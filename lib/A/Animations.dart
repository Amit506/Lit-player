import 'package:flutter/cupertino.dart';

class HeroPageBuilder extends PageRouteBuilder {
  final Widget page;

  HeroPageBuilder({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SizeTransition(sizeFactor: animation, child: child),
        );
  @override
  Duration get transitionDuration => Duration(seconds: 4);
  @override
  Curve get barrierCurve => Curves.easeOutCubic;
}
