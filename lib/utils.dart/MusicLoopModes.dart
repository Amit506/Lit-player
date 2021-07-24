import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicLoopModeWidget extends StatelessWidget {
  final LoopMode loopMode;
  final bool isRepeatMode;
  final VoidCallback onChange;
  const MusicLoopModeWidget(
      {Key key, this.loopMode, this.isRepeatMode, this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget loopWidget;
    switch (loopMode) {
      case LoopMode.off:
        loopWidget = IconButton(
            iconSize: 20,
            color: Colors.grey[100],
            icon: Icon(Icons.loop),
            onPressed: onChange);
        break;
      case LoopMode.one:
        loopWidget = IconButton(
            iconSize: 20, icon: Icon(Icons.repeat), onPressed: onChange);
        break;
      case LoopMode.all:
        loopWidget = IconButton(
            iconSize: 20, icon: Icon(Icons.loop), onPressed: onChange);

        break;
    }
    return loopWidget;
  }
}

class MusiocShuffleWidget extends StatelessWidget {
  final bool isShuffling;
  final VoidCallback onShuffle;
  const MusiocShuffleWidget({Key key, this.isShuffling, this.onShuffle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isShuffling) {
      return IconButton(
        iconSize: 20,
        icon: Icon(
          Icons.shuffle,
        ),
        onPressed: onShuffle,
      );
    } else {
      return IconButton(
        iconSize: 20,
        color: Colors.grey[200],
        icon: Icon(Icons.shuffle),
        onPressed: onShuffle,
      );
    }
  }
}
