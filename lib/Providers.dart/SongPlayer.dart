import 'dart:math';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lit_player/Providers.dart/BackgroundTask.dart';
import 'package:marquee/marquee.dart';
import 'package:media_stores/SongInfo.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shimmer/shimmer.dart';
import './song.dart';

const universalImage = 'assets/SPACE_album-mock.jpg';

class SongPlayer extends ChangeNotifier {
  static AudioPlayer player = AudioPlayer();
  static final SongPlayer _singleton = SongPlayer._internal();
  final backgroundAudioPlayer = AudioPlayerTask();

  factory SongPlayer() {
    return _singleton;
  }

  SongPlayer._internal();
  Widget currentWidget = Center(
    child: CircularProgressIndicator(),
  );
  ValueKey _key;
  ValueKey get key => this._key;
  SongInfo latestSongInfo;
  SongInfo get getLatestSongInfo => this.latestSongInfo;

  set setLatestSongInfo(latestSongInfo) => this.latestSongInfo = latestSongInfo;
  set key(ValueKey value) => this._key = value;
  get getCurrentWidget => this.currentWidget;
  List<SongInfo> currentPlayList = [];
  List<SongInfo> get getCurrentPlayList => this.currentPlayList;

  set setCurrentPlayList(currentPlayList) =>
      this.currentPlayList = currentPlayList;
  set setCurrentWidget(currentWidget) => this.currentWidget = currentWidget;
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

  Color color = Colors.white;
  LinearGradient gradientBackground;
  get getGradientBackground => this.gradientBackground;

  set setGradientBackground(gradientBackground) =>
      this.gradientBackground = gradientBackground;
  bool get isPlaying => player.playing;

  bool get hasNext => player.hasNext;
  bool get hasPrevious => player.hasPrevious;
  Duration get duration => player.duration;
  generatebackGroundColor(
    Uint8List byte,
  ) async {
    ImageProvider<Object> image;
    if (byte != null) {
      image = MemoryImage(byte);
    } else {
      image = AssetImage('assets/SPACE_album-mock.jpg');
    }

    final p = await PaletteGenerator.fromImageProvider(image);

    final newGradient = LinearGradient(
        colors: [
          p.dominantColor.color,
          p.lightVibrantColor.color,
          // p.lightMutedColor.color
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        stops: [0.4, 0.7]);
    setGradientBackground = newGradient;
    notifyListeners();
  }

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
    AudioService.play();
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
    // AudioService.currentMediaItemStream.listen((event) {
    //   print("000");
    //   print(event.toString());
    // });
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
      print('-------------' + event.toString());
      key = ValueKey(event);
      final image = await Thumbnail.getQualityThumbnail(
          event, int.parse(getCurrentPlayList[event].id));

      generatebackGroundColor(image);

      setCurrentWidget = image != null
          ? Image.memory(
              image,
              key: key,
            )
          : Image.asset(
              'assets/SPACE_album-mock.jpg',
              fit: BoxFit.cover,
              key: key,
            );

      latestSongInfo = getCurrentPlayList[event];
      notifyListeners();
      setSliderValues();
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
    player.playerStateStream.listen((event) {});
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
    print('--------');

    player.sequenceStateStream.listen((event) async {
      print(event.toString());
      final int index = event.currentIndex;

      final mode = event.loopMode;
      // print('mode ' + mode.toString());
      // print('current -------' + index.toString());
      // print('next -------' + playListNextIndex.toString());
      // print('previous-------' + playListPreviousIndex.toString());
      // print(getIsFirstTimeStarted.toString());
      if ((!getIsFirstTimeStarted && mode != LoopMode.one)) {
        latestSongInfo = getCurrentPlayList[index];

        // print(image.toString());
        notifyListeners();
        // setSliderValues();
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

  Widget loopWidgets(VoidCallback onChange, LoopMode loopMode) {
    Widget loopWidget;
    switch (loopMode) {
      case LoopMode.off:
        {
          loopWidget = IconButton(
              color: Colors.grey, icon: Icon(Icons.loop), onPressed: onChange);
        }
        break;
      case LoopMode.one:
        {
          loopWidget =
              IconButton(icon: Icon(Icons.repeat), onPressed: onChange);
        }
        break;
      case LoopMode.all:
        {
          loopWidget = IconButton(icon: Icon(Icons.loop), onPressed: onChange);
        }
        break;
    }
    return loopWidget;
  }

  Widget shuffleWidget(bool value, VoidCallback onTap) {
    if (value) {
      return IconButton(
        icon: Icon(
          Icons.shuffle,
        ),
        onPressed: onTap,
      );
    } else {
      return IconButton(
        color: Colors.grey,
        icon: Icon(Icons.shuffle),
        onPressed: onTap,
      );
    }
  }

  Widget smallPlayerTextWidget(SongInfo info, Size size) {
    key = ValueKey(Random().nextInt(200000));
    if (latestSongInfo == null) {
      return Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          child: Column(
            children: [
              Container(
                height: 10.0,
                width: double.infinity,
                color: Colors.white,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 10.0,
                width: double.infinity,
                color: Colors.white,
              )
            ],
          ));
    } else {
      return Column(
        key: key,
        children: [
          Flexible(
            child: Marquee(
              text: getLatestSongInfo.title,
              style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.green,
                  fontWeight: FontWeight.w400),
              blankSpace: 20.0,
              velocity: 100.0,
              pauseAfterRound: Duration(seconds: 1),
              startPadding: 10.0,
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              accelerationDuration: Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          ),
          Flexible(child: Text(getLatestSongInfo.artist))
        ],
      );
    }
  }

  Widget bigPlayerTextWidget(SongInfo info, Size size) {
    key = ValueKey(Random().nextInt(200000));

    return Column(
      key: key,
      children: [
        Flexible(
          child: Marquee(
            text: getLatestSongInfo.title,
            style: TextStyle(
                fontSize: 14.0,
                color: Colors.green,
                fontWeight: FontWeight.w400),
            blankSpace: 20.0,
            velocity: 100.0,
            pauseAfterRound: Duration(seconds: 1),
            startPadding: 10.0,
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            accelerationDuration: Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
        ),
        Flexible(child: Text(getLatestSongInfo.artist))
      ],
    );
  }

  playButtonAnimation(AnimationController playButton) {
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

  initiatingBackGroundTask() async {
    print("pppppppppppppppppppppp");
    await AudioService.start(
            backgroundTaskEntrypoint: _backgroundTaskEntrypoint)
        .then((value) {
      print("----------------------------------" + value.toString());
      AudioService.playbackStateStream.listen((event) {
        print(event.playing);
        // setIsBackGroundAudioPlaying = event.playing;
      });
    });
//     Thumbnail.getQualityThumbnail(0,  getCurrentPlayList[0].id);
// final media = MediaItem(id: getCurrentPlayList[0].id, album:getCurrentPlayList[0]. album, title: getCurrentPlayList[0].title,bitMap: getCurrentPlayList[0])
//     AudioServiceBackground.setMediaItem(getCurrentPlayList[isPlaying])
  }
// }

}

_backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}
