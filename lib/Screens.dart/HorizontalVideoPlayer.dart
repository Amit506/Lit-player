import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:lit_player/Providers.dart/videoPlayerProvider.dart';
import 'package:lit_player/main.dart';
import 'package:lit_player/utils.dart/OverLayWidget.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

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
  // double aspectRatio;
  @override
  void initState() {
    super.initState();
    _videoPlayerProvider =
        Provider.of<VideoPlayerProvider>(context, listen: false);
    Provider.of<VideoPlayerProvider>(context, listen: false)
            .animatedButtonController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _controller = _videoPlayerProvider.videocontroller;
    _animatedButtonController =
        Provider.of<VideoPlayerProvider>(context, listen: false)
            .animatedButtonController;
    _controller.initialize().then(
          (_) => setState(
            () {
              _videoPlayerProvider.aspectratio =
                  _videoPlayerProvider.videocontroller.value.aspectRatio;
              _controller.play();
              _animatedButtonController.forward();
              Provider.of<VideoPlayerProvider>(context, listen: false)
                  .hideOverLay();
            },
          ),
        );
  }

  @override
  void didUpdateWidget(covariant HorizontalVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controller.value.isPlaying) _animatedButtonController.reverse();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controller.value.isPlaying) _animatedButtonController.reverse();
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerProvider.videocontroller.dispose();
    _videoPlayerProvider.animatedButtonController.dispose();
    AutoOrientation.portraitUpMode();
  }

  void rightInkWellTap() => print('right taped');
  void leftInkWellTap() => print('left taped');

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final videoProvider =
        Provider.of<VideoPlayerProvider>(context, listen: false);
    videoProvider.screenSizeAspectioRatio = size.aspectRatio;
    final screen = Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: SizedBox(
          child: AspectRatio(
            aspectRatio: Provider.of<VideoPlayerProvider>(context).aspectratio,
            child: GestureDetector(
              onLongPress: () async {
                await Share.shareFiles(
                  [widget.uri],
                );
              },
              // onScaleUpdate: (scale) {
              //   print("---------------------");
              //   print(scale);
              //   // final renderBox = context.findRenderObject() as RenderBox;
              //   // final height = renderBox.size.height + scale.verticalScale;
              //   // final width = renderBox.size.height + scale.horizontalScale;
              //   // aspectRatio = height / width;
              //   // if (aspectRatio > _controller.value.aspectRatio &&
              //   //     aspectRatio <= size.height / size.width) {
              //   //   setState(() {
              //   //     aspectRatio = height / width;
              //   //   });
              //   // }
              // },
              onScaleEnd: (scaleEnd) {},
              onDoubleTap: () {},
              behavior: HitTestBehavior.opaque,
              onDoubleTapDown: (value) => onDoubleTap(value, videoProvider),
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
                        currentTime: Provider.of<VideoPlayerProvider>(context)
                            .sliderCurrent,
                        time: Provider.of<VideoPlayerProvider>(context,
                                listen: false)
                            .sliderMax,
                        rightInkWellTap: rightInkWellTap,
                        leftInkWellTap: leftInkWellTap,
                        showControls: data,
                        isPlaying: _controller.value.isPlaying,
                        videoPlayerController: _controller,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // if (videoProvider.videocontroller.value.isInitialized) {
    return screen;
    // } else {

    //   Navigator.pop(context);
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(SnackBar(content: Text('Something went wrong')));
    // }
  }

  onDoubleTap(TapDownDetails value, VideoPlayerProvider videoProvider) {
    videoProvider.showOverLayFunction();
    final renderBox = context.findRenderObject() as RenderBox;
    final double limit = renderBox.size.width / 2;
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
