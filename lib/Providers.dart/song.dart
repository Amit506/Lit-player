import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:lit_player/Providers.dart/FetchData.dart';
import 'package:media_stores/SongInfo.dart';
import 'package:media_stores/media_stores.dart';

class SongsService extends ChangeNotifier {
  List<SongInfo> songInfoList = [];
  List<SongInfo> songShowList = [];
  ValueNotifier<List<Uint8List>> songThumbnails = ValueNotifier(<Uint8List>[]);
  List<bool> isAvailableThumnails = [];
  List<SongInfo> get allPlaysListAvailable => songInfoList;
  SongInfo currentSong;
  SongInfo get getCurrentSong => this.currentSong;

  set setCurrentSong(SongInfo currentSong) => this.currentSong = currentSong;
  void initState() async {
    songInfoList = await MediaStores.getSongs();
    songThumbnails = ValueNotifier(List.filled(songInfoList.length, null));
    isAvailableThumnails = List.filled(songInfoList.length, false);
    updateSongShowList(0, songInfoList.length < 20 ? songInfoList.length : 20);
  }

  updateSongShowList(int start, int end) {
    end = end > songInfoList.length ? songInfoList.length : end;
    if (start < songInfoList.length && end <= songInfoList.length) {
      songShowList.addAll(songInfoList.sublist(start, end));
      notifyListeners();
      getThumbail(
          start: start, end: end == songInfoList.length ? end - 1 : end);
    } else {
      print('reached   ${songInfoList.length}==${songInfoList.length}');
    }
  }

  Future getThumbail({int index, int id, int start = 0, int end = 15}) async {
    print("-------------------getthumbnail------------");
    int i = start;
    while (i < end) {
      if (!isAvailableThumnails[i]) {
        final bitmap = await MediaStores.bitMap(int.parse(songInfoList[i].id),
                width: 50, height: 50)
            .onError((error, stackTrace) {
          print(error.toString());
        });

        if (bitmap != null) {
          songThumbnails.value[i] = bitmap;
          notifyListeners();
        }
        isAvailableThumnails[i] = true;

        i++;
      }
    }
  }

  Future<Uint8List> getQualityThumbnail(int index, int id) async {
    final bitmap = await MediaStores.bitMap(id, width: 500, height: 500)
        .onError((error, stackTrace) {
      print(error.toString());
      return null;
    });
    return bitmap;
  }
}

class Thumbnail {
  static Future<Uint8List> getQualityThumbnail(int index, int id) async {
    final bitmap = await MediaStores.bitMap(id, width: 500, height: 500)
        .onError((error, stackTrace) {
      print(error.toString());
      return null;
    });
    return bitmap;
  }
}
