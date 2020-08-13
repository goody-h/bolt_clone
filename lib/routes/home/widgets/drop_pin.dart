import 'dart:ui';

import 'package:bolt_clone/utils.dart';
import 'package:flutter/material.dart';

class DropPin extends StatelessWidget {
  const DropPin({Key key, this.isDown, this.isDestination}) : super(key: key);
  final bool isDown;
  final bool isDestination;

  double get pinRegionHeight => 80;
  double get pinBaseBottomOffset => 12.5;
  double get pinRegionHeightFromBase => pinRegionHeight - pinBaseBottomOffset;
  double get baseCenteringBottomPadding =>
      pinRegionHeightFromBase - pinBaseBottomOffset;
  double get totalHeight => pinRegionHeightFromBase * 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: totalHeight,
      padding: EdgeInsets.only(bottom: baseCenteringBottomPadding),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: isDown ? 0.0 : 1.0),
        curve: Curves.decelerate,
        duration: Duration(milliseconds: 300),
        builder: (context, value, child) {
          double jump;
          double skew = 1.0;

          if (value >= 0.75) {
            jump = lerpDouble(1, 1.2, (1 - value) / 0.25);
          } else if (value >= 0.25 && isDown) {
            jump = lerpDouble(1.2, 0, (0.5 - value) / 0.5);
          } else if (value >= 0 && isDown) {
            jump = 0.0;
            skew = lerpDouble(0.6, 1.0, (0.125 - value).abs() / 0.125);
          } else if (value >= 0) {
            jump = lerpDouble(1.2, 0, (0.75 - value) / 0.75);
          }

          return Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(1.0, 0.25, 1.0),
                  child: ClipOval(
                    child: Container(
                      height: pinBaseBottomOffset * 2,
                      width: 10 + 10 * jump,
                      color: Colors.black.withOpacity(0.05),
                      child: Center(
                        child: ClipOval(
                          child: Container(
                            height: 10 * jump,
                            width: 5 * jump,
                            color: Colors.black.withOpacity(0.25 * jump),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: pinBaseBottomOffset + 7.5 * jump,
                left: 0,
                right: 0,
                height: 15,
                child: Center(
                  child: Container(
                    height: 20,
                    width: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: isDestination
                          ? AppColors.indigoDark
                          : AppColors.greenDark,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: pinBaseBottomOffset + 14 + 7.5 * jump,
                left: 0,
                right: 0,
                child: Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.diagonal3Values(1.0, skew, 1.0),
                  child: ClipOval(
                    child: Container(
                      height: 40,
                      width: 40,
                      color: isDestination
                          ? AppColors.indigo
                          : AppColors.greenButton,
                      child: Center(
                        child: ClipOval(
                          child: Container(
                              height: 15, width: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
