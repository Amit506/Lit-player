import 'package:flutter/material.dart';
import 'package:lit_player/utils.dart/text_player_widget.dart';
import 'package:shimmer/shimmer.dart';

class SlideBottomWidget extends StatelessWidget {
  final Widget child;

  const SlideBottomWidget({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: (child, animation) {
        final offsetAnimation =
            Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
                .animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      layoutBuilder: (Widget currentChild, List<Widget> previousChildren) {
        return currentChild;
      },
      duration: Duration(milliseconds: 500),
      child: child,
    );
  }
}

class SmallTextPlayerWidget extends StatelessWidget {
  final bool showShimmer;
  final String title;
  final String artist;
  final Widget child;
  const SmallTextPlayerWidget(
      {Key key, this.showShimmer, this.title, this.artist, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return showShimmer
        ? child
        : TextPlayerWidget(
            title: title ?? "Unknown",
            artist: artist ?? "__",
            key: key,
            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
            titletTextColor: Theme.of(context).textTheme.subtitle1.color,
            artisttextColor: Theme.of(context).textTheme.caption.color,
            artistFontSize: Theme.of(context).textTheme.caption.fontSize,
          );
  }
}
