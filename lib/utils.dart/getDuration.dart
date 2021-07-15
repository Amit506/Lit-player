String getDuration(double value) {
  Duration duration = Duration(milliseconds: value.round());
  return [duration.inMinutes, duration.inSeconds]
      .map((e) => e.remainder(60).toString().padLeft(2, '0'))
      .join(':');
}
