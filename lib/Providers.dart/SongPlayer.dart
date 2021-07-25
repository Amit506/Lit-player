import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lit_player/Providers.dart/BackgroundTask.dart';
import 'package:lit_player/Providers.dart/thumbnail.dart';

import 'package:media_stores/SongInfo.dart';
import 'package:media_stores/media_stores.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shimmer/shimmer.dart';
import './song.dart';

const universalImage = 'assets/SPACE_album-mock.jpg';

class SongPlayer extends ChangeNotifier {
  final highQualityThumbnail = Thumbnail(500, 600);
  final isolates = IsolateHandler();
  static AudioPlayer player = AudioPlayer();
  static final SongPlayer _singleton = SongPlayer._internal();
  final backgroundAudioPlayer = AudioPlayerTask();

  factory SongPlayer() {
    return _singleton;
  }
  Timer sleepTimer;
  setSleepTimer(int min) {
    removeSleepTimer();
    sleepTimer = Timer(Duration(minutes: min), () {
      stop();
    });
  }

  removeSleepTimer() {
    if (sleepTimer?.isActive ?? false) sleepTimer.cancel();
  }

  SongPlayer._internal();

  ValueKey _key;
  ValueKey get key => this._key;
  SongInfo latestSongInfo;
  SongInfo get getLatestSongInfo => this.latestSongInfo;
  Uint8List imageByte;
  get getImageByte => this.imageByte;

  set setImageByte(imageByte) => this.imageByte = imageByte;
  set setLatestSongInfo(latestSongInfo) => this.latestSongInfo = latestSongInfo;
  set key(ValueKey value) => this._key = value;

  List<SongInfo> currentPlayList = [];
  List<SongInfo> get getCurrentPlayList => this.currentPlayList;

  set setCurrentPlayList(currentPlayList) =>
      this.currentPlayList = currentPlayList;

  int _curentId;
  int _currentIndex;
  int get getCurentId => this._curentId;
  double _sliderMin = 0.0;
  double _sliderMax = 0.0;
  double _sliderCurrent = 0.0;
  get playListPreviousIndex => player.previousIndex;
  get playListNextIndex => player.nextIndex;
  get playListIndex => player.currentIndex;
  get sliderMin => this._sliderMin;

  set sliderMin(int value) => this._sliderMin = value.toDouble();

  get sliderMax => this._sliderMax;

  set sliderMax(int value) => this._sliderMax = value.toDouble();

  get sliderCurrent => this._sliderCurrent;

  set sliderCurrent(int value) => this._sliderCurrent = value.toDouble();

  set setCurentId(int curentId) => this._curentId = curentId;

  get getCurrentIndex => this._currentIndex;

  set setCurrentIndex(currentIndex) => this._currentIndex = currentIndex;
  bool _isFirstTimeStarted = false;
  bool get getIsFirstTimeStarted => this._isFirstTimeStarted;

  set setIsFirstTimeStarted(bool isFirstTimeStarted) =>
      this._isFirstTimeStarted = isFirstTimeStarted;
  Future<Duration> setMusicUri(String uri) async {
    return await player.setUrl(uri);
  }

  Color playButtonColor = Colors.white;
  get getPlayButtonColor => this.playButtonColor;

  set setPlayButtonColor(Color playButtonColor) =>
      this.playButtonColor = playButtonColor;
  LinearGradient gradientBackground;
  get getGradientBackground => this.gradientBackground;

  set setGradientBackground(gradientBackground) =>
      this.gradientBackground = gradientBackground;
  bool get isPlaying => player.playing;

  bool get hasNext => player.hasNext;
  bool get hasPrevious => player.hasPrevious;
  Duration get duration => player.duration;
  Future<void> generatebackGroundColor(
    Uint8List byte,
  ) async {
    if (byte != null) {
      final p = await MediaStores.getPalete(byte);
      setLinearGradients(p);
      print(p.toString());
    } else {
      final image = await rootBundle.load('assets/music-note.png');
      final p = await MediaStores.getPalete(image.buffer.asUint8List());
      print(p.toString());
      setLinearGradients(p);

      // AssetImage('assets/music-note.png');
    }
  }

