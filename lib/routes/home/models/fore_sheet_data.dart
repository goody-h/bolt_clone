import 'package:flutter/material.dart';

class ForeSheetData {
  ForeSheetData({
    this.text,
    this.offsetHeight,
    this.onTap,
    this.textStream,
    this.reverseGesture = false,
    this.height,
    this.duration,
    this.gestureOffset,
  });
  final String Function() text;
  final double offsetHeight;
  final VoidCallback onTap;
  final Stream<String> textStream;
  final bool reverseGesture;
  final double height;
  final Duration duration;
  final double gestureOffset;
}
