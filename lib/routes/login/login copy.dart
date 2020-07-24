import 'package:bolt_clone/routes/home/home.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: ClipPath(
                  clipper: BackClip(),
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.green,
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Hero(
                            tag: "logo",
                            child: Icon(
                              Icons.local_taxi,
                              color: Colors.white,
                              size: 100,
                            ),
                          ),
                          Container(
                            width: 70,
                            child: Divider(
                              height: 65,
                              color: Colors.white,
                              thickness: 3,
                            ),
                          ),
                          Text(
                            "Tap a button,",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                          ),
                          Text(
                            "get a journey",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Center(
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => Home(),
                        ));
                      },
                      child: Text("Login"),
                    ),
                  )),
            ],
          ),
          Positioned(
            child: MediaQuery(
                data: MediaQuery.of(context),
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: TextField(
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                  ),
                )),
            bottom: 50,
            left: 0,
            right: 0,
          )
        ],
      ),
    );
  }
}

class BackClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height - (tan(pi * 6 / 180) * size.width));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(BackClip clipper) {
    return true;
  }
}
