import 'package:flutter/material.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:lit_player/Providers.dart/VideoService.dart';
import 'package:lit_player/Providers.dart/song.dart';
import 'package:lit_player/Screens.dart/SplashScreen.dart';
import 'package:provider/provider.dart';
import './Screens.dart/HomeScreen.dart';
import 'Providers.dart/FetchData.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SongPlayer>(
          create: (_) => SongPlayer(),
        ),
        ChangeNotifierProvider<SongsService>(
          create: (_) => SongsService(),
        ),
        ChangeNotifierProvider<VideoService>(
          create: (_) => VideoService(),
        )
      ],
      child: MaterialApp(
        home: SplashScreen(),
      ),
    );
  }
}
