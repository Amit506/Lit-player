import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:lit_player/Providers.dart/song.dart';
import 'package:lit_player/Theme.dart/appTheme.dart';
import 'package:lit_player/utils.dart/SongPlayerwidget.dart';
import 'package:lit_player/utils.dart/getDuration.dart';

import 'package:media_stores/SongInfo.dart';
import 'package:media_stores/media_stores.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:tuple/tuple.dart';

class MusicPlayerScreen extends StatefulWidget {
  final int index;
  final String uri;
  const MusicPlayerScreen({Key key, this.index, this.uri}) : super(key: key);

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Provider.of<SongPlayer>(context, listen: false).isPlaying) {
      print('---isplaying');
      _animatedButtonController.forward();
    } else if (!Provider.of<SongPlayer>(context, listen: false).isPlaying) {
      _animatedButtonController.reverse();
    }
  }
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     if (Provider.of<SongPlayer>(context, listen: false).isPlaying) {
  //       print('---isplaying');
  //       _animatedButtonController.forward();
  //     } else if (!Provider.of<SongPlayer>(context, listen: false).isPlaying) {
  //       _animatedButtonController.reverse();
  //     }
  //   }
  // }

  @override
  void dispose() {
    _animatedButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffold,
      body: Selector<SongPlayer, LinearGradient>(
        selector: (_, s) => s.getGradientBackground,
        builder: (context, value, child) {
          print("builder music screeb--");
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
                        onPressed: () => showMusicBottomSheet())
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
                    valueChanged: (_isFavorite) {},
                  ),
                  Selector<SongPlayer, bool>(
                      selector: (_, foo) => foo.isShuffleEnabled,
                      builder: (_, data, __) {
                        return AnimatedSwitcher(
                            duration: Duration(milliseconds: 500),
                            child: songPlayer.shuffleWidget(data, () {
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

  showMusicBottomSheet() {
    _scaffold.currentState.showBottomSheet((context) => ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: Icon(Icons.music_note),
              title: Text(songPlayer.getLatestSongInfo.title),
            ),
            ListTile(
              leading: Icon(Icons.lock_clock),
              onTap: () {
                double timeSliderValue = 0.0;
                _scaffold.currentState.showBottomSheet((context) =>
                    StatefulBuilder(
                      builder: (context, state) => Container(
                        height: 200,
                        width: double.infinity,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                timeSliderValue == 0.0
                                    ? Text(
                                        'Sleep Timer off',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      )
                                    : RichText(
                                        text: TextSpan(children: [
                                        TextSpan(
                                          text: 'Stop audio in ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        ),
                                        TextSpan(
                                          text: '${timeSliderValue.round()}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(color: darkBlueColor),
                                        ),
                                        TextSpan(
                                          text: ' min',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        )
                                      ])),
                                Column(
                                  children: [
                                    SliderTheme(
                                      data: SliderThemeData(
                                          overlayShape: RoundSliderOverlayShape(
                                              overlayRadius: 2.0),
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 8.0,
                                              disabledThumbRadius: 8.0),
                                          activeTrackColor: darkBlueColor,
                                          trackHeight: 4.0,
                                          thumbColor: darkBlueColor),
                                      child: Slider(
                                          max: 90.0,
                                          min: 0.0,
                                          value: timeSliderValue,
                                          onChanged: (value) {
                                            state(() {
                                              timeSliderValue = value;
                                              songPlayer
                                                  .setSleepTimer(value.round());
                                            });
                                          }),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: audioTimers
                                          .map((e) => Text(
                                                e,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption,
                                              ))
                                          .toList(),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ));
              },
              title: Text('Set Sleep Timer'),
            ),
            ListTile(
              leading: Icon(Icons.share),
              onTap: () async {
                final filePath =
                    await MediaStores.getPath(songPlayer.getLatestSongInfo.uri);
                await Share.shareFiles(
                  [filePath],
                );
              },
              title: Text('Share'),
            ),
          ],
        ));
  }

  final List<String> audioTimers = ['off', '30 min', '60 min', '90 min'];

  onChangingLoopMode(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        {
          songPlayer.loopOn();
        }
        break;
      case LoopMode.one:
        {
          songPlayer.loopOff();
        }
        break;
      case LoopMode.all:
        {
          songPlayer.loopOnlyOne();
        }
        break;
    }
  }
}
