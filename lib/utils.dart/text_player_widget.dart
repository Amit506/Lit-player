import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class TextPlayerWidget extends StatelessWidget {
  final title;
  final artist;
  final double fontSize;
  final double artistFontSize;
  final Color titletTextColor;
  final Color artisttextColor;
  const TextPlayerWidget(
      {Key key,
      this.title,
      this.artist,
      this.fontSize,
      this.titletTextColor,
      this.artisttextColor,
      this.artistFontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      key: key,
      children: [
        Flexible(
          child: Marquee(
            text: title,
            fadingEdgeStartFraction: 0.4,
            style: TextStyle(
                fontSize: fontSize,
                color: titletTextColor,
                fontWeight: FontWeight.w400),
            blankSpace: 20.0,
            velocity: 100.0,
            pauseAfterRound: Duration(seconds: 1),
            startPadding: 10.0,
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            accelerationDuration: Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
        ),
        Flexible(
            child: Text(
          artist,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: artistFontSize,
            color: artisttextColor,
          ),
        ))
      ],
    );
  }
}
