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
  Duration get transitionDuration => Duration(seconds: 5);
  @override
  Curve get barrierCurve => Curves.easeOutCubic;
}

class HeroMusicOpenScreen extends PageRouteBuilder {
  final Widget page;

  HeroMusicOpenScreen({this.page})
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
                SizeTransition(
                    sizeFactor: Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.linear,
                      ),
                    ),
                    child: child));
  @override
  Duration get transitionDuration => Duration(seconds: 1);
}
