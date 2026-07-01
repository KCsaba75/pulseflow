import 'package:supabase_flutter/supabase_flutter.dart';

import 'haptic_service.dart';

class SessionService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<void> logSession({
    required PulsePreset preset,
    required int durationSeconds,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('session_logs').insert({
      'user_id': userId,
      'preset': preset.name,
      'duration_seconds': durationSeconds,
      'started_at': DateTime.now()
          .subtract(Duration(seconds: durationSeconds))
          .toUtc()
          .toIso8601String(),
      'ended_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
