import 'package:flutter/material.dart';
import 'package:lit_player/A/Animations.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:lit_player/Screens.dart/MusicPlayerScreen.dart';
import 'package:media_stores/SongInfo.dart';
import 'package:provider/provider.dart';
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
    if (songPlayer.isPlaying) {
      _animatedButtonController.forward();
    } else {
      _animatedButtonController.reverse();
    }
    return Material(
      color: Theme.of(context).primaryColor,
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
                              enabledThumbRadius: 3.0,
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
                      selector: (_, changer) => changer.getCurrentWidget,
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
                                      data, size, context),
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
