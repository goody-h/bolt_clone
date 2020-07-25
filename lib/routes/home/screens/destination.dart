import 'package:flutter/material.dart';
import '../models.dart';

// recover camera position from google camera
class DestinationScreen extends StatelessWidget {
  DestinationScreen({
    Key key,
    this.actionCallback,
  }) : super(key: key);

  final HomeStateHandler actionCallback;
  static final double minHeight = 150;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      height: minHeight,
      left: 0,
      right: 0,
      bottom: 0,
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
        child: Column(
          children: <Widget>[
            FlatButton(
              child: Text("edit"),
              onPressed: () {
                actionCallback(HomeState.PLAN_END, true);
              },
            ),
            RaisedButton(
              child: Text("Confirm"),
              onPressed: () async {
                actionCallback(HomeState.RIDE, true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
