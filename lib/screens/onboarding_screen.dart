import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';

const _kOnboardingSeenKey = 'onboarding_seen';

Future<bool> hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingSeenKey) ?? false;
}

Future<void> markOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingSeenKey, true);
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.vibration,
      title: 'Feel the rhythm',
      body: 'Gentle haptic pulses guide your breathing and calm your nervous system.',
    ),
    _OnboardingPage(
      icon: Icons.tune,
      title: 'Choose your state',
      body: 'Sleep, Calm, or Focus — each preset is tuned to a different heart-rate rhythm.',
    ),
    _OnboardingPage(
      icon: Icons.play_circle_outline,
      title: 'Start any time',
      body: 'Tap Start and let Pulsoma do the rest. No setup, no noise — just you.',
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await markOnboardingSeen();
    widget.onDone();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PulseFlowColors.deepPurple,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip', style: TextStyle(color: Colors.white54)),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: _pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => _Dot(active: i == _page)),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PulseFlowColors.paleGold,
                    foregroundColor: PulseFlowColors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(_page < _pages.length - 1 ? 'Next' : 'Get started'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _OnboardingPage({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: PulseFlowColors.paleGold),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w300, letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? PulseFlowColors.paleGold : Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
