import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerController {
  static final AudioPlayerController _instance =
      AudioPlayerController._internal();
  factory AudioPlayerController() => _instance;
  AudioPlayerController._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> play(String url) async {
    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  void dispose() {
    _audioPlayer.dispose();
  }
}
