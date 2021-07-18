import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:lit_player/Providers.dart/videoPlayerProvider.dart';
import 'package:lit_player/main.dart';
import 'package:lit_player/utils.dart/OverLayWidget.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:tuple/tuple.dart';
import 'package:video_player/video_player.dart';

class HorizontalVideoPlayer extends StatefulWidget {
  final String uri;
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
    _controller.initialize().then((_) => setState(() {
          _controller.play();

        }));

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
    _videoPlayerProvider.videocontroller.dispose();
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
      backgroundColor: Colors.black87,
      body: Center(
        child: SizedBox(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: GestureDetector(
              onLongPress: () async {
                await Share.shareFiles(
                  [widget.uri],
                );
              },
              onDoubleTap: () {},
              behavior: HitTestBehavior.opaque,
              onDoubleTapDown: (value) => onDoubleTap(value, videoProvider),
              onTap: () async {
                print('----------------');
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

  onDoubleTap(TapDownDetails value, VideoPlayerProvider videoProvider) {
    videoProvider.showOverLayFunction();
    final renderBox = context.findRenderObject() as RenderBox;
    final double limit = renderBox.size.width / 2;
    // final divided = renderBox.size.width / 3;

    print(limit);

    print(value.localPosition.dx);
    if (limit - 20 > value.localPosition.dx) {
      leftInkWellTap();

      videoProvider.setShowLeftfastForwardWidget();
    }
    if (limit + 20 < value.localPosition.dx) {
      videoProvider.setShowRightfastForwardWidget();
      rightInkWellTap();
    }
  }
}

const whiteColor = Colors.white;
const blackColor = Colors.black;
