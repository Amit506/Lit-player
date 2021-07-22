import 'package:flutter/material.dart';
import 'package:lit_player/Providers.dart/SearchProvider.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:lit_player/Providers.dart/VideoService.dart';
import 'package:lit_player/Providers.dart/song.dart';
import 'package:lit_player/Providers.dart/videoPlayerProvider.dart';
import 'package:lit_player/Screens.dart/SplashScreen.dart';
import 'package:lit_player/Theme.dart/appTheme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider<AppTheme>(
      create: (_) => AppTheme(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SearchService>(
          create: (_) => SearchService(),
        ),
        ChangeNotifierProvider<VideoPlayerProvider>(
          create: (_) => VideoPlayerProvider(),
        ),
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
        theme: Provider.of<AppTheme>(context).theme,
        home: SplashScreen(),
      ),
    );
  }
}
