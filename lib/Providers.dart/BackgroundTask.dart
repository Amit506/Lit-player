import 'package:audio_service/audio_service.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  static final AudioPlayerTask _singleton = AudioPlayerTask._internal();

  factory AudioPlayerTask() {
    return _singleton;
  }

  AudioPlayerTask._internal();

  final _audioPlayer = SongPlayer.player;
  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    AudioServiceBackground.setState(controls: [
      MediaControl.pause,
      MediaControl.stop,
      MediaControl.skipToNext,
      MediaControl.skipToPrevious
    ], playing: true, processingState: AudioProcessingState.connecting);

    await _audioPlayer.play();
    AudioServiceBackground.setState(controls: [
      MediaControl.pause,
      MediaControl.stop,
      MediaControl.skipToNext,
      MediaControl.skipToPrevious
    ], playing: true, processingState: AudioProcessingState.ready);

    return super.onStart(params);
  }

  @override
  Future<void> onStop() async {
    print(
        "stop..................................................................");
    AudioServiceBackground.setState(
        controls: [],
        playing: false,
        processingState: AudioProcessingState.stopped);
    await _audioPlayer.stop();
    return super.onStop();
  }

  @override
  Future<void> onPause() async {
    print(
        "pauseddd..................................................................");
    AudioServiceBackground.setState(controls: [
      MediaControl.play,
      MediaControl.stop,
      MediaControl.skipToNext,
      MediaControl.skipToPrevious
    ], playing: true, processingState: AudioProcessingState.ready);
    await _audioPlayer.pause();
    return super.onPause();
  }

  @override
  Future<void> onPlay() async {
    print(
        "play..................................................................");
    AudioServiceBackground.setState(controls: [
      MediaControl.pause,
      MediaControl.stop,
      MediaControl.skipToNext,
      MediaControl.skipToPrevious
    ], playing: true, processingState: AudioProcessingState.ready);
    await _audioPlayer.play();
    return super.onPlay();
  }

  Future<void> seekToNext() async {
    AudioServiceBackground.setState(controls: [
      MediaControl.pause,
      MediaControl.stop,
      MediaControl.skipToNext,
      MediaControl.skipToPrevious
    ], playing: true, processingState: AudioProcessingState.ready);
    await _audioPlayer.seekToNext();
    return super.onSeekForward(true);
  }

  Future<void> seekToPrevious() async {
    AudioServiceBackground.setState(controls: [
      MediaControl.pause,
      MediaControl.stop,
      MediaControl.skipToNext,
      MediaControl.skipToPrevious
    ], playing: true, processingState: AudioProcessingState.ready);
    await _audioPlayer.seekToPrevious();
    return super.onSeekBackward(true);
  }
}
