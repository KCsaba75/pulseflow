import 'package:just_audio/just_audio.dart';

import 'haptic_service.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> start(PulsePreset preset) async {
    await _player.setAsset(preset.audioAsset);
    await _player.setLoopMode(LoopMode.one);
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
