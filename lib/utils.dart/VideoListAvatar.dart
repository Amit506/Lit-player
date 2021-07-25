import 'dart:typed_data';

import 'package:flutter/material.dart';

class MusicTempAvatar extends StatelessWidget {
  const MusicTempAvatar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          image: DecorationImage(
            image: AssetImage('assets/music-note.png'),
          )),
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

class VideoTempavatar extends StatelessWidget {
  const VideoTempavatar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Icon(
          Icons.video_collection_rounded,
          size: 50,
        ));
  }
}

class VideoAlbumArtAvatar extends StatelessWidget {
  final Uint8List image;
  const VideoAlbumArtAvatar({Key key, @required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          image: DecorationImage(image: MemoryImage(image), fit: BoxFit.cover)),
    );
  }
}
