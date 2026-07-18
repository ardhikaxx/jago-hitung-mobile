import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService instance = SoundService._internal();

  factory SoundService() {
    return instance;
  }

  SoundService._internal();

  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();

  Future<void> init() async {
    // Preload sounds for faster playback
    await _clickPlayer.setSource(AssetSource('sounds/click.wav'));
    await _correctPlayer.setSource(AssetSource('sounds/success.wav'));
    await _wrongPlayer.setSource(AssetSource('sounds/error.wav'));
    
    // Set players to low latency mode if needed
    _clickPlayer.setPlayerMode(PlayerMode.lowLatency);
    _correctPlayer.setPlayerMode(PlayerMode.lowLatency);
    _wrongPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  void playClick() async {
    try {
      await _clickPlayer.stop();
      await _clickPlayer.resume();
    } catch (_) {}
  }

  void playCorrect() async {
    try {
      await _correctPlayer.stop();
      await _correctPlayer.resume();
    } catch (_) {}
  }

  void playWrong() async {
    try {
      await _wrongPlayer.stop();
      await _wrongPlayer.resume();
    } catch (_) {}
  }
}
