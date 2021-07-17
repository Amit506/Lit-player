import 'package:flutter/material.dart';

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
