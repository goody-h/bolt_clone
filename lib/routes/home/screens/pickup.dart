import 'package:flutter/material.dart';
import '../models.dart';
import '../utils.dart';

class PickupScreen extends StatelessWidget {
  PickupScreen({
    Key key,
    this.gestureHandler,
    this.maxHeight,
    this.isPickup = false,
    this.actionCallback,
  }) : super(key: key);

  final bool isPickup;
  final GestureHandler gestureHandler;
  final HomeStateHandler actionCallback;
  final double maxHeight;

  static final double minHeight = 250;

  @override
  Widget build(BuildContext context) {
    if (isPickup) {
      actionCallback(HomeState.PLAN_START, false);
    } else if (gestureHandler.controller.value == 1) {
      actionCallback(HomeState.PLAN_END, false);
    } else if (gestureHandler.controller.value == 0) {
      actionCallback(HomeState.DEFAULT, false);
    }

    return Stack(
      children: <Widget>[
        IgnorePointer(
          child: Container(
            color: !isPickup
                ? Colors.black.withOpacity(gestureHandler.lerp(0, 0.75))
                : Colors.black,
            height: double.infinity,
            width: double.infinity,
          ),
          ignoring: isPickup || gestureHandler.controller.value == 0,
        ),
        Positioned(
          height:
              !isPickup ? gestureHandler.lerp(minHeight, maxHeight) : maxHeight,
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onVerticalDragUpdate:
                !isPickup ? gestureHandler.handleDragUpdate : null,
            onVerticalDragEnd: !isPickup ? gestureHandler.handleDragEnd : null,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                color: Colors.white, //background color of box
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2, // soften the shadow
                    spreadRadius: 1.0, //extend the shadow
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: 100),
                child: FlatButton(
                  onPressed: () {
                    if (!isPickup) {
                      actionCallback(HomeState.RIDE, true);
                    } else {
                      actionCallback(HomeState.CONFIRM, true);
                    }
                  },
                  child: Text("Rukpokwu"),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          height: !isPickup ? gestureHandler.lerp(0, 180) : 180,
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, //background color of box
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2, // soften the shadow
                  spreadRadius: 1.0, //extend the shadow
                )
              ],
            ),
            child: SingleChildScrollView(
              reverse: true,
              physics: NeverScrollableScrollPhysics(),
              child: Container(
                height: 180,
                width: double.infinity,
              ),
            ),
          ),
        ),
        Positioned(
          height: !isPickup ? gestureHandler.lerp(0, 50) : 50,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, //background color of box
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2, // soften the shadow
                  spreadRadius: 1.0, //extend the shadow
                )
              ],
            ),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Container(
                height: 50,
                width: double.infinity,
                child: FlatButton(
                  onPressed: () {
                    if (!isPickup) {
                      actionCallback(HomeState.PICK, true);
                    } else {
                      actionCallback(HomeState.CONFIRM, true);
                    }
                  },
                  child: Text("Choose on map"),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
