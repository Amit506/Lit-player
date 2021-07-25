import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lit_player/Providers.dart/SearchProvider.dart';

import 'package:lit_player/Providers.dart/VideoService.dart';
import 'package:lit_player/Providers.dart/videoPlayerProvider.dart';
import 'package:lit_player/Screens.dart/HorizontalVideoPlayer.dart';
import 'package:lit_player/Screens.dart/VideoSearchScreen.dart';
import 'package:lit_player/utils.dart/VideoListAvatar.dart';
import 'package:lit_player/utils.dart/bottomSheetTop.dart';
import 'package:lit_player/utils.dart/videoContainer.dart';
import 'package:media_stores/media_stores.dart';
import 'package:media_stores/videoInfo.dart';
import 'package:provider/provider.dart';

import 'package:lit_player/utils.dart/getDuration.dart';
import 'package:share/share.dart';

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
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  final df = DateFormat('dd-MM-yyyy');
  @override
  Widget build(BuildContext context) {
    final videoService = Provider.of<VideoService>(context);
    return Scaffold(
      key: _scaffold,
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
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Consumer<VideoService>(
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
                child: GridView.builder(
                  // key: PageStorageKey(1),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4),
                  itemBuilder: (BuildContext context, int index) {
                    print(videos[index].dateAdded);
                    return VideoContainer(
                      date: df.format(
                        DateTime.parse(videos[index].dateAdded),
                      ),
                      size:
                          '${videos[index].size.substring(0, videos[index].size.length < 4 ? videos[index].size.length : 4)} mb',
                      fileName: videos[index].title,
                      index: index,
                      duration: videos[index].duration,
                      onTap: () async {
                        final filePath =
                            await MediaStores.getPath(videos[index].uri);
                        print(filePath.toString());
                        if (filePath != null) {
                          Provider.of<VideoPlayerProvider>(context,
                                  listen: false)
                              .onInitVideo(filePath);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HorizontalVideoPlayer(
                                uri: filePath,
                              ),
                            ),
                          );
                        }
                      },
                      onLongPress: () async {
                        final filePath =
                            await MediaStores.getPath(videos[index].uri);
                        _scaffold.currentState.showBottomSheet(
                          (context) => ListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: [
                                BottomSheetTop(),
                                ListTile(
                                  leading: Icon(Icons.video_label),
                                  title: Text(videos[index].title),
                                  subtitle: Text(videos[index].duration != null
                                      ? getDuration(
                                          double.parse(videos[index].duration))
                                      : '-'),
                                  trailing: Text(
                                      '${videos[index].size.substring(0, videos[index].size.length < 4 ? videos[index].size.length : 4)} mb'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.share),
                                  onTap: () async {
                                    if (filePath != null)
                                      await Share.shareFiles(
                                        [filePath],
                                      );
                                  },
                                  title: Text('Share'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.filter_none_rounded),
                                  // onTap: () async {
                                  //   final filePath = await MediaStores.getPath(
                                  //       videos[index].uri);
                                  //   await Share.shareFiles(
                                  //     [filePath],
                                  //   );
                                  // },
                                  title: Text(filePath ?? '---'),
                                ),
                              ]),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        );
                      },
                    );
                  },
                  itemCount: videos.length,
                ),
              );
            }
          },
        ),
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
