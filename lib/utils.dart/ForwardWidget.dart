import 'dart:math';

import 'package:flutter/material.dart';

class LeftForwardWidget extends StatelessWidget {
  final int seeked;
  final double height;
  final VoidCallback leftInkWellTap;
  const LeftForwardWidget(
      {Key key, this.seeked, this.height, this.leftInkWellTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(height / 2 - 20),
              bottomRight: Radius.circular(height / 2 - 20)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                  angle: pi, child: Icon(Icons.fast_forward_rounded)),
              SizedBox(
                width: 5,
              ),
              Text('${seeked.abs() == 0 ? 10 : seeked.abs()}')
            ],
          ),
        ),
      ),
    );
  }
}

// customBorder: RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//       topRight: Radius.circular(height / 2 - 20),
//       bottomRight: Radius.circular(height / 2 - 20)),
//         ),
class RightForwardWidget extends StatelessWidget {
  final int seeked;
  final double height;
  final VoidCallback rightInkWellTap;
  const RightForwardWidget(
      {Key key, this.seeked, this.height, this.rightInkWellTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(height / 2 - 20),
              bottomLeft: Radius.circular(height / 2 - 20)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fast_forward_rounded),
              SizedBox(
                width: 10,
              ),
              Text('$seeked')
            ],
          ),
        ),
      ),
    );
  }
}
