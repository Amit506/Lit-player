import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lit_player/Providers.dart/SearchProvider.dart';
import 'package:lit_player/Providers.dart/videoPlayerProvider.dart';
import 'package:lit_player/Screens.dart/HorizontalVideoPlayer.dart';
import 'package:lottie/lottie.dart';
import 'package:media_stores/media_stores.dart';
import 'package:provider/provider.dart';
import 'package:lit_player/utils.dart/getDuration.dart';
import 'package:share/share.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Timer _debounce;
  @override
  void dispose() {
    super.dispose();
    _debounce?.cancel();
  }

  onChange(String value, SearchService searchService) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      searchService.onSearchResult(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchService = Provider.of<SearchService>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) => onChange(value, searchService),
          decoration: InputDecoration(
            suffixIcon: IconButton(icon: Icon(Icons.cancel), onPressed: () {}),
            fillColor: Colors.white38,
            hintText: 'Search....',
            enabledBorder: UnderlineInputBorder(),
            border: UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(),
            disabledBorder: UnderlineInputBorder(),
          ),
        ),
      ),
      body: SizedBox(
          height: size.height,
          width: size.width,
          child: Consumer<SearchService>(
            builder: (context, value, child) {
              if (value.searchStatus == SearchStatus.Initiliased) {
                return Center(
                  child: Hero(
                    tag: "b",
                    child: Lottie.asset(
                        'assets/65743-search-magnifying-glass.json',
                        animate: true,
                        repeat: true),
                  ),
                );
              } else if (value.searchStatus == SearchStatus.NoFound) {
                return Center(
                  child: Lottie.asset('assets/13525-empty.json',
                      animate: true, repeat: true),
                );
              } else {
                final list = value.searchResult;
                return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      return ListTile(
                        onLongPress: () async {
                          final filePath =
                              await MediaStores.getPath(list[i].uri);
                          await Share.shareFiles(
                            [filePath],
                          );
                        },
                        onTap: () async {
                          final filePath =
                              await MediaStores.getPath(list[i].uri);
                          print(filePath);
                          Provider.of<VideoPlayerProvider>(context,
                                  listen: false)
                              .onInitVideo(filePath);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => HorizontalVideoPlayer(
                                        uri: filePath,
                                      )));
                        },
                        title: Text(
                          list[i].title,
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              list[i].duration != null
                                  ? getDuration(double.parse(list[i].duration))
                                  : '-',
                            ),
                            Text(
                              '${list[i].size.substring(0, list[i].size.length < 4 ? list[i].size.length : 4)} mb',
                            ),
                          ],
                        ),
                      );
                    });
              }
            },
          )),
    );
  }
}

enum SearchStatus {
  Found,
  NoFound,
  Initiliased,
}
