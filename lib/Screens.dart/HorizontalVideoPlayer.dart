import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:lit_player/Providers.dart/videoPlayerProvider.dart';
import 'package:lit_player/main.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:video_player/video_player.dart';

class HorizontalVideoPlayer extends StatefulWidget {
  final uri;
  const HorizontalVideoPlayer({Key key, this.uri}) : super(key: key);

  @override
  _HorizontalVideoPlayerState createState() => _HorizontalVideoPlayerState();
}

class _HorizontalVideoPlayerState extends State<HorizontalVideoPlayer>
    with SingleTickerProviderStateMixin {
  VideoPlayerController _controller;
  VideoPlayerProvider _videoPlayerProvider;
  AnimationController _animatedButtonController;
  // bool showOverLay = true;
  @override
  void initState() {
    super.initState();
    _videoPlayerProvider =
        Provider.of<VideoPlayerProvider>(context, listen: false);
    _controller = _videoPlayerProvider.videocontroller;
    _controller.initialize().then((_) => setState(() {}));

    Provider.of<VideoPlayerProvider>(context, listen: false)
            .animatedButtonController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animatedButtonController =
        Provider.of<VideoPlayerProvider>(context, listen: false)
            .animatedButtonController;
  }

  @override
  void didUpdateWidget(covariant HorizontalVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controller.value.isPlaying) _animatedButtonController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controller.value.isPlaying) _animatedButtonController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    AutoOrientation.portraitUpMode();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final videoProvider =
        Provider.of<VideoPlayerProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: () {},
              onTap: () async {
                if (videoProvider.showOverLay) {
                  videoProvider.instantHideOverLay();
                } else {
                  videoProvider.showOverLayFunction();
                }
              },
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                fit: StackFit.expand,
                children: [
                  VideoPlayer(_controller),
                  Selector<VideoPlayerProvider, bool>(
                      selector: (_, changer) => changer.showOverLay,
                      builder: (_, data, child) => Positioned.fill(
                            child: OverLayVideoWidget(
                              showControls: data,
                              isPlaying: _controller.value.isPlaying,
                              videoPlayerController: _controller,
                            ),
                          )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());
    return [duration.inMinutes, duration.inSeconds]
        .map((e) => e.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }
}
