import 'package:flutter/material.dart';

class BottomSheetTop extends StatelessWidget {
  const BottomSheetTop({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: SizedBox(
        height: 40,
        width: double.infinity,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.5),
              color: Colors.black,
            ),
            height: 3,
            width: 25,
          ),
        ),
      ),
    );
  }
}
