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
  final AudioPlayer _bgmPlayer = AudioPlayer();

  bool _bgmEnabled = true;

  bool get isBgmEnabled => _bgmEnabled;

  Future<void> init() async {
    await _clickPlayer.setSource(AssetSource('sounds/click.wav'));
    await _correctPlayer.setSource(AssetSource('sounds/success.wav'));
    await _wrongPlayer.setSource(AssetSource('sounds/error.wav'));

    _clickPlayer.setPlayerMode(PlayerMode.lowLatency);
    _correctPlayer.setPlayerMode(PlayerMode.lowLatency);
    _wrongPlayer.setPlayerMode(PlayerMode.lowLatency);

    await _bgmPlayer.setSource(AssetSource('sounds/backsound.mp3'));
    _bgmPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
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

  Future<void> playBgm() async {
    if (!_bgmEnabled) return;
    try {
      await _bgmPlayer.resume();
    } catch (_) {}
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.pause();
    } catch (_) {}
  }

  void toggleBgm() {
    _bgmEnabled = !_bgmEnabled;
    if (_bgmEnabled) {
      playBgm();
    } else {
      stopBgm();
    }
  }

  void setBgmEnabled(bool enabled) {
    _bgmEnabled = enabled;
    if (_bgmEnabled) {
      playBgm();
    } else {
      stopBgm();
    }
  }

  void dispose() {
    _clickPlayer.dispose();
    _correctPlayer.dispose();
    _wrongPlayer.dispose();
    _bgmPlayer.dispose();
  }
}
