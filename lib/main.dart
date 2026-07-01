import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'models/session_timer.dart';
import 'screens/login_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/settings_screen.dart';
import 'services/audio_service.dart';
import 'services/haptic_service.dart';
import 'services/subscription_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const PulseFlowApp());
}

class PulseFlowApp extends StatelessWidget {
  const PulseFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulsoma',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: PulseFlowColors.deepPurple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PulseFlowColors.deepPurple,
          brightness: Brightness.dark,
          primary: PulseFlowColors.paleGold,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return const LoginScreen();
        }
        return const HomeScreen();
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _hapticService = HapticService();
  final _audioService = AudioService();
  final _subscriptionService = SubscriptionService();

  PulsePreset _selectedPreset = PulsePreset.calm;
  SessionTimer _selectedTimer = SessionTimer.min20;
  bool _isPulsing = false;
  bool _isPremium = false;
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();
    _initSubscription();
  }

  Future<void> _initSubscription() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    await _subscriptionService.init(appUserId: userId);
    final isPremium = await _subscriptionService.isPremium();
    if (mounted) setState(() => _isPremium = isPremium);
  }

  Future<void> _openPaywall() async {
    final purchased = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
    if (purchased == true && mounted) {
      setState(() => _isPremium = true);
    }
  }

  void _selectTimer(SessionTimer timer) {
    if (!_isPremium && timer != SessionTimer.min20) {
      _openPaywall();
      return;
    }
    setState(() => _selectedTimer = timer);
  }

  void _toggle() {
    if (_isPulsing) {
      _stop();
    } else {
      _start();
    }
  }

  void _start() {
    _hapticService.start(_selectedPreset);
    _audioService.start(_selectedPreset);
    setState(() => _isPulsing = true);

    final cappedTimer = _isPremium ? _selectedTimer : SessionTimer.min20;
    final duration = cappedTimer.duration ?? AppConfig.freeSessionLimit;
    _sessionTimer = Timer(duration, _stop);
  }

  void _stop() {
    _hapticService.stop();
    _audioService.stop();
    _sessionTimer?.cancel();
    _sessionTimer = null;
    if (mounted) {
      setState(() => _isPulsing = false);
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _hapticService.stop();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PulseFlowColors.deepPurple,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.settings, color: PulseFlowColors.paleGold),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pulsoma',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ToggleButtons(
                    isSelected: PulsePreset.values.map((p) => p == _selectedPreset).toList(),
                    onPressed: _isPulsing
                        ? null
                        : (index) {
                            setState(() => _selectedPreset = PulsePreset.values[index]);
                          },
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: PulseFlowColors.deepPurple,
                    fillColor: PulseFlowColors.paleGold,
                    color: Colors.white70,
                    children: PulsePreset.values
                        .map((p) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Text(p.label),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  ToggleButtons(
                    isSelected: SessionTimer.values.map((t) => t == _selectedTimer).toList(),
                    onPressed: _isPulsing
                        ? null
                        : (index) => _selectTimer(SessionTimer.values[index]),
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: PulseFlowColors.deepPurple,
                    fillColor: PulseFlowColors.paleGold,
                    color: Colors.white70,
                    children: SessionTimer.values
                        .map((t) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(t.label),
                                  if (!_isPremium && t != SessionTimer.min20) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.lock, size: 14),
                                  ],
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  if (!_isPremium) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _openPaywall,
                      child: const Text(
                        'Go Premium for unlimited sessions',
                        style: TextStyle(color: PulseFlowColors.paleGold),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _toggle,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isPulsing ? PulseFlowColors.paleGold : Colors.transparent,
                        border: Border.all(color: PulseFlowColors.paleGold, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          _isPulsing ? 'Stop' : 'Start',
                          style: TextStyle(
                            color: _isPulsing ? PulseFlowColors.deepPurple : PulseFlowColors.paleGold,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
