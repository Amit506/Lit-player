import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerProvider extends ChangeNotifier {
  Timer _timer;
  Timer _rightFastForwardTimer;
  Timer _leftFastForwardTimer;
  VideoPlayerController _videocontroller;
  AnimationController animatedButtonController;
  int initialForward = 10;
  VideoPlayerController get videocontroller => this._videocontroller;
  bool showLeftFastWordWidget = false;
  bool showRightFastWordWidget = false;
  set videocontroller(VideoPlayerController value) =>
      this._videocontroller = value;
  onInitVideo(String uri) {
    videocontroller = VideoPlayerController.file(File.fromUri(Uri.parse(uri)));
    sliderListenSetup();
    postionStream();
  }

  setShowLeftfastForwardWidget() {
    videocontroller.seekTo(Duration(
        seconds: videocontroller.value.position.inSeconds - initialForward));
    initialForward -= 10;
    if (_leftFastForwardTimer?.isActive ?? false)
      _rightFastForwardTimer.cancel();

    showLeftFastWordWidget = true;
    _leftFastForwardTimer = Timer(Duration(seconds: 1), () {
      setHideLeftfastForwardWidget();
    });
    notifyListeners();
  }

  setHideLeftfastForwardWidget() {
    initialForward = 10;
    showLeftFastWordWidget = false;
    notifyListeners();
  }

  setShowRightfastForwardWidget() {
    videocontroller.seekTo(Duration(
        seconds: videocontroller.value.position.inSeconds + initialForward));
    initialForward += 10;
    if (_rightFastForwardTimer?.isActive ?? false)
      _rightFastForwardTimer.cancel();

    showRightFastWordWidget = true;
    _rightFastForwardTimer = Timer(Duration(seconds: 1), () {
      setHideRightfastForwardWidget();
    });
    notifyListeners();
  }

  setHideRightfastForwardWidget() {
    initialForward = 10;
    showRightFastWordWidget = false;
    notifyListeners();
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
    removeTimer();
    Future.delayed(Duration(seconds: 1), () {
      showOverLay = false;
      notifyListeners();
    });
  }

  setTimer() {
    _timer = Timer(Duration(seconds: 3), () {
      instantHideOverLay();
    });
  }

  removeTimer() {
    if (_timer?.isActive ?? false) _timer.cancel();
  }

  void showOverLayFunction() {
    removeTimer();
    showOverLay = true;
    setTimer();
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
