import 'package:bolt_clone/routes/home/home.dart';
import 'package:flutter/material.dart';
import '../models.dart';
import '../../../resources/payment.dart';

import 'package:data_repository/data_repository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/blocs.dart';

// recover camera position from google camera
class ReviewScreen extends StatelessWidget {
  ReviewScreen({
    Key key,
    this.actionCallback,
  }) : super(key: key);

  final HomeStateHandler actionCallback;
  static final double minHeight = 210;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: HomeMainScreen.of(context).inset.controller,
      builder: (context, child) {
        return Stack(
          children: <Widget>[
            Positioned(
              height:
                  minHeight * HomeMainScreen.of(context).inset.controller.value,
              left: 0,
              right: 0,
              bottom: 0,
              child: child,
            )
          ],
        );
      },
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
                "Confirm pickup",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12, bottom: 12),
                child: Text("Pickup in 1 min  N850"),
              ),
              Divider(height: 1),
              SizedBox(
                height: 55,
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.album, size: 14, color: Colors.green),
                    Container(width: 10),
                    Text(
                      'Unnamed Road',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Spacer(flex: 1),
                    SizedBox(
                      height: 55,
                      width: 55,
                      child: FlatButton(
                        onPressed: () {
                          actionCallback(HomeState.PLAN_START, true);
                        },
                        shape: CircleBorder(side: BorderSide.none),
                        child: Icon(Icons.edit),
                      ),
                    ),
                  ],
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
                    "CONFIRM ORDER",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () async {
                    var manager = PaymentProvider(handleStatus: (m) {
                      _showMessage(context, m["message"]);
                    });
                    final state = BlocProvider.of<UserBloc>(context).state;
                    print(state);
                    if (state is UserLoaded) {
                      await manager.checkout(context, Invoice(), state.user);
                    }
                  },
                ),
              ),
            ],
          ),
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
