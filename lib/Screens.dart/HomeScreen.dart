import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:lit_player/A/music_visualizer.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:lit_player/Providers.dart/song.dart';
import 'package:lit_player/Screens.dart/VideoScreen.dart';
import 'package:lit_player/Theme.dart/appTheme.dart';
import 'package:lit_player/utils.dart/VideoListAvatar.dart';
import 'package:lit_player/utils.dart/bottoSongWidget.dart';

import 'package:media_stores/SongInfo.dart';

import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController _animatedButtonController;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    initiating();

    _animatedButtonController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        {
          if (Provider.of<SongPlayer>(context, listen: false).isPlaying) {
            print('---isplaying');
            _animatedButtonController.forward();
          } else if (!Provider.of<SongPlayer>(context, listen: false)
              .isPlaying) {
            _animatedButtonController.reverse();
          }
          AudioService.connect();
        }
        break;
      case AppLifecycleState.paused:
        AudioService.disconnect();
        break;
      default:
        break;
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

  @override
  Future<bool> didPopRoute() async {
    AudioService.disconnect();
    return false;
  }

  @override
  void dispose() {
    AudioService.disconnect();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool onlyOneDrag = true;

  @override
  Widget build(BuildContext context) {
    print('rebuild------------------------');
    final size = MediaQuery.of(context).size;
    final songPlayer = Provider.of<SongPlayer>(context, listen: false);
    // final songService = Provider.of<SongsService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.nightlight_round),
              onPressed: () =>
                  Provider.of<AppTheme>(context, listen: false).changeTheme()),
          IconButton(
              icon: Icon(Icons.video_collection_rounded),
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
      body: SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(
            children: [
              Consumer<SongsService>(builder: (context, value, child) {
                print(
                    "called...........................................................");
                if (value.songShowList != null &&
                    value.songShowList.length == 0) {
                  return Center(
                    child: Text('No songs available in device'),
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
                          trailing: Selector<SongPlayer, SongInfo>(
                            child: SizedBox(
                              height: 20,
                              width: 30,
                              // child: VisualizerWidget()
                            ),
                            selector: (_, s) => s.latestSongInfo,
                            builder: (context, value, child) {
                              if (value == songs[i]) {
                                return child;
                              } else {
                                return SizedBox();
                              }
                            },
                          ),
                          subtitle: Text(songs[i].artist),
                          onTap: () async {
                            songPlayer.playerSetAudioSoucres(
                                Provider.of<SongsService>(context,
                                        listen: false)
                                    .allPlaysListAvailable,
                                initialIndex: i);
                            songPlayer.play();
                            _animatedButtonController.forward();
                          },
                          leading: FittedBox(
                            fit: BoxFit.cover,
                            child: Selector<SongsService, List<SongInfo>>(
                                selector: (_, changer) => changer.songShowList,
                                builder: (_, data, child) {
                                  Widget animatedSwitcherChild = data[i]
                                              .imageBit !=
                                          null
                                      ? AlbumArtAvatar(image: data[i].imageBit)
                                      : Tempavatar();
                                  return AnimatedSwitcher(
                                      duration: Duration(milliseconds: 500),
                                      child: animatedSwitcherChild);
                                }),
                          ),
                          title: Text(songs[i].title),
                        );
                      },
                    ),
                  );
                }
              }),
              // Positioned(
              //   top: size.height / 2,
              //   right: 0.0,
              //   child: Transform.rotate(
              //     angle: -pi / 2,
              //     alignment: Alignment.centerRight,
              //     child: ClipPath(
              //         clipper: CustomHalfCircleClipper(),
              //         child: CircleAvatar(
              //           radius: 30,
              //         )),
              //   ),
              // ),

              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
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
                ),
              ),
            ],
          )),
    );
  }

  void initiating() async {
    AudioService.connect();
    Provider.of<SongPlayer>(context, listen: false)
      ..indexesStream()
      ..sequenceStateChange()
      ..listenStream()
      ..initiatingBackGroundTask()
      ..playerState();
  }
}

// class CustomHalfCircleClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final Path path = new Path();
//     path.lineTo(0.0, size.height / 2);
//     path.lineTo(size.width, size.height / 2);
//     path.lineTo(size.width, 0);
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) {
//     return true;
//   }
// }
