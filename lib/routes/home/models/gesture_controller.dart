import 'package:flutter/material.dart';

class GestureController {
  GestureController({this.onVerticalDragUpdate, this.onVerticalDragEnd});
  final void Function(DragUpdateDetails) onVerticalDragUpdate;
  final void Function(DragEndDetails) onVerticalDragEnd;
}
