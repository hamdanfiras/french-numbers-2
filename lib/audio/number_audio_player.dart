import 'package:audioplayers/audioplayers.dart';

abstract interface class NumberAudioPlayer {
  Future<void> play(int number);

  Future<void> stop();

  Future<void> dispose();
}

class AssetNumberAudioPlayer implements NumberAudioPlayer {
  AssetNumberAudioPlayer() : _player = AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> play(int number) async {
    await _player.stop();
    final completed = _player.onPlayerComplete.first;
    await _player.play(AssetSource('audio/$number.m4a'));
    await completed;
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}
