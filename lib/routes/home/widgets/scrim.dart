import 'dart:ui';
import 'package:flutter/material.dart';

class Scrim extends StatelessWidget {
  Scrim({this.onTap, this.scrimValue});
  final VoidCallback onTap;
  final double scrimValue;
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Visibility(
        visible: scrimValue > 0.0,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.black.withOpacity(lerpDouble(0, 0.75, scrimValue)),
          ),
        ),
      ),
    );
  }
}
