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
              SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child),
        );
  @override
  Duration get transitionDuration => Duration(seconds: 4);
  @override
  Curve get barrierCurve => Curves.easeOutCubic;
}
