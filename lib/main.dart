import 'dart:async';

import 'package:flutter/material.dart';

import 'models/session_timer.dart';
import 'screens/settings_screen.dart';
import 'services/audio_service.dart';
import 'services/haptic_service.dart';
import 'theme.dart';

void main() {
  runApp(const PulseFlowApp());
}

class PulseFlowApp extends StatelessWidget {
  const PulseFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulseFlow',
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
      home: const HomeScreen(),
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

  PulsePreset _selectedPreset = PulsePreset.calm;
  SessionTimer _selectedTimer = SessionTimer.min20;
  bool _isPulsing = false;
  Timer? _sessionTimer;

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

    final duration = _selectedTimer.duration;
    if (duration != null) {
      _sessionTimer = Timer(duration, _stop);
    }
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
                    'PulseFlow',
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
                        : (index) {
                            setState(() => _selectedTimer = SessionTimer.values[index]);
                          },
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: PulseFlowColors.deepPurple,
                    fillColor: PulseFlowColors.paleGold,
                    color: Colors.white70,
                    children: SessionTimer.values
                        .map((t) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Text(t.label),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 56),
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
