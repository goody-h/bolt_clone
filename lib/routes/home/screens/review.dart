import 'package:flutter/material.dart';
import '../models.dart';
import '../../../models/invoice.dart';
import '../../../models/user.dart';
import '../../../services/payment.dart';

// recover camera position from google camera
class ReviewScreen extends StatelessWidget {
  ReviewScreen({
    Key key,
    this.insets = 1,
    this.actionCallback,
    this.isPickup = false,
  }) : super(key: key);

  final double insets;
  final HomeStateHandler actionCallback;
  final bool isPickup;
  static final double minHeight = 150;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      height: minHeight * insets,
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
              color: Colors.black,
              blurRadius: 20.0, // soften the shadow
              spreadRadius: 1.0, //extend the shadow
              offset: Offset(
                17.0, // Move to right 10  horizontally
                17.0, // Move to bottom 10 Vertically
              ),
            )
          ],
        ),
        child: Column(
          children: <Widget>[
            FlatButton(
              child: Text("edit"),
              onPressed: () {
                if (!isPickup) {
                  actionCallback(HomeState.PLAN_END, true);
                } else {
                  actionCallback(HomeState.PLAN_START, true);
                }
              },
            ),
            RaisedButton(
              child: Text("Confirm"),
              onPressed: () async {
                if (!isPickup) {
                  actionCallback(HomeState.RIDE, true);
                } else {
                  // Scaffold.of(context);
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (BuildContext context) => HomePage()));
                  var manager = PaymentManager(handleStatus: (m) {
                    _showMessage(context, m["message"]);
                  });

                  await manager.checkout(context, Invoice(), User());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  _showMessage(BuildContext context, String message,
      [Duration duration = const Duration(seconds: 5)]) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(message),
      duration: duration,
      action: new SnackBarAction(
          label: 'CLOSE',
          onPressed: () => Scaffold.of(context).removeCurrentSnackBar()),
    ));
  }
}
