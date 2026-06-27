import 'package:flutter/material.dart';

import 'services/haptic_service.dart';

const _deepPurple = Color(0xFF2D1B69);
const _paleGold = Color(0xFFC9A84C);

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
        scaffoldBackgroundColor: _deepPurple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _deepPurple,
          brightness: Brightness.dark,
          primary: _paleGold,
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
  PulsePreset _selectedPreset = PulsePreset.calm;
  bool _isPulsing = false;

  void _toggle() {
    if (_isPulsing) {
      _hapticService.stop();
      setState(() => _isPulsing = false);
    } else {
      _hapticService.start(_selectedPreset);
      setState(() => _isPulsing = true);
    }
  }

  @override
  void dispose() {
    _hapticService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepPurple,
      body: SafeArea(
        child: Center(
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
              const SizedBox(height: 48),
              ToggleButtons(
                isSelected: PulsePreset.values.map((p) => p == _selectedPreset).toList(),
                onPressed: _isPulsing
                    ? null
                    : (index) {
                        setState(() => _selectedPreset = PulsePreset.values[index]);
                      },
                borderRadius: BorderRadius.circular(8),
                selectedColor: _deepPurple,
                fillColor: _paleGold,
                color: Colors.white70,
                children: PulsePreset.values
                    .map((p) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Text(p.label),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 64),
              GestureDetector(
                onTap: _toggle,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isPulsing ? _paleGold : Colors.transparent,
                    border: Border.all(color: _paleGold, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _isPulsing ? 'Stop' : 'Start',
                      style: TextStyle(
                        color: _isPulsing ? _deepPurple : _paleGold,
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
      ),
    );
  }
}
