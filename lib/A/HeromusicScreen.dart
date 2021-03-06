import 'package:flutter/material.dart';

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

class SlideTransitionBuilder extends PageRouteBuilder {
  final Widget page;

  SlideTransitionBuilder({this.page})
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

                    // sizeFactor: Tween<double>(
                    //   begin: 0.0,
                    //   end: 1.0,
                    // ).animate(
                    //   CurvedAnimation(
                    //     parent: animation,
                    //     curve: Curves.linear,
                    //   ),
                    // ),
                    child: child));
  @override
  Duration get transitionDuration => Duration(seconds: 1);
}
