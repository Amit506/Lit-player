import 'package:flutter/cupertino.dart';
import 'package:lit_player/Screens.dart/VideoSearchScreen.dart';
import 'package:media_stores/videoInfo.dart';

class SearchService extends ChangeNotifier {
  List<VideoInfo> allSearchableList = [];
  List<VideoInfo> searchResult = [];
  SearchStatus searchStatus = SearchStatus.Initiliased;
  onSearchResult(String searchItem) {
    searchStatus = SearchStatus.NoFound;
    searchResult = allSearchableList
        .where(
            (p) => p.title.toLowerCase().startsWith(searchItem.toLowerCase()))
        .toList();
    if (searchResult.length != 0)
      searchStatus = SearchStatus.Found;
    else
      searchStatus = SearchStatus.NoFound;

    notifyListeners();
  }
}
