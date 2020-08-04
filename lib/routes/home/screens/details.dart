import 'package:bolt_clone/routes/home/home.dart';
import 'package:flutter/material.dart';
import '../models.dart';
import '../utils.dart';

class DetailsScreen extends StatelessWidget {
  DetailsScreen({
    Key key,
    this.gestureHandler,
    this.maxHeight,
    this.actionCallback,
  }) : super(key: key);

  final GestureHandler gestureHandler;
  final double maxHeight;
  final HomeStateHandler actionCallback;
  static final double minHeight = 320;

  Widget _getListItem(
      IconData icon, String title, String subTitle, bool isSelected) {
    return SizedBox(
      width: double.infinity,
      height: 82,
      child: FlatButton(
        color: isSelected ? Colors.lightGreen : Colors.white,
        highlightColor: Colors.lightGreen.withOpacity(0.4),
        onPressed: () {
          gestureHandler.controller.forward();
        },
        padding: EdgeInsets.only(right: 20, left: 20, bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                icon,
                color: Colors.grey,
                size: 28,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(title),
                  Text(
                    subTitle,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("N 300"),
                Text(
                  "N 500",
                  style: TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

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
            onTap: () {
              gestureHandler.controller.reverse();
            },
          ),
          ignoring: gestureHandler.controller.value == 0,
        ),
        AnimatedBuilder(
          animation: HomeMainScreen.of(context).inset.controller,
          child: GestureDetector(
            onVerticalDragUpdate: gestureHandler.controller.value > 0.0
                ? gestureHandler.handleDragUpdate
                : null,
            onVerticalDragEnd: gestureHandler.controller.value > 0.0
                ? gestureHandler.handleDragEnd
                : null,
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
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Opacity(
                  opacity: (0.5 - gestureHandler.controller.value).abs() / 0.5,
                  child: gestureHandler.controller.value < 0.5
                      ? Container(
                          height: minHeight,
                          padding: EdgeInsets.only(bottom: 135),
                          //possible scroll view
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              _getListItem(
                                  Icons.local_taxi, "Lite", "6 min", true),
                              _getListItem(Icons.directions_transit, "Premium",
                                  "10 min", false),
                            ],
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(top: 20),
                          height: maxHeight - 20,
                          color: Colors.blue,
                          width: double.infinity,
                          child: Text("details"),
                        ),
                ),
              ),
            ),
          ),
          builder: (context, child) {
            return Stack(
              children: <Widget>[
                Positioned(
                  height: gestureHandler.lerp(minHeight, maxHeight) *
                      HomeMainScreen.of(context).inset.controller.value,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: child,
                ),
              ],
            );
          },
        ),
        AnimatedBuilder(
          animation: HomeMainScreen.of(context).inset.controller,
          child: Container(
            height: 135,
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
                height: 135,
                padding: EdgeInsets.only(bottom: 20),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: FlatButton(
                        onPressed: () {},
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.credit_card),
                            Container(width: 10),
                            Text('Cash'),
                            Icon(Icons.keyboard_arrow_down),
                            Spacer(flex: 1),
                            Container(
                              child: Text("-40% promo",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: RaisedButton(
                          color: Colors.green,
                          elevation: 1,
                          shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          child: Text(
                            "SELECT LITE",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () {
                            actionCallback(HomeState.CONFIRM, true);
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          builder: (context, child) {
            return Stack(
              children: <Widget>[
                Positioned(
                  height: (135 - gestureHandler.lerp(0, 135)) *
                      HomeMainScreen.of(context).inset.controller.value,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: child,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