  setLinearGradients(p) {
    final newGradient = LinearGradient(
        colors: [
          p.dominantColor,
          p.mutedColor,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.4, 0.7]);
    setGradientBackground = newGradient;
    setPlayButtonColor = p.vibrantColor ?? p.darkMutedColor;
    notifyListeners();
  }

  // isolateHandle(List<int> image) {
  //   isolates.spawn(entryPoint,
  //       name: 'path',
  //       onReceive: (valye) {},
  //       onInitialized: () => isolates.send('dvbdvndfv d', to: 'path'));
  // }

  playInit() {
    setSliderValues();
    play();
  }

  setSliderValues() {
    if (player.duration != null) {
      sliderMax = player.duration.inMilliseconds;
    }
    sliderCurrent = 0;
    notifyListeners();
  }

  play() async {
    await player.play();
    await AudioService.playMediaItem(MediaItem(
        id: latestSongInfo.id,
        album: latestSongInfo.album,
        title: latestSongInfo.title));
    notifyListeners();
  }

  pause() {
    player.pause();
    AudioService.pause();

    notifyListeners();
  }

  stop() {
    player.stop();
    AudioService.stop();

    notifyListeners();
  }

  playNext() async {
    await player.seekToNext().then((value) {
      setSliderValues();
    });
    notifyListeners();
  }

  playPrevious() async {
    await player.seekToPrevious().then((value) {
      setSliderValues();
    });
    notifyListeners();
  }

  indexesStream() async {
    player.currentIndexStream.listen((event) async {
      if (getCurrentPlayList.length != 0) {
        print('-------------' + event.toString());

        final image = await highQualityThumbnail
            .getSongThumbnail(int.parse(getCurrentPlayList[event].id));
        setImageByte = image;
        generatebackGroundColor(image);

        latestSongInfo = getCurrentPlayList[event];
        notifyListeners();
        setSliderValues();
      }
    });
  }

  listenStream() {
    player.positionStream.listen((event) {
      if (event.inMilliseconds <= sliderMax)
        sliderCurrent = event.inMilliseconds;

      notifyListeners();
    });
  }

  sliderValueChanged(double value) {
    player.seek(Duration(milliseconds: value.round()));
    notifyListeners();
  }

  playerState() {
    player.playerStateStream.listen((event) {
      print(AudioService.currentMediaItem);
      if (event.playing)
        AudioService.play();
      else {
        AudioService.pause();
      }
    });
  }

  Future playerSetAudioSoucres(List<SongInfo> songInfo,
      {int initialIndex = 0}) async {
    await player.setAudioSource(
      ConcatenatingAudioSource(
          useLazyPreparation: true, // default
          // Customise the shuffle algorithm.
          shuffleOrder: DefaultShuffleOrder(random: Random.secure()), // default
          // Specify the items in the playlist.
          children: songInfo
              .map((e) => ProgressiveAudioSource(Uri.parse(e.uri)))
              .toList()),

      // Playback will be prepared to start from track1.mp3
      initialIndex: initialIndex, // default

      initialPosition: Duration.zero, // default
    );
    sequenceStateChange();
  }

  sequenceStateChange() async {
    player.sequenceStateStream.listen((event) async {
      final int index = event.currentIndex;

      final mode = event.loopMode;

      if ((!getIsFirstTimeStarted && mode != LoopMode.one)) {
        latestSongInfo = getCurrentPlayList[index];

        notifyListeners();
      }

      if (getIsFirstTimeStarted) {
        setIsFirstTimeStarted = false;
      }
    });
  }

  // LoopMode previousLoopMode = LoopMode.off;
  // get getPreviousLoopMode => this.previousLoopMode;

