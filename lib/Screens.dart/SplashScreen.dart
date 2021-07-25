import 'package:flutter/material.dart';
import 'package:lit_player/A/Animations.dart';
import 'package:lit_player/Providers.dart/VideoService.dart';
import 'package:lit_player/Providers.dart/song.dart';
import 'package:lit_player/Screens.dart/HomeScreen.dart';
import 'package:lit_player/Theme.dart/appTheme.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animateController;
  @override
  void initState() {
    super.initState();
    permission();

    animateController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..forward().whenComplete(() => Navigator.pushReplacement(
        context, HeroPageBuilder(page: HomeScreen())));
  }

  @override
  void dispose() {
    super.dispose();
    animateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: lightGreenColor,
      child: Center(
        child: Container(
          height: 250,
          width: 250,
          child: Hero(
            flightShuttleBuilder: (
              BuildContext flightContext,
              Animation<double> animation,
              HeroFlightDirection flightDirection,
              BuildContext fromHeroContext,
              BuildContext toHeroContext,
            ) {
              final Hero toHero = toHeroContext.widget;

              return RotationTransition(
                turns: animation,
                child: FadeTransition(opacity: animation, child: toHero.child),
              );
            },
            tag: 'appIcon',
            child: Image.asset(
              'assets/appIcon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ));
  }

  void permission() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request().then((value) {
        if (value.isGranted) {
          Provider.of<SongsService>(context, listen: false).initState();
        }
      });
    } else {
      Provider.of<SongsService>(context, listen: false).initState();
    }
  }
}
