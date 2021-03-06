import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lit_player/Providers.dart/VideoService.dart';
import 'package:lit_player/Theme.dart/appTheme.dart';
import 'package:lit_player/utils.dart/VideoListAvatar.dart';
import 'package:media_stores/videoInfo.dart';
import 'package:provider/provider.dart';

class VideoContainer extends StatelessWidget {
  final String date;
  final String size;
  final String fileName;
  final int index;
  final String duration;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const VideoContainer(
      {Key key,
      this.date,
      this.size,
      this.fileName,
      this.index,
      this.duration,
      this.onTap,
      this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Selector<VideoService, List<VideoInfo>>(
                selector: (_, changer) => changer.videoShowList,
                builder: (_, data, child) {
                  Widget animatedSwitcherChild = data[index].imageBit != null
                      ? VideoAlbumArtAvatar(image: data[index].imageBit)
                      : VideoTempavatar();
                  return AnimatedSwitcher(
                      child: animatedSwitcherChild,
                      duration: Duration(milliseconds: 500));
                }),
            // ShadowWidget(
            //   offset: Offset(
            //     0.0,
            //     160,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Text(
                  size,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 1.0,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
              ),
            ),
            // ShadowWidget(
            //   offset: Offset(
            //     0.0,
            //     200,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  date,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 1.0,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class ShadowWidget extends StatelessWidget {
//   final Offset offset;
//   const ShadowWidget({Key key, this.offset}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(boxShadow: [
//         BoxShadow(
//             color: Provider.of<AppTheme>(context).currentTheme ==
//                     CurrentTheme.Light
//                 ? Colors.white60.withOpacity(0.6)
//                 : Colors.black26.withOpacity(0.6),
//             spreadRadius: 10.0,
//             offset: offset)
//       ]),
//     );
//   }
// }
