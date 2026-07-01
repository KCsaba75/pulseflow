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
    // Stopwatch anchors timing to session start so per-beat overhead never accumulates.
    final stopwatch = Stopwatch()..start();
    int beatCount = 0;

    while (_isRunning) {
      Vibration.vibrate(duration: 120);
      beatCount++;

      final nextBeatMs = beatCount * beatIntervalMs;
      final remainingMs = nextBeatMs - stopwatch.elapsedMilliseconds;
      if (remainingMs > 0) {
        await Future.delayed(Duration(milliseconds: remainingMs));
      }
      // If remainingMs <= 0 the system was slow — fire the next beat immediately.
    }
  }

  void stop() {
    _isRunning = false;
    Vibration.cancel();
  }
}
