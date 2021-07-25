import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lit_player/A/Animations.dart';
import 'package:lit_player/A/HeromusicScreen.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:lit_player/Screens.dart/MusicPlayerScreen.dart';
import 'package:lit_player/utils.dart/SlideBottomWidget.dart';
import 'package:lit_player/utils.dart/albumimageWidgte.dart';
import 'package:media_stores/SongInfo.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tuple/tuple.dart';

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

    return Material(
      elevation: 1.0,
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
                    thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 3.0, disabledThumbRadius: 3.0),
                    trackHeight: 3.0,
                    trackShape: RectangularSliderTrackShape()),
                child: Selector<SongPlayer, Tuple3<double, double, double>>(
                    selector: (_, foo) =>
                        Tuple3(foo.sliderMin, foo.sliderMax, foo.sliderCurrent),
                    builder: (_, data, __) {
                      return Slider(
                          min: data.item1,
                          max: data.item2,
                          value: data.item3,
                          onChanged: songPlayer.sliderValueChanged);
                    }),
              ),
            ),
          ),
          SizedBox(
            height: 78,
            width: size.width,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: size.width * 0.2,
                  height: double.infinity,
                  child: FittedBox(
                    clipBehavior: Clip.antiAlias,
                    fit: BoxFit.cover,
                    child: Hero(
                      flightShuttleBuilder: (
                        BuildContext flightContext,
                        Animation<double> animation,
                        HeroFlightDirection flightDirection,
                        BuildContext fromHeroContext,
                        BuildContext toHeroContext,
                      ) {
                        final Hero toHero = toHeroContext.widget;

                        return RotationTransition(
                          turns: animation,
                          child: toHero.child,
                        );
                      },
                      tag: "a",
                      child: Selector<SongPlayer, Uint8List>(
                        selector: (_, changer) => changer.getImageByte,
                        builder: (_, data, child) => AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: AlbumImageWidget(
                            memeoryImage: data,
                            // initial: true,
                          ),
                        ),
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
                              child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300],
                                  highlightColor: Colors.grey[100],
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 10.0,
                                        width: double.infinity,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        height: 10.0,
                                        width: double.infinity,
                                        color: Colors.white,
                                      )
                                    ],
                                  )),
                              selector: (_, changer) =>
                                  changer.getLatestSongInfo,
                              builder: (_, data, child) => SlideBottomWidget(
                                  child: SmallTextPlayerWidget(
                                showShimmer: data == null ? true : false,
                                title: data?.title,
                                artist: data?.artist,
                                key: ValueKey(data.hashCode),
                                child: child,
                              )),
                            ),
                          ),
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
