import 'package:flutter/material.dart';

class MusicVisualizer extends StatefulWidget {
  final Color colors;
  final int duration;
  const MusicVisualizer({Key key, this.colors, this.duration})
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
    animation = Tween<double>(begin: 0, end: 100).animate(curvedAnimation)
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
    return Container(
      width: 2,
      decoration: BoxDecoration(
        color: widget.colors,
        borderRadius: BorderRadius.circular(5),
      ),
      height: animation.value,
    );
  }
}

class VisualizerWidget extends StatelessWidget {
  const VisualizerWidget({Key key}) : super(key: key);
  static List<Color> colors = <Color>[
    Colors.black,
    Colors.green,
    Colors.black,
    Colors.green
  ];
  static List<int> duration = <int>[300, 580, 640, 820];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
            4,
            (index) => MusicVisualizer(
                  duration: duration[index],
                  colors: colors[index],
                )),
      ),
    );
  }
}
