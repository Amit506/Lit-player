import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_visualizers/Visualizers/LineVisualizer.dart';
import 'package:flutter_visualizers/visualizer.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:lit_player/Providers.dart/song.dart';
// import 'package:lit_player/Tuple.dart';
import 'package:marquee/marquee.dart';
import 'package:media_stores/SongInfo.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class MusicPlayerScreen extends StatefulWidget {
  final int index;
  final String uri;
  const MusicPlayerScreen({Key key, this.index, this.uri}) : super(key: key);

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animatedButtonController;
  SongPlayer songPlayer;
  @override
  void initState() {
    super.initState();
    songPlayer = Provider.of<SongPlayer>(context, listen: false);
    _animatedButtonController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    if (songPlayer.isPlaying) {
      _animatedButtonController.forward();
    }
    initialPlay();
  }

  initialPlay() async {
    if (widget.uri != null) {
      await songPlayer.setMusicUri(widget.uri).then((value) {
        songPlayer.playInit();
        songPlayer.listenStream();
        songPlayer.playerSetAudioSoucres(
            Provider.of<SongsService>(context, listen: false)
                .allPlaysListAvailable,
            initialIndex: widget.index);
      });
    }
  }

  @override
  void dispose() {
    _animatedButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Selector<SongPlayer, LinearGradient>(
        selector: (_, s) => s.getGradientBackground,
        builder: (context, value, child) {
          return DecoratedBox(
              decoration: BoxDecoration(
                gradient: value ?? null,
              ),
              child: child);
        },
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              SizedBox(
                width: size.width,
                height: 50,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Selector<SongPlayer, SongInfo>(
                        selector: (_, changer) => changer.getLatestSongInfo,
                        builder: (_, data, child) => AnimatedSwitcher(
                          transitionBuilder: (child, animation) {
                            final offsetAnimation = Tween<Offset>(
                                    begin: Offset(1.0, 0.0), end: Offset.zero)
                                .animate(animation);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                          layoutBuilder: (Widget currentChild,
                              List<Widget> previousChildren) {
                            return currentChild;
                          },
                          duration: Duration(milliseconds: 500),
                          child: songPlayer.bigPlayerTextWidget(data, size),
                        ),
                      ),
                    ),
                    IconButton(
                        color: Colors.white,
                        icon: Icon(
                          Icons.more_vert_outlined,
                          color: Colors.white,
                        ),
                        onPressed: null)
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Hero(
                tag: "a",
                child: SizedBox(
                  width: size.width * 0.8,
                  height: size.height * 0.5,
                  child: Selector<SongPlayer, Widget>(
                    selector: (_, changer) => changer.getCurrentWidget,
                    builder: (_, data, child) => FittedBox(
                      fit: BoxFit.contain,
                      child: AnimatedSwitcher(
                        transitionBuilder: (child, animation) {
                          final offsetAnimation = Tween<Offset>(
                                  begin: Offset(1.0, 0.0), end: Offset.zero)
                              .animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offsetAnimation,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: child),
                            ),
                          );
                        },
                        duration: Duration(milliseconds: 500),
                        child: data,
                      ),
                    ),
                  ),
                ),
              ),
              Selector<SongPlayer, Tuple4<double, double, double, Color>>(
                  selector: (_, foo) => Tuple4(foo.sliderMin, foo.sliderMax,
                      foo.sliderCurrent, foo.playButtonColor),
                  builder: (_, data, __) {
                    return Slider(
                        activeColor: data.item4,
                        inactiveColor: Colors.white,
                        min: data.item1,
                        max: data.item2,
                        value: data.item3,
                        onChanged: songPlayer.sliderValueChanged);
                  }),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Selector<SongPlayer, double>(
                        selector: (_, foo) => foo.sliderCurrent,
                        builder: (_, data, __) {
                          return Text(getDuration(data));
                        }),
                    Selector<SongPlayer, double>(
                        selector: (_, foo) => foo.sliderMax,
                        builder: (_, data, __) {
                          return Text(getDuration(data));
                        }),
                  ],
                ),
              ),
              Selector<SongPlayer, Color>(
                selector: (_, changer) => changer.getPlayButtonColor,
                builder: (context, value, child) {
                  return Flexible(
                    child: SongPlayerWidget(
                        color: value,
                        play: () {
                          songPlayer
                              .playButtonAnimation(_animatedButtonController);
                        },
                        next: () {
                          songPlayer.playNext();
                          print(songPlayer.hasNext.toString());
                        },
                        previous: () {
                          songPlayer.playPrevious();
                        },
                        animatedButtonController: _animatedButtonController),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Selector<SongPlayer, LoopMode>(
                      selector: (_, foo) => foo.getLoopMode,
                      builder: (_, data, __) {
                        return AnimatedSwitcher(
                            duration: Duration(milliseconds: 500),
                            child: songPlayer.loopWidgets(() {
                              onChangingLoopMode(data);
                            }, data));
                      }),
                  FavoriteButton(
                    iconSize: 38,
                    valueChanged: (_isFavorite) {
                      print('Is Favorite $_isFavorite)');
                    },
                  ),
                  Selector<SongPlayer, bool>(
                      selector: (_, foo) => foo.isShuffleEnabled,
                      builder: (_, data, __) {
                        return AnimatedSwitcher(
                            duration: Duration(milliseconds: 500),
                            child: songPlayer.shuffleWidget(data, () {
                              // songPlayer.setIsFirstTimeStarted = true;
                              if (data) {
                                songPlayer.shuffleOf();
                              } else {
                                songPlayer.shuffleOn();
                              }
                            }));
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  onChangingLoopMode(LoopMode mode) {
    // songPlayer.setIsFirstTimeStarted = true;

    switch (mode) {
      case LoopMode.off:
        {
          print('ooooooo----');
          songPlayer.loopOn();
          // songPlayer.setPreviousLoopMode = LoopMode.off;
        }
        break;
      case LoopMode.one:
        {
          songPlayer.loopOff();
          // songPlayer.setPreviousLoopMode = LoopMode.one;
        }
        break;
      case LoopMode.all:
        {
          songPlayer.loopOnlyOne();
          // songPlayer.setPreviousLoopMode = LoopMode.all;
        }
        break;
    }
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());
    return [duration.inMinutes, duration.inSeconds]
        .map((e) => e.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }
}

class SongPlayerWidget extends StatelessWidget {
  const SongPlayerWidget(
      {Key key,
      @required AnimationController animatedButtonController,
      this.play,
      this.next,
      this.color,
      this.previous})
      : _animatedButtonController = animatedButtonController,
        super(key: key);

  final AnimationController _animatedButtonController;
  final VoidCallback play;
  final VoidCallback next;
  final VoidCallback previous;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
            iconSize: 50,
            icon: Icon(Icons.skip_previous_rounded),
            onPressed: previous),
        GestureDetector(
          onTap: play,
          child: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Center(
              child: AnimatedIcon(
                  size: 50,
                  icon: AnimatedIcons.play_pause,
                  progress: _animatedButtonController),
            ),
          ),
        ),
        IconButton(
            iconSize: 50, icon: Icon(Icons.skip_next_rounded), onPressed: next),
      ],
    );
  }
}
