import 'package:bolt_clone/blocs/authentication_bloc/bloc.dart';
import 'package:bolt_clone/routes/home/home.dart';
import 'package:bolt_clone/routes/login/login.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/blocs.dart';

class Splash extends StatefulWidget {
  Splash({
    Key key,
  }) : super(key: key);

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    BlocProvider.of<AuthenticationBloc>(context)
        .asBroadcastStream()
        .listen((event) {
      if (event is Authenticated) {
        _pushLogin();
        // _pushHome();
      } else if (event is Unauthenticated) {
        _pushLogin();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fadeInLogo = true;
      _controller.repeat(reverse: true);
    });
  }

  _pushLogin() async {
    var page = await _buidLoginAsync();
    var route = _loginRoute(page);
    _controller.stop();
    Navigator.of(context).pushReplacement(route);
  }

  _pushHome() async {
    var page = await _buidPageAsync();
    var route = _pushBuilder(page);
    _controller.stop();
    setState(() {
      translate = true;
    });
    Navigator.of(context).pushReplacement(route);
  }

  var translate = false;
  var fadeInLogo = false;

  _loginRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: 0.0, end: 1.0);
        var fadeAnimation = animation.drive(tween);
        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    );
  }

  _pushBuilder(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: Offset(1.0, 0.0), end: Offset.zero);
        var fadeAnimation = animation.drive(tween);
        return SlideTransition(
          position: fadeAnimation,
          child: child,
        );
      },
    );
  }

  Future<Widget> _buidPageAsync() async {
    return Future.microtask(() => Home(
          mapDelay: Duration(milliseconds: 700),
        ));
  }

  Future<Widget> _buidLoginAsync() async {
    return Future.microtask(() => Login());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get maxWidth => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          AnimatedPositioned(
            top: 0,
            bottom: 0,
            width: maxWidth,
            left: translate ? -maxWidth : 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.green
                    .withGreen(100 + (155 * _controller.value) ~/ 1),
                child: Center(
                  child: AnimatedOpacity(
                    opacity: fadeInLogo ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 800),
                    child: Hero(
                      tag: "logo",
                      child: Icon(
                        Icons.local_taxi,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            duration: Duration(milliseconds: 500),
          ),
        ],
      ),
    );
  }
}
