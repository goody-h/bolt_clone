import 'dart:ui';
import 'package:bolt_clone/utils.dart';
import 'package:flutter/material.dart';

class ForeSheet extends StatelessWidget {
  ForeSheet({
    this.text,
    this.offsetHeight = 85,
    this.revealValue = 0,
    this.onTap,
    this.textStream,
    this.reverseGesture,
    this.height,
    this.isAnimating,
    this.duration = Duration.zero,
    this.gestureOffset,
  });

  final String Function() text;
  final Stream<String> textStream;
  final double revealValue;
  final double offsetHeight;
  final double gestureOffset;
  final VoidCallback onTap;
  final bool reverseGesture;
  final double height;
  final bool isAnimating;
  final Duration duration;

  double get bottomOffset =>
      (isAnimating ? -(gestureOffset ?? offsetHeight) : -offsetHeight) + 85;

  @override
  Widget build(BuildContext context) {
    Widget body = AnimatedContainer(
      duration: !isAnimating ? (duration ?? Duration.zero) : Duration.zero,
      height: !reverseGesture
          ? lerpDouble(isAnimating ? (gestureOffset ?? offsetHeight) : height,
              0, revealValue)
          : lerpDouble(
              0,
              isAnimating ? (gestureOffset ?? offsetHeight) : height,
              revealValue),
      width: double.infinity,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.only(bottom: 30, right: 20, left: 20),
          width: double.infinity,
          child: SizedBox(
            height: 55,
            width: double.infinity,
            child: StreamBuilder<String>(
              key: ValueKey(text()),
              stream: textStream ?? Stream.value(text()),
              builder: (context, snapshot) {
                String label = "";
                if (snapshot.data != null) {
                  label = snapshot.data;
                }
                // TODO diisable button when text is null
                return RaisedButton(
                  color: AppColors.greenButton,
                  elevation: 1,
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () => onTap(),
                );
              },
              initialData: text(),
            ),
          ),
        ),
      ),
    );

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomOffset,
      child: body,
    );
  }
}
