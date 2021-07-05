import 'dart:async';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:lit_player/Animations.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:lit_player/Providers.dart/song.dart';
import 'package:lit_player/Screens.dart/MusicPlayerScreen.dart';
import 'package:lit_player/Screens.dart/VideoScreen.dart';
import 'package:lit_player/utils.dart/ListAvatar.dart';
import 'package:marquee/marquee.dart';
import 'package:media_store/SongInfo.dart';
import 'package:media_store/media_store.dart';
import 'package:provider/provider.dart';

import '../Tuple.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animatedButtonController;
  @override
  void initState() {
    super.initState();
    initiating();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initAudioService();
    });

    _animatedButtonController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  bool onlyOneDrag = true;

  @override
  Widget build(BuildContext context) {
    print('rebuild------------------------');
    final size = MediaQuery.of(context).size;
    final songPlayer = Provider.of<SongPlayer>(context, listen: false);
    final songService = Provider.of<SongsService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.near_me),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => VideoListScreen()));
              })
        ],
        leading: Hero(
          tag: 'appIcon',
          child: Image.asset(
              'assets/f8a7b6e4-6564-4094-b027-357b0dcef705_200x200.png'),
        ),
        title: Text(
          'Lit player',
          style: TextStyle(
              letterSpacing: 2,
              wordSpacing: 5,
              fontFamily: 'serif',
              fontWeight: FontWeight.w800),
        ),
      ),
      body: Container(
          height: size.height,
          width: size.width,
          child: Stack(
            children: [
              Consumer<SongsService>(builder: (context, value, child) {
                if (value.songShowList != null &&
                    value.songShowList.length == 0) {
                  return Center(
                    child: Text('no songs available in device'),
                  );
                } else {
                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels ==
                          notification.metrics.maxScrollExtent) {
                        value.updateSongShowList(value.songShowList.length,
                            value.songShowList.length + 30);
                      }
                      return true;
                    },
                    child: ListView.separated(
                      separatorBuilder: (context, i) {
                        return Divider(
                          indent: 60,
                        );
                      },
                      itemCount: value.songShowList.length,
                      itemBuilder: (_, i) {
                        final songs = value.songShowList;
                        return ListTile(
                          onTap: () async {
                            songPlayer.playerSetAudioSoucres(
                                Provider.of<SongsService>(context,
                                        listen: false)
                                    .allPlaysListAvailable,
                                initialIndex: i);
                            songPlayer.play();
                            _animatedButtonController.forward();
                          },
                          leading: ValueListenableBuilder<List<Uint8List>>(
                            valueListenable: value.songThumbnails,
                            builder: (context, values, child) {
                              Widget animatedSwitcherChild = values[i] != null
                                  ? AlbumArtAvatar(image: values[i])
                                  : Tempavatar();
                              return AnimatedSwitcher(
                                  child: animatedSwitcherChild,
                                  duration: Duration(seconds: 1));
                            },
                          ),
                          title: Text(songs[i].title),
                        );
                      },
                    ),
                  );
                }
              }),
              AnimatedPositioned(
                duration: Duration(seconds: 1),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      child: BottomSongWidget(
                        onPanUpdate: (value) {
                          final direction = value.velocity.pixelsPerSecond.dx;
                          if (direction > 0) {
                            songPlayer.playNext();
                          } else {
                            songPlayer.playPrevious();
                          }
                        },
                        size: size,
                        animatedButtonController: _animatedButtonController,
                      ),
                      height: 80,
                      width: size.width,
                      color: Colors.white),
                ),
              ),
            ],
          )),
    );
  }

  gotToMusicScreen() async {}

  void initiating() async {
    Provider.of<SongPlayer>(context, listen: false).setCurrentPlayList =
        Provider.of<SongsService>(context, listen: false).allPlaysListAvailable;
    await Provider.of<SongPlayer>(context, listen: false).playerSetAudioSoucres(
      Provider.of<SongsService>(context, listen: false).allPlaysListAvailable,
    );
    Provider.of<SongPlayer>(context, listen: false).setLatestSongInfo =
        Provider.of<SongsService>(context, listen: false)
            .allPlaysListAvailable[0];
    print(Provider.of<SongPlayer>(context, listen: false)
        .getLatestSongInfo
        .toString());
    Provider.of<SongPlayer>(context, listen: false).indexesStream();
    Provider.of<SongPlayer>(context, listen: false).sequenceStateChange();
    Provider.of<SongPlayer>(context, listen: false).listenStream();
    // Provider.of<SongPlayer>(context, listen: false).convertToMediaItems();
    // Provider.of<SongPlayer>(context, listen: false).initiatingBackGroundTask();
  }

  void initAudioService() async {}
}

class BottomSongWidget extends StatelessWidget {
  const BottomSongWidget({
    Key key,
    @required AnimationController animatedButtonController,
    @required this.size,
    @required this.onPanUpdate,
  })  : _animatedButtonController = animatedButtonController,
        super(key: key);
  final AnimationController _animatedButtonController;
  final Size size;
  final Function(DragEndDetails) onPanUpdate;

  @override
  Widget build(BuildContext context) {
    final songPlayer = Provider.of<SongPlayer>(context, listen: false);
    if (songPlayer.isPlaying) {
      _animatedButtonController.forward();
    } else {
      _animatedButtonController.reverse();
    }
    print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr');
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: Selector<SongPlayer, Tuple3<double, double, double>>(
                selector: (_, foo) =>
                    Tuple3(foo.sliderMin, foo.sliderMax, foo.sliderCurrent),
                builder: (_, data, __) {
                  return Align(
                    alignment: Alignment.bottomLeft,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 0.0),
                          thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 4.0,
                              disabledThumbRadius: 3.0),
                          trackHeight: 3.0,
                          trackShape: RectangularSliderTrackShape()),
                      child: Slider(
                          min: data.item1,
                          max: data.item2,
                          value: data.item3,
                          onChanged: songPlayer.sliderValueChanged),
                    ),
                  );
                }),
          ),
          SizedBox(
            height: 78,
            width: size.width,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: size.width * 0.2,
                  child: Hero(
                    tag: "a",
                    child: Selector<SongPlayer, Widget>(
                      selector: (_, changer) => changer.currentWidget,
                      builder: (_, data, child) => AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: data,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: size.width * 0.6,
                          child: GestureDetector(
                              onTap: () {
                                // songPlayer.play();
                                Navigator.push(
                                    context,
                                    HeroMusicOpenScreen(
                                        page: MusicPlayerScreen()));
                              },
                              onHorizontalDragEnd: onPanUpdate,
                              child: Selector<SongPlayer, SongInfo>(
                                selector: (_, changer) =>
                                    changer.getLatestSongInfo,
                                builder: (_, data, child) => AnimatedSwitcher(
                                  transitionBuilder: (child, animation) {
                                    final offsetAnimation = Tween<Offset>(
                                            begin: Offset(1.0, 0.0),
                                            end: Offset.zero)
                                        .animate(animation);
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  layoutBuilder: (Widget currentChild,
                                      List<Widget> previousChildren) {
                                    return currentChild;
                                  },
                                  duration: Duration(milliseconds: 500),
                                  child: songPlayer.smallPlayerTextWidget(
                                      data, size),
                                ),
                              )),
                        ),
                      ),
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            songPlayer
                                .playButtonAnimation(_animatedButtonController);
                          },
                          child: AnimatedIcon(
                              size: 50,
                              icon: AnimatedIcons.play_pause,
                              progress: _animatedButtonController),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
