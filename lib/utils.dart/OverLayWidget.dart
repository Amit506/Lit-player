import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final double currentTime;
  final double time;
  const OverLayVideoWidget({
    Key key,
    this.videoPlayerController,
    this.showControls,
    this.isPlaying,
    this.rightInkWellTap,
    this.leftInkWellTap,
    this.time,
    this.currentTime,
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

  @override
  void didUpdateWidget(covariant OverLayVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(
        "rebuilded----------------------------------------------------------");

    if (Provider.of<VideoPlayerProvider>(context)
            .animatedButtonController
            .isCompleted &&
        !widget.isPlaying) {
      Provider.of<VideoPlayerProvider>(context)
          .animatedButtonController
          .forward();
    }
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
      // print("constraint" +
      //     constraint.maxWidth.toString() +
      //     " " +
      //     constraint.maxHeight.toString());
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
                      child: AnimatedOpacity(
                          duration: Duration(milliseconds: 500),
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
                            videoProvider.animatedButtonController.reverse();
                            await widget.videoPlayerController.pause();
                            videoProvider.hideOverLay();
                          } else {
                            await widget.videoPlayerController.play();
                            videoProvider.animatedButtonController.forward();

                            videoProvider.hideOverLay();
                          }
                        }
                      : null,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    radius: 40,
                    child: AnimatedIcon(
                        color: Colors.white,
                        size: 60,
                        icon: AnimatedIcons.play_pause,
                        progress: videoProvider.animatedButtonController),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getDuration(widget.currentTime) +
                        '/ ${getDuration(widget.time)}',
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(color: Colors.white),
                  ),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        color: Colors.white,
                        iconSize: 20.0,
                        padding: const EdgeInsets.all(0.0),
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
                        color: Colors.white,
                        iconSize: 20.0,
                        padding: const EdgeInsets.all(0.0),
                        icon: Icon(Icons.fullscreen),
                        onPressed: videoProvider.showOverLay
                            ? () {
                                if (videoProvider
                                        .videocontroller.value.aspectRatio >
                                    1.3) {
                                  if (landScapeMode) {
                                    AutoOrientation.portraitUpMode();
                                    SystemChrome.restoreSystemUIOverlays();
                                    landScapeMode = false;
                                  } else {
                                    SystemChrome.setEnabledSystemUIOverlays([]);
                                    AutoOrientation.landscapeAutoMode(
                                        forceSensor: true);
                                    landScapeMode = true;
                                  }
                                }
                              }
                            : null)
                  ]),
                ],
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          iconSize: 20,
                          icon: IconWithShadow(
                            iconData: Icons.open_in_full_rounded,
                          ),
                          onPressed: () {
                            videoProvider.fullSizeAspectratio();
                          }),
                      PopupMenuButton<double>(
                          icon: IconWithShadow(
                            iconData: Icons.more_vert,
                          ),
                          color: Colors.white,
                          initialValue:
                              videoProvider.videocontroller.value.playbackSpeed,
                          tooltip: 'Playback speed',
                          onSelected: (speed) {
                            videoProvider.videocontroller
                                .setPlaybackSpeed(speed);
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
                          }),
                    ],
                  )),
              Padding(
                padding: EdgeInsets.only(bottom: 2.0),
                child: SizedBox(
                  height: 10,
                  child: VideoProgressIndicator(
                    widget.videoPlayerController,
                    allowScrubbing: videoProvider.getIsScrubbing,
                    onPanDown: (value) {
                      videoProvider.controllerWasPlaying =
                          videoProvider.videocontroller.value.isPlaying;

                      videoProvider.setOverLayOnEnd();
                    },
                    onPanEnd: (value) {
                      videoProvider.hideOverLay();
                      videoProvider.setIsScrubbing = false;

                      print(videoProvider.controllerWasPlaying);
                      if (videoProvider.controllerWasPlaying) {
                        videoProvider.videocontroller.play();
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

class IconWithShadow extends StatelessWidget {
  final IconData iconData;
  const IconWithShadow({Key key, @required this.iconData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: 1.2,
          top: 1.2,
          child: Icon(
            iconData,
            color: Colors.black54,
            size: 20,
          ),
        ),
        Icon(
          iconData,
          color: Colors.white,
          size: 20,
        ),
      ],
    );
  }
}
