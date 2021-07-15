import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerProvider extends ChangeNotifier {
  VideoPlayerController _videocontroller;
  AnimationController animatedButtonController;
  VideoPlayerController get videocontroller => this._videocontroller;

  set videocontroller(VideoPlayerController value) =>
      this._videocontroller = value;
  onInitVideo(String uri) {
    videocontroller = VideoPlayerController.file(File.fromUri(Uri.parse(uri)));
    sliderListenSetup();
    postionStream();
  }

  void sliderListenSetup() async {
    sliderMax = videocontroller.value.duration.inMilliseconds;
    sliderCurrent = 0;
    notifyListeners();
  }

  double _sliderMin = 0.0;
  double _sliderMax = 0.0;
  double _sliderCurrent = 0.0;
  get sliderMin => this._sliderMin;

  set sliderMin(int value) => this._sliderMin = value.toDouble();

  get sliderMax => this._sliderMax;

  set sliderMax(int value) => this._sliderMax = value.toDouble();

  get sliderCurrent => this._sliderCurrent;

  set sliderCurrent(int value) => this._sliderCurrent = value.toDouble();

  get currentMaxSliderPostion =>
      videocontroller.value.duration.inMilliseconds ?? this.sliderCurrent;

  void setOverLayOnEnd() {
    showOverLay = true;
    notifyListeners();
  }

  void instantHideOverLay() {
    showOverLay = false;
    notifyListeners();
  }

  void hideOverLay() {
    Future.delayed(Duration(seconds: 2), () {
      showOverLay = false;
      notifyListeners();
    });
  }

  void showOverLayFunction() {
    showOverLay = true;
    notifyListeners();
  }

  bool showOverLay = true;
  void postionStream() {
    videocontroller.addListener(() {
      if (videocontroller.value.position.inSeconds ==
          videocontroller.value.duration.inSeconds) {
        animatedButtonController.forward();
        setOverLayOnEnd();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _videocontroller.dispose();

    super.dispose();
  }
}
