import 'package:flutter/material.dart';
import '../models.dart';
import '../../../resources/payment.dart';

import 'package:data_repository/data_repository.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/blocs.dart';

// recover camera position from google camera
class DestinationScreen extends StatelessWidget {
  DestinationScreen({
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
                  var manager = PaymentProvider(handleStatus: (m) {
                    _showMessage(context, m["message"]);
                  });
                  final state = BlocProvider.of<UserBloc>(context).state;
                  if (state is UserLoaded) {
                    await manager.checkout(context, Invoice(), state.user);
                  }
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
