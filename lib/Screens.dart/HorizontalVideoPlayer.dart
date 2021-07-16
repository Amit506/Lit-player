import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:lit_player/Providers.dart/videoPlayerProvider.dart';
import 'package:lit_player/main.dart';
import 'package:lit_player/utils.dart/OverLayWidget.dart';
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
    if (_controller.value.isInitialized) _controller.play();
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

  void rightInkWellTap() => print('right taped');
  void leftInkWellTap() => print('left taped');

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
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
              onDoubleTapDown: (value) {
                videoProvider.showOverLayFunction();
                final renderBox = context.findRenderObject() as RenderBox;
                double limit = renderBox.size.width;

                if (limit < 80)
                  limit -= 20;
                else
                  limit -= 40;

                if (limit > value.localPosition.dx) {
                  leftInkWellTap();

                  videoProvider.setShowLeftfastForwardWidget();
                }
                if (limit < value.localPosition.dx) {
                  videoProvider.setShowRightfastForwardWidget();
                  rightInkWellTap();
                }
              },
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
                              rightInkWellTap: rightInkWellTap,
                              leftInkWellTap: leftInkWellTap,
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
}

const whiteColor = Colors.white;
const blackColor = Colors.black;
