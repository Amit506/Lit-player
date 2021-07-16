import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lit_player/Providers.dart/SearchProvider.dart';

import 'package:lit_player/Providers.dart/VideoService.dart';
import 'package:lit_player/Providers.dart/videoPlayerProvider.dart';
import 'package:lit_player/Screens.dart/HorizontalVideoPlayer.dart';
import 'package:lit_player/Screens.dart/VideoSearchScreen.dart';
import 'package:lit_player/utils.dart/VideoListAvatar.dart';
import 'package:media_stores/media_stores.dart';
import 'package:media_stores/videoInfo.dart';
import 'package:provider/provider.dart';

import 'package:lit_player/utils.dart/getDuration.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({Key key}) : super(key: key);

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  @override
  void initState() {
    super.initState();
  }

  int index = 15;

  @override
  Widget build(BuildContext context) {
    final videoService = Provider.of<VideoService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
        actions: <Widget>[
          DropdownButtonHideUnderline(
            child: DropdownButton<SortBy>(
                isDense: true,
                hint: Text('sort by'),
                items: [
                  DropdownMenuItem(
                    child: Text('Size'),
                    value: SortBy.Size,
                  ),
                  DropdownMenuItem(
                    child: Text('A-Z'),
                    value: SortBy.AtoZ,
                  ),
                  DropdownMenuItem(
                    child: Text('Default'),
                    value: SortBy.Default,
                  ),
                ],
                onChanged: (value) {
                  videoService.sortBy(value);
                }),
          ),
        ],
      ),
      body: Consumer<VideoService>(
        builder: (context, value, child) {
          if (value.videoList.length == 0) {
            return Center(
              child: Text('No videos available in device'),
            );
          } else {
            final videos = value.videoShowList;
            return NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels ==
                    notification.metrics.maxScrollExtent) {
                  value.updateVideoShowList(value.videoShowList.length,
                      value.videoShowList.length + 30);
                }
                return true;
              },
              child: ListView.separated(
                separatorBuilder: (context, i) {
                  return Divider(
                    indent: 60,
                  );
                },
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  return ListTile(
                    onTap: () async {
                      final filePath = await MediaStores.getPath(videos[i].uri);

                      if (filePath != null) {
                        Provider.of<VideoPlayerProvider>(context, listen: false)
                            .onInitVideo(filePath);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => HorizontalVideoPlayer(
                                      uri: filePath,
                                    )));
                      }
                    },
                    leading: Selector<VideoService, List<VideoInfo>>(
                        selector: (_, changer) => changer.videoShowList,
                        builder: (_, data, child) {
                          Widget animatedSwitcherChild =
                              data[i].imageBit != null
                                  ? AlbumArtAvatar(image: data[i].imageBit)
                                  : Tempavatar(
                                      isSong: false,
                                    );
                          return FittedBox(
                            fit: BoxFit.cover,
                            child: AnimatedSwitcher(
                                child: animatedSwitcherChild,
                                duration: Duration(milliseconds: 500)),
                          );
                        }),
                    title: Text(videos[i].title),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${videos[i].dateAdded}'),
                        Text(
                            '${videos[i].size.substring(0, videos[i].size.length < 4 ? videos[i].size.length : 4)} mb')
                      ],
                    ),
                  );
                },
                itemCount: videos.length,
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'b',
        onPressed: () {
          Provider.of<SearchService>(context, listen: false).allSearchableList =
              Provider.of<VideoService>(context, listen: false).videoList;
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => SearchScreen()));
        },
        child: Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}
