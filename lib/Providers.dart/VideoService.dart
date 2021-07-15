import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:media_stores/media_stores.dart';
import 'package:media_stores/videoInfo.dart';

class VideoService extends ChangeNotifier {
  List<VideoInfo> videoList = [];
  List<VideoInfo> videoListStore = [];
  List<VideoInfo> videoShowList = [];
  // ValueNotifier<List<Uint8List>> videoThumbnails = ValueNotifier(<Uint8List>[]);
  // List<bool> isVideoAvailableThumnails = [];

  void initState({bool setDefault = false}) async {
    if (videoList.length == 0 || setDefault) {
      final allVideos = await MediaStores.getVideos();
      videoList = allVideos;
      videoListStore = allVideos;

      // videoThumbnails = ValueNotifier(List.filled(videoList.length, null));
      // isVideoAvailableThumnails = List.filled(videoList.length, false);
      updateVideoShowList(0, videoList.length < 30 ? videoList.length : 30);
    }
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

  void sortBy(SortBy sort) {
    if (SortBy.AtoZ == sort) {
      videoList.sort((a, b) {
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
    } else if (SortBy.Size == sort) {
      videoList.sort((a, b) {
        return double.parse(b.size).compareTo(double.parse(a.size));
      });
    } else {
      initState(setDefault: true);
    }
    videoShowList.clear();
    updateVideoShowList(0, videoList.length < 30 ? videoList.length : 30);
  }

  Future getThumbail({int index, int id, int start = 0, int end = 20}) async {
    print("-------------------videogetthumbnail------------");
    int i = start;
    while (i < end) {
      print("990000000000000000000");
      // if (!isVideoAvailableThumnails[i]) {
      final bitmap = await MediaStores.videoBitMap(int.parse(videoList[i].id),
              width: 120, height: 80)
          .onError((error, stackTrace) {
        print(error.toString());
      });

      if (bitmap != null) {
        videoList[i] = videoList[i].copyWith(imageBit: bitmap);

        videoShowList[i] = videoList[i];
        // print(videoList[i].imageBit.toString());
        // videoThumbnails.value[i] = bitmap;
        notifyListeners();
      }
      // isVideoAvailableThumnails[i] = true;

      i++;
      // }
    }
  }
}

enum SortBy {
  Size,
  AtoZ,
  Default,
}
