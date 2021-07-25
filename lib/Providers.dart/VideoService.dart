import 'package:flutter/foundation.dart';
import 'package:lit_player/Providers.dart/thumbnail.dart';
import 'package:media_stores/media_stores.dart';
import 'package:media_stores/videoInfo.dart';

class VideoService extends ChangeNotifier {
  final lowQualityThumbNail = Thumbnail(480, 480);
  List<VideoInfo> videoList = [];

  List<VideoInfo> videoShowList = [];

  void initState({bool setDefault = false}) async {
    videoList.clear();
    videoShowList.clear();
    if (videoList.length == 0 || setDefault) {
      final allVideos = await MediaStores.getVideos();
      videoList = allVideos;

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
      videoList.sort((a, b) {
        var date1 = DateTime.parse(a.dateAdded);
        var date2 = DateTime.parse(b.dateAdded);
        return date2.compareTo(date1);
      });
    }
    videoShowList.clear();
    updateVideoShowList(0, videoList.length < 30 ? videoList.length : 30);
  }

  Future getThumbail({int index, int id, int start = 0, int end = 20}) async {
    int i = start;
    while (i < end) {
      final bitmap = await lowQualityThumbNail
          .getVideoThumbnail(
        int.parse(videoList[i].id),
      )
          .onError((error, stackTrace) {
        print(error.toString());
        return null;
      });

      if (bitmap != null) {
        try {
          videoList[i] = videoList[i].copyWith(imageBit: bitmap);
          videoShowList[i] = videoList[i];
        } catch (e) {}

        notifyListeners();
      }

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
