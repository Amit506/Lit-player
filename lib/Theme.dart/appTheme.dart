import 'package:flutter/material.dart';

enum CurrentTheme {
  Light,
  Dark,
}

class AppTheme extends ChangeNotifier {
  CurrentTheme currentTheme = CurrentTheme.Light;
  ThemeData theme = lightTheme;
  changeTheme() {
    if (currentTheme == CurrentTheme.Light) {
      this.theme = darkTheme;
      currentTheme = CurrentTheme.Dark;
    } else {
      this.theme = lightTheme;
      currentTheme = CurrentTheme.Light;
    }
    notifyListeners();
  }

  static final darkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.grey.shade900,
      primaryColor: darkGreenColor,
      brightness: Brightness.dark,
      sliderTheme: SliderThemeData(
        disabledActiveTrackColor: lightGreenColor,
        thumbColor: lightGreenColor,
        disabledInactiveTrackColor: darkGreenColor,
        activeTrackColor: lightGreenColor,
        inactiveTrackColor: darkGreenColor,
        inactiveTickMarkColor: darkGreenColor,
      ),
      textTheme: Typography.whiteRedwoodCity,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkGreenColor,
      ));

  static final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: lightGreenColor,
      sliderTheme: SliderThemeData(
        disabledActiveTrackColor: darkGreenColor,
        thumbColor: darkGreenColor,
        disabledInactiveTrackColor: lightGreenColor,
        activeTrackColor: darkGreenColor,
        inactiveTrackColor: lightGreenColor,
        inactiveTickMarkColor: lightGreenColor,
      ),
      textTheme: Typography.blackRedwoodCity,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightGreenColor,
      ));
}

const darkGreenColor = Color(0xFF100949);
// Color(0xFF0A2E07);
const lightGreenColor = Color(0xFF7AD3E7);
const lightBlueColor = Color(0xff8FD6E1);
const darkBlueColor = Color(0xff150E56);
const lightGreen = Color(0xffA3F7BF);
