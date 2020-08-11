import 'dart:ui';
import 'package:flutter/material.dart';

class LowerSheet extends StatelessWidget {
  LowerSheet({this.isAnimating, this.revealValue, this.onTap});
  final bool isAnimating;
  final double revealValue;
  final VoidCallback onTap;

  double bottomPadding(BuildContext context) {
    return isAnimating ? 0.0 : MediaQuery.of(context).viewInsets.bottom;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: lerpDouble(0, 50 + bottomPadding(context), revealValue),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2, // soften the shadow
              spreadRadius: 1.0, //extend the shadow
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            height: 50,
            width: double.infinity,
            child: FlatButton(
              onPressed: onTap,
              child: const Text("Choose on map"),
            ),
          ),
        ),
      ),
    );
  }
}
