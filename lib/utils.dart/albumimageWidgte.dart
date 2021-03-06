import 'package:flutter/material.dart';

class AlbumImageWidget extends StatelessWidget {
  final memeoryImage;
  final bool initial;

  const AlbumImageWidget({Key key, this.memeoryImage, this.initial = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (initial) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
        ),
      );
    } else {
      return memeoryImage != null
          ? Image.memory(
              memeoryImage,
              fit: BoxFit.cover,
            )
          : Image.asset(
              'assets/music-note.png',
              fit: BoxFit.cover,
            );
    }
  }
}
