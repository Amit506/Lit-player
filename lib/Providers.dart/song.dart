import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:lit_player/Providers.dart/FetchData.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:media_stores/SongInfo.dart';
import 'package:media_stores/media_stores.dart';

class SongsService extends ChangeNotifier {
  final SongPlayer _songPlayer = SongPlayer();
  List<SongInfo> songInfoList = [];
  List<SongInfo> songShowList = [];
  // ValueNotifier<List<Uint8List>> songThumbnails = ValueNotifier(<Uint8List>[]);
  // List<bool> isAvailableThumnails = [];
  List<SongInfo> get allPlaysListAvailable => songInfoList;
  SongInfo currentSong;
  SongInfo get getCurrentSong => this.currentSong;

  set setCurrentSong(SongInfo currentSong) => this.currentSong = currentSong;
  void initState() async {
    songInfoList = await MediaStores.getSongs();
    if (songInfoList.length > 0) {
      _songPlayer.setLatestSongInfo = songInfoList[0];
      _songPlayer.setCurrentPlayList = songInfoList;
      _songPlayer.playerSetAudioSoucres(songInfoList);
    }
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
    int i = start;
    while (i < end) {
      final bitmap = await MediaStores.bitMap(int.parse(songInfoList[i].id),
              width: 160, height: 120)
          .onError((error, stackTrace) {
        print(error.toString());
        return null;
      });

      if (bitmap != null) {
        songInfoList[i] = songInfoList[i].copyWith(imageBit: bitmap);
        songShowList[i] = songInfoList[i];

        notifyListeners();
      }

      i++;
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
    final bitmap = await MediaStores.bitMap(id, width: 500, height: 650)
        .onError((error, stackTrace) {
      print(error.toString());
      return null;
    });
    return bitmap;
  }
}
