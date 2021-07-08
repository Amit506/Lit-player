import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:media_stores/media_stores.dart';
import 'package:media_stores/videoInfo.dart';

class VideoService extends ChangeNotifier {
  List<VideoInfo> videoList = [];
  List<VideoInfo> videoShowList = [];
  ValueNotifier<List<Uint8List>> videoThumbnails = ValueNotifier(<Uint8List>[]);
  List<bool> isVideoAvailableThumnails = [];

  void initState() async {
    videoList = await MediaStores.getVideos();
    videoThumbnails = ValueNotifier(List.filled(videoList.length, null));
    isVideoAvailableThumnails = List.filled(videoList.length, false);
    updateVideoShowList(0, videoList.length < 20 ? videoList.length : 20);
  }

  updateVideoShowList(int start, int end) {
    end = end > videoList.length ? videoList.length : end;
    if (start < videoList.length && end <= videoList.length && start < end) {
      videoShowList.addAll(videoList.sublist(start, end));
      notifyListeners();
      getThumbail(start: start, end: end == videoList.length ? end - 1 : end);
    } else {
      print('reached    ${videoList.length}==${videoShowList.length}');
    }
  }

  Future getThumbail({int index, int id, int start = 0, int end = 15}) async {
    print("-------------------videogetthumbnail------------");
    int i = start;
    while (i < end) {
      if (!isVideoAvailableThumnails[i]) {
        final bitmap = await MediaStores.videoBitMap(int.parse(videoList[i].id),
                width: 50, height: 50)
            .onError((error, stackTrace) {
          print(error.toString());
        });

        if (bitmap != null) {
          videoThumbnails.value[i] = bitmap;
          notifyListeners();
        }
        isVideoAvailableThumnails[i] = true;
        notifyListeners();
        i++;
      }
    }
  }
}
