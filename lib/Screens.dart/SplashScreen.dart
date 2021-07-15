import 'package:flutter/material.dart';
import 'package:lit_player/A/Animations.dart';
import 'package:lit_player/Providers.dart/VideoService.dart';
import 'package:lit_player/Providers.dart/song.dart';
import 'package:lit_player/Screens.dart/HomeScreen.dart';
import 'package:media_stores/media_stores.dart';
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
    Provider.of<SongsService>(context, listen: false).initState();
    Provider.of<VideoService>(context, listen: false).initState();
    animateController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..forward().whenComplete(
        () => Navigator.push(context, HeroPageBuilder(page: HomeScreen())));
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
      color: Color(0xF8BEECD0),
      child: Center(
        child: FadeTransition(
          opacity:
              Tween<double>(begin: 0.0, end: 1.0).animate(animateController),
          child: Container(
            height: 200,
            width: 200,
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
                  child: toHero.child,
                );
              },
              tag: 'appIcon',
              child: Image.asset(
                'assets/f8a7b6e4-6564-4094-b027-357b0dcef705_200x200.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
// class HeroFlight extends HeroFlightShuttleBuilder{

// }
