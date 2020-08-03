import 'package:bolt_clone/routes/home/home.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    KeyboardVisibilityNotification().addNewListener(
      onChange: (visible) {
        setState(() => isKeyboardVisible = visible);
        if (!visible && textFieldNode.hasFocus) {
          textFieldNode.unfocus();
        }
      },
    );
    textFieldNode.addListener(_handleFocusChange);
    super.initState();
  }

  bool isKeyboardVisible = false;
  FocusNode textFieldNode = FocusNode();

  _handleFocusChange() {
    setState(() {
      isKeyboardVisible = textFieldNode.hasFocus;
    });
  }

  Widget _getTextField() {
    return TextField(
      maxLines: 1,
      keyboardType: TextInputType.number,
      focusNode: textFieldNode,
      decoration: InputDecoration(
        hintText: "Phone number",
        contentPadding: EdgeInsets.only(
          top: 2,
          bottom: 2,
          left: 0,
          right: 0,
        ),
        isDense: true,
        hintStyle:
            TextStyle(fontSize: 22, color: Colors.grey, letterSpacing: 1),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[300],
            width: 0.5,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isKeyboardVisible ? Colors.green : Colors.grey[300],
            width: isKeyboardVisible ? 2 : 0.5,
          ),
        ),
      ),
      cursorColor: Colors.green,
      style: TextStyle(fontSize: 22),
      showCursor: isKeyboardVisible,
    );
  }

  Future<bool> _handlePopScope() {
    if (isKeyboardVisible) {
      textFieldNode.unfocus();
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
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
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          bottom: 100,
                          left: 40,
                          right: 40,
                          child: Text(
                            "Get started with your",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                                letterSpacing: 1),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              IgnorePointer(
                ignoring: !isKeyboardVisible,
                child: AnimatedOpacity(
                  opacity: isKeyboardVisible ? 1 : 0,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    color: Colors.white,
                    height: double.infinity,
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 25,
                      top: MediaQuery.of(context).viewInsets.top + 25,
                    ),
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: FlatButton(
                            padding: EdgeInsets.only(right: 30),
                            onPressed: () {
                              textFieldNode.unfocus();
                            },
                            child: Icon(Icons.arrow_back),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "You'll get an SMS to",
                                  style:
                                      TextStyle(fontSize: 18, letterSpacing: 1),
                                ),
                                Text(
                                  "confirm your number",
                                  style:
                                      TextStyle(fontSize: 18, letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Or login with Facebook",
                                  style:
                                      TextStyle(fontSize: 14, letterSpacing: 1),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 15, left: 25, right: 25),
                                  child: RaisedButton(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) => Home()));
                                    },
                                    child: Text(
                                      "NEXT",
                                      style: TextStyle(
                                          fontSize: 18, letterSpacing: 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.flag),
                    Container(
                      width: 65,
                      padding: EdgeInsets.only(right: 10, left: 5),
                      child: TextField(
                        maxLines: 1,
                        enabled: false,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "+234",
                          contentPadding: EdgeInsets.only(
                            top: 2,
                            bottom: 2,
                            left: 0,
                            right: 0,
                          ),
                          isDense: true,
                          hintStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              letterSpacing: 1),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[300],
                              width: isKeyboardVisible ? 2 : 0.5,
                            ),
                          ),
                        ),
                        style: TextStyle(fontSize: 18),
                        showCursor: isKeyboardVisible,
                      ),
                    ),
                    Expanded(
                      child: _getTextField(),
                    )
                  ],
                ),
                padding:
                    EdgeInsets.only(top: 200, bottom: 60, left: 40, right: 40),
                alignment: isKeyboardVisible
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
              ),
            ],
          ),
        ),
        onWillPop: _handlePopScope);
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
