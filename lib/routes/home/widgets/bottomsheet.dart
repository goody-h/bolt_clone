import 'dart:ui';
import 'package:bolt_clone/routes/home/models/gesture_controller.dart';
import 'package:flutter/material.dart';

export 'package:bolt_clone/routes/home/models/gesture_controller.dart';

class BottomSheetWrapper extends StatelessWidget {
  BottomSheetWrapper({
    this.child,
    this.revealValue,
    this.maxHeight,
    this.minHeight,
    this.useGesture,
    this.useFade,
    this.duration,
    this.isAnimating,
  });

  final double revealValue;
  final double maxHeight;
  final double minHeight;
  final Widget child;
  final GestureController useGesture;
  final Animation<double> Function() useFade;
  final Duration duration;
  final bool isAnimating;

  double get height => lerpDouble(minHeight, maxHeight, revealValue);

  @override
  Widget build(BuildContext context) {
    Widget body = AnimatedContainer(
      duration: !isAnimating ? duration : Duration.zero,
      height: height,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: child,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2, // soften the shadow
            spreadRadius: 1.0, //extend the shadow
          )
        ],
      ),
    );

    if (useFade != null) {
      body = FadeTransition(opacity: useFade(), child: body);
    }

    body = GestureDetector(
      onVerticalDragUpdate: useGesture?.onVerticalDragUpdate,
      onVerticalDragEnd: useGesture?.onVerticalDragEnd,
      child: body,
    );

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: body,
    );
  }
}