  // set setPreviousLoopMode(previousLoopMode) =>
  //     this.previousLoopMode = previousLoopMode;
  LoopMode get getLoopMode => player.loopMode;
  bool get isShuffleEnabled => player.shuffleModeEnabled;
  loopOn() {
    player.setLoopMode(LoopMode.all);
  }

  loopOff() {
    player.setLoopMode(LoopMode.off);
  }

  loopOnlyOne() async {
    await player.setLoopMode(LoopMode.one);
  }

  shuffleOn() async {
    await player.setShuffleModeEnabled(true);
  }

  shuffleOf() async {
    await player.setShuffleModeEnabled(false);
  }

  playButtonAnimation(AnimationController playButton) async {
    if (player.playing) {
      playButton.reverse();
      player.pause();
    } else {
      player.play();

      playButton.forward();
    }
    notifyListeners();
  }

//////////////////////////////////////////////////background
//   bool isBackGroundAudioPlaying = false;
//   bool get getIsBackGroundAudioPlaying => this.isBackGroundAudioPlaying;
//   List<MediaItem> mediaItem;
//   List<MediaItem> get getMediaItem => this.mediaItem;

//   set setMediaItem(List<MediaItem> mediaItem) => this.mediaItem = mediaItem;
//   set setIsBackGroundAudioPlaying(bool isBackGroundAudioPlaying) =>
//       this.isBackGroundAudioPlaying = isBackGroundAudioPlaying;
//   void convertToMediaItems() {
//     setMediaItem = getCurrentPlayList
//         .map<MediaItem>((e) => MediaItem(
//             id: e.id, album: e.album, title: e.title, artist: e.artist))
//         .toList();
//   }
  List<MediaItem> get mediaItem => getCurrentPlayList
      .map<MediaItem>((e) => MediaItem(
          id: e.id,
          album: e.album,
          title: e.title,
          duration: Duration(milliseconds: int.parse(e.duration))))
      .toList();

  initiatingBackGroundTask() async {
    await AudioService.start(
            androidEnableQueue: true,
            backgroundTaskEntrypoint: _backgroundTaskEntrypoint)
        .then((value) async {
      AudioService.playbackStateStream.listen((event) {
        print('-------------------------------------------' +
            event.playing.toString());
        // setIsBackGroundAudioPlaying = event.playing;
      });
    });
  }
// }

}

_backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

// class Worker {
//   SendPort sendPort;
//   Isolate isolate;
//   Completer<void> isolateReady = Completer<void>();
//   Worker() {
//     init();
//   }
//   void getPate(ImageProvider imageProvider) {
//     sendPort.send(imageProvider);
//   }

//   Future<void> init() async {
//     var receivePort = ReceivePort();

//     receivePort.listen(handleMessage);
//     isolate = await Isolate.spawn(isolateEntry, receivePort.sendPort);
//   }

//   Future<void> get iisolateReady => isolateReady.future;
//   void dispose() {
//     isolate.kill();
//   }

//   static void isolateEntry(SendPort message) {
//     SendPort sendPort;

//     final recieve = ReceivePort();
//     recieve.listen((message) {
//       assert(message is PaletteGenerator);
//       sendPort.send(message as PaletteGenerator);
//     });
//     if (message is SendPort) {
//       sendPort = message;
//       sendPort.send(recieve.sendPort);
//       return;
//     }
//   }

//   void handleMessage(message) {
//     if (message is SendPort) {
//       sendPort = message;
//       isolateReady.complete();
//       return;
//     }
//     print(message);
//   }
// }

// getPal(ImageProvider<Object> image) async {
//   print('iiiiiiiiiiiiiiiiiiiiiiiiiiiiiii');
//   if (image != null) {
//     final p = PaletteGenerator.fromImageProvider(image);
//     print(p.toString());
//   } else
//     print('iiiiiiiiiiiiiiiiiiiiiiiiiiiiiii');

//   return null;
// }
