import 'package:flutter/material.dart';
import '../models.dart';

// recover camera position from google camera
class DestinationScreen extends StatelessWidget {
  DestinationScreen({
    Key key,
    this.actionCallback,
  }) : super(key: key);

  final HomeStateHandler actionCallback;
  static final double minHeight = 210;

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
        padding: EdgeInsets.all(20),
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
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Set stop location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: FlatButton(
                  highlightColor: Color(int.parse("0xFFDCDCDC")),
                  color: Color(int.parse("0xFFF4F4F6")),
                  onPressed: () {
                    actionCallback(HomeState.PLAN_END, true);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Unnamed Road",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Spacer(flex: 1),
                        Icon(Icons.search, size: 28),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
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
                    "CONFIRM",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () async {
                    actionCallback(HomeState.RIDE, true);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
