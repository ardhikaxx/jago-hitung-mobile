import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService instance = SoundService._();
  SoundService._();

  final AudioPlayer _player = AudioPlayer();

  void init() {}

  Future<void> playClick() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/click.wav'));
    } catch (_) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> playCorrect() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/correct.wav'));
    } catch (_) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> playWrong() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/wrong.wav'));
    } catch (_) {
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> playCelebration() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/celebration.wav'));
    } catch (_) {
      HapticFeedback.mediumImpact();
    }
  }

  void dispose() {
    _player.dispose();
  }
}
