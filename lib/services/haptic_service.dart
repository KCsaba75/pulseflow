import 'package:vibration/vibration.dart';

enum PulsePreset { sleep, calm, focus }

extension PulsePresetBpm on PulsePreset {
  int get bpm {
    switch (this) {
      case PulsePreset.sleep:
        return 50;
      case PulsePreset.calm:
        return 60;
      case PulsePreset.focus:
        return 70;
    }
  }

  String get label {
    switch (this) {
      case PulsePreset.sleep:
        return 'Sleep';
      case PulsePreset.calm:
        return 'Calm';
      case PulsePreset.focus:
        return 'Focus';
    }
  }

  String get audioAsset {
    switch (this) {
      case PulsePreset.sleep:
        return 'assets/audio/sleep_ambient.mp3';
      case PulsePreset.calm:
        return 'assets/audio/calm_ambient.mp3';
      case PulsePreset.focus:
        return 'assets/audio/focus_ambient.mp3';
    }
  }
}

class HapticService {
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  Future<void> start(PulsePreset preset) async {
    final hasVibrator = await Vibration.hasVibrator();
    if (!hasVibrator) return;

    _isRunning = true;
    final beatIntervalMs = (60000 / preset.bpm).round();

    while (_isRunning) {
      Vibration.vibrate(duration: 120);
      await Future.delayed(Duration(milliseconds: beatIntervalMs));
    }
  }

  void stop() {
    _isRunning = false;
    Vibration.cancel();
  }
}
