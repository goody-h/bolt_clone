import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class GestureHandler {
  GestureHandler({this.controller, this.maxBound});
  final AnimationController controller;
  final double maxBound;

  double lerp(double min, double max) => lerpDouble(min, max, controller.value);

  void handleDragUpdate(DragUpdateDetails details) {
    controller.value -= details.primaryDelta /
        maxBound; //<-- Update the _controller.value by the movement done by user.
  }

  void handleDragEnd(DragEndDetails details) {
    if (controller.isAnimating ||
        controller.status == AnimationStatus.completed) return;

    final double flingVelocity = details.velocity.pixelsPerSecond.dy /
        maxBound; //<-- calculate the velocity of the gesture
    if (flingVelocity < 0.0)
      controller.fling(
          velocity: max(2.0, -flingVelocity)); //<-- either continue it upwards
    else if (flingVelocity > 0.0)
      controller.fling(
          velocity: min(-2.0, -flingVelocity)); //<-- or continue it downwards
    else
      controller.fling(
          velocity: controller.value < 0.5
              ? -2.0
              : 2.0); //<-- or just continue to whichever edge is closer
  }
}
