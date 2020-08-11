import 'package:flutter/material.dart';

class ForeSheetData {
  ForeSheetData({
    this.text,
    this.offsetHeight,
    this.onTap,
    this.useSlide,
    this.textStream,
    this.reverseGesture = false,
  });
  final String Function() text;
  final double offsetHeight;
  final VoidCallback onTap;
  final Animation<Offset> Function() useSlide;
  final Stream<String> textStream;
  final bool reverseGesture;
}
