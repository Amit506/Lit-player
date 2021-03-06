import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:lit_player/Providers.dart/FetchData.dart';
import 'package:lit_player/Providers.dart/SongPlayer.dart';
import 'package:lit_player/Providers.dart/thumbnail.dart';
import 'package:media_stores/SongInfo.dart';
import 'package:media_stores/media_stores.dart';

class SongsService extends ChangeNotifier {
  final lowQualityThumbNail = Thumbnail(140, 120);
  final SongPlayer _songPlayer = SongPlayer();
  List<SongInfo> songInfoList = [];
  List<SongInfo> songShowList = [];
  List<SongInfo> get allPlaysListAvailable => songInfoList;
  SongInfo currentSong;
  SongInfo get getCurrentSong => this.currentSong;

  set setCurrentSong(SongInfo currentSong) => this.currentSong = currentSong;
  void initState() async {
    songInfoList.clear();
    songShowList.clear();
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
      final bitmap = await lowQualityThumbNail
          .getSongThumbnail(
        int.parse(songInfoList[i].id),
      )
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
}
