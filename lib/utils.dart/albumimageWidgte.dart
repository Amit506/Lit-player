import 'package:flutter/material.dart';

class AlbumImageWidget extends StatelessWidget {
  final memeoryImage;
  final bool initial;

  const AlbumImageWidget({Key key, this.memeoryImage, this.initial = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(memeoryImage);
    if (initial) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return memeoryImage != null
          ? Image.memory(
              memeoryImage,
              fit: BoxFit.cover,
            )
          : Image.asset(
              'assets/SPACE_album-mock.jpg',
              fit: BoxFit.cover,
            );
    }
  }
}
