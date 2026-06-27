import 'package:flutter/material.dart';

import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PulseFlowColors.deepPurple,
      appBar: AppBar(
        backgroundColor: PulseFlowColors.deepPurple,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: PulseFlowColors.paleGold),
      ),
      body: const Center(
        child: Text(
          'Account, subscription and notification\nsettings will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}
