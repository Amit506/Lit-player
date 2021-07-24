import 'package:flutter/material.dart';

class VideoButtonBoxDecoration extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool isLightTheme;
  const VideoButtonBoxDecoration({
    Key key,
    this.child,
    this.padding = const EdgeInsets.all(2.0),
    this.isLightTheme = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: DecoratedBox(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: isLightTheme
                ? Colors.black.withOpacity(0.4)
                : Colors.white.withOpacity(0.4)),
        child: child,
      ),
    );
  }
}
