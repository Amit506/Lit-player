import 'dart:typed_data';

import 'package:flutter/material.dart';

class Tempavatar extends StatelessWidget {
  const Tempavatar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          image: DecorationImage(
              image: AssetImage('assets/SPACE_album-mock.jpg'),
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
          borderRadius: BorderRadius.circular(15.0),
          image:
              DecorationImage(image: MemoryImage(image), fit: BoxFit.contain)),
    );
  }
}
