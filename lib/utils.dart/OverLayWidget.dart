import 'dart:math';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:lit_player/Providers.dart/VideoService.dart';
import 'package:lit_player/Providers.dart/videoPlayerProvider.dart';
import 'package:lit_player/utils.dart/getDuration.dart';
import 'package:lit_player/utils.dart/ForwardWidget.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:video_player/video_player.dart';

class OverLayVideoWidget extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool isPlaying;
  final bool showControls;
  final VoidCallback rightInkWellTap;
  final VoidCallback leftInkWellTap;
  const OverLayVideoWidget({
    Key key,
    this.videoPlayerController,
    this.showControls,
    this.isPlaying,
    this.rightInkWellTap,
    this.leftInkWellTap,
  }) : super(key: key);

  @override
  _OverLayVideoWidgetState createState() => _OverLayVideoWidgetState();
}

class _OverLayVideoWidgetState extends State<OverLayVideoWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // _animatedButtonController =
    //     AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   print("olllllllllllllllllllllllllllllddddddddddddddddddddddddddddddddwwww");
  // }

  @override
  void didUpdateWidget(covariant OverLayVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("ollllllllllllllllllllllllllllldddddddddddddddddddddddddddddddd");
    // if (widget.videoPlayerController.value. != oldWidget.videoPlayerController.value.position) {
    //   _animatedButtonController.reverse();
    // } else {
    //   _animatedButtonController.forward();
    // }
  }

  static const _playBackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
  ];
  bool landScapeMode = false;
  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoPlayerProvider>(context);
    return LayoutBuilder(builder: (_, constraint) {
      print("constraint" +
          constraint.maxWidth.toString() +
          " " +
          constraint.maxHeight.toString());
      return AnimatedOpacity(
        opacity: widget.showControls ? 1.0 : 0.0,
        duration: Duration(seconds: 1),
        child: SizedBox(
          height: constraint.maxHeight,
          width: constraint.maxWidth,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Row(
                children: [
                  Selector<VideoPlayerProvider, Tuple2<bool, int>>(
                    selector: (_, changer) => Tuple2(
                        changer.showLeftFastWordWidget, changer.initialForward),
                    builder: (_, data, child) => Flexible(
                      child: Opacity(
                          opacity: data.item1 ? 1.0 : 0.0,
                          child: LeftForwardWidget(
                            seeked: data.item2,
                            leftInkWellTap: widget.leftInkWellTap,
                            height: constraint.maxHeight,
                          )),
                    ),
                  ),
                  Spacer(),
                  Selector<VideoPlayerProvider, Tuple2<bool, int>>(
                    selector: (_, changer) => Tuple2(
                        changer.showRightFastWordWidget,
                        changer.initialForward),
                    builder: (_, data, child) => Flexible(
                      child: AnimatedOpacity(
                          duration: Duration(milliseconds: 500),
                          opacity: data.item1 ? 1.0 : 0.0,
                          child: RightForwardWidget(
                            seeked: data.item2,
                            height: constraint.maxHeight,
                            rightInkWellTap: widget.rightInkWellTap,
                          )),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: constraint.maxHeight / 2 - 40,
                left: constraint.maxWidth / 2 - 40,
                child: GestureDetector(
                  onTap: videoProvider.showOverLay
                      ? () async {
                          if (widget.videoPlayerController.value.isPlaying) {
                            videoProvider.animatedButtonController.forward();
                            await widget.videoPlayerController.pause();
                            videoProvider.hideOverLay();
                          } else {
                            await widget.videoPlayerController.play();
                            videoProvider.animatedButtonController.reverse();
                            videoProvider.hideOverLay();
                          }
                        }
                      : null,
                  child: AnimatedIcon(
                      size: 60,
                      icon: AnimatedIcons.pause_play,
                      progress: videoProvider.animatedButtonController),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getDuration(widget
                          .videoPlayerController.value.position.inMilliseconds
                          .toDouble()) +
                      '/ ${getDuration(widget.videoPlayerController.value.duration.inMilliseconds.toDouble())}'),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        icon: Icon(
                            videoProvider.videocontroller.value.volume == 0.0
                                ? Icons.volume_off
                                : Icons.volume_up),
                        onPressed: () {
                          if (videoProvider.videocontroller.value.volume == 0.0)
                            videoProvider.videocontroller.setVolume(1.0);
                          else
                            videoProvider.videocontroller.setVolume(0.0);
                        }),
                    IconButton(
                        icon: Icon(Icons.fullscreen),
                        onPressed: videoProvider.showOverLay
                            ? () {
                                if (landScapeMode) {
                                  AutoOrientation.portraitUpMode();
                                  landScapeMode = false;
                                } else {
                                  AutoOrientation.landscapeAutoMode();
                                  landScapeMode = true;
                                }
                              }
                            : null)
                  ]),
                ],
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: PopupMenuButton<double>(
                      initialValue:
                          videoProvider.videocontroller.value.playbackSpeed,
                      tooltip: 'Playback speed',
                      onSelected: (speed) {
                        videoProvider.videocontroller.setPlaybackSpeed(speed);
                      },
                      itemBuilder: (context) {
                        return [
                          for (final speed in _playBackRates)
                            PopupMenuItem(
                              height: 25,
                              value: speed,
                              child: Text('${speed}x'),
                            )
                        ];
                      })),
              Padding(
                padding: EdgeInsets.only(bottom: 2.0),
                child: VideoProgressIndicator(widget.videoPlayerController,
                    allowScrubbing: true),
              )
            ],
          ),
        ),
      );
    });
  }
}
