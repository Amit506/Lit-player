import 'dart:typed_data';

import 'package:flutter/material.dart';

class Tempavatar extends StatelessWidget {
  final isSong;
  const Tempavatar({Key key, this.isSong = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          image: DecorationImage(
              image: AssetImage(!isSong
                  ? 'assets/video-player.png'
                  : 'assets/music-note.png'),
              fit: BoxFit.cover)),
    );
  }
}

class AlbumArtAvatar extends StatelessWidget {
  final Uint8List image;
  const AlbumArtAvatar({Key key, @required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          image: DecorationImage(image: MemoryImage(image), fit: BoxFit.cover)),
    );
  }
}
