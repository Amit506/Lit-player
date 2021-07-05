import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lit_player/Providers.dart/VideoService.dart';
import 'package:lit_player/utils.dart/ListAvatar.dart';
import 'package:provider/provider.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
      ),
      body: Consumer<VideoService>(
        builder: (context, value, child) {
          if (value.videoList.length == 0) {
            return Center(
              child: Text('no items'),
            );
          } else {
            final videos = value.videoShowList;
            return NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels ==
                    notification.metrics.maxScrollExtent) {
                  value.updateVideoShowList(value.videoShowList.length,
                      value.videoShowList.length + 20);
                }
              },
              child: ListView.builder(
                itemBuilder: (context, i) {
                  return ListTile(
                    leading: ValueListenableBuilder<List<Uint8List>>(
                      valueListenable: value.videoThumbnails,
                      builder: (context, values, child) {
                        Widget animatedSwitcherChild = values[i] != null
                            ? AlbumArtAvatar(image: values[i])
                            : Tempavatar();
                        return AnimatedSwitcher(
                            // transitionBuilder: (child, animation) {
                            //   return ScaleTransition(
                            //     scale: animation,
                            //     child: child,
                            //   );
                            // },
                            child: animatedSwitcherChild,
                            duration: Duration(seconds: 1));
                      },
                    ),
                    title: Text(videos[i].title),
                  );
                },
                itemCount: videos.length,
              ),
            );
          }
        },
      ),
    );
  }
}
