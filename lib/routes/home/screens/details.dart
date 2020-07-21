import 'package:flutter/material.dart';
import '../models.dart';
import '../utils.dart';

class DetailsScreen extends StatelessWidget {
  DetailsScreen({
    Key key,
    this.gestureHandler,
    this.inset,
    this.maxHeight,
    this.actionCallback,
  }) : super(key: key);

  final GestureHandler gestureHandler;
  final double inset;
  final double maxHeight;
  final HomeStateHandler actionCallback;
  static final double minHeight = 200;

  @override
  Widget build(BuildContext context) {
    if (gestureHandler.controller.value == 1) {
      actionCallback(HomeState.RIDE_DETAILS, false);
    } else if (gestureHandler.controller.value == 0) {
      actionCallback(HomeState.RIDE, false);
    }
    return Stack(
      children: <Widget>[
        IgnorePointer(
          child: GestureDetector(
            child: Container(
              color: Colors.black.withOpacity(gestureHandler.lerp(0, 0.75)),
              height: double.infinity,
              width: double.infinity,
            ),
            onTap: () {},
          ),
          ignoring: gestureHandler.controller.value == 0,
        ),
        Positioned(
          height: gestureHandler.lerp(minHeight, maxHeight) * inset,
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onVerticalDragUpdate: gestureHandler.handleDragUpdate,
            onVerticalDragEnd: gestureHandler.handleDragEnd,
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
                  onPressed: () {},
                  child: Text("Comfort"),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          height: (100 - gestureHandler.lerp(0, 100)) * inset,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 100,
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
                height: 100,
                width: double.infinity,
                child: RaisedButton(
                  child: Text("Confirm ride"),
                  onPressed: () {
                    actionCallback(HomeState.CONFIRM, true);
                  },
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
