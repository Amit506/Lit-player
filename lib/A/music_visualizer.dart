import 'package:flutter/material.dart';
import 'package:lit_player/Theme.dart/appTheme.dart';

class MusicVisualizer extends StatefulWidget {
  final Color colors;
  final int duration;
  final int end;
  const MusicVisualizer({Key key, this.colors, this.duration, this.end})
      : super(key: key);

  @override
  _MusicVisualizerState createState() => _MusicVisualizerState();
}

class _MusicVisualizerState extends State<MusicVisualizer>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController animationController;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.duration));
    final curvedAnimation = CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInCubic,
        reverseCurve: Curves.easeInCirc);
    animation = Tween<double>(begin: 0, end: widget.end.toDouble())
        .animate(curvedAnimation)
          ..addListener(() {
            setState(() {});
          });
    animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 2,
      height: animation.value,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.colors,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

class VisualizerWidget extends StatelessWidget {
  const VisualizerWidget({Key key}) : super(key: key);
  static List<Color> colors = <Color>[
    Colors.greenAccent,
    Colors.deepOrangeAccent,
    Colors.greenAccent,
    Colors.deepOrangeAccent,
  ];
  static List<int> duration = <int>[350, 720, 750, 500];
  static List<int> end = <int>[30, 100, 30, 100];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
            4,
            (index) => MusicVisualizer(
                  duration: duration[index],
                  end: end[index],
                  colors: colors[index],
                )),
      ),
    );
  }
}
