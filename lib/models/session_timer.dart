enum SessionTimer { min20, min45, night }

extension SessionTimerDuration on SessionTimer {
  Duration? get duration {
    switch (this) {
      case SessionTimer.min20:
        return const Duration(minutes: 20);
      case SessionTimer.min45:
        return const Duration(minutes: 45);
      case SessionTimer.night:
        return null;
    }
  }

  String get label {
    switch (this) {
      case SessionTimer.min20:
        return '20 min';
      case SessionTimer.min45:
        return '45 min';
      case SessionTimer.night:
        return 'Night';
    }
  }
}
