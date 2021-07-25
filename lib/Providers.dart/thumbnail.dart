import 'dart:typed_data';

import 'package:media_stores/media_stores.dart';

class Thumbnail {
  final int width;
  final int height;

  Thumbnail(this.width, this.height);
  Future<Uint8List> getSongThumbnail(int id) async {
    final bitmap = await MediaStores.bitMap(id, width: width, height: height)
        .onError((error, stackTrace) {
      print(error.toString());
      return null;
    });
    return bitmap;
  }

  Future<Uint8List> getVideoThumbnail(int id) async {
    final bitmap =
        await MediaStores.videoBitMap(id, width: width, height: height)
            .onError((error, stackTrace) {
      print(error.toString());
      return null;
    });
    return bitmap;
  }
}
