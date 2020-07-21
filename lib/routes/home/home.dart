import 'dart:async';
import 'package:bolt_clone/blocs/trip_bloc/trip.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/types.dart';
import './screen.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/blocs.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  _registerPop(BoolCallback callback) {
    onPopCallback = callback;
  }

  BoolCallback onPopCallback;

  @override
  Widget build(BuildContext context) {
    return HomeScaffold(
      onBackPressed: _onBackPressed,
      drawer: HomeDrawer(),
      child: HomeMain(registerPop: _registerPop),
    );
  }

  Future<bool> _onBackPressed() {
    // return showDialog(
    //       context: context,
    //       builder: (context) => new AlertDialog(
    //         title: new Text('Are you sure?'),
    //         content: new Text('Do you want to exit an App'),
    //         actions: <Widget>[
    //           new GestureDetector(
    //             onTap: () => Navigator.of(context).pop(false),
    //             child: Text("NO"),
    //           ),
    //           SizedBox(height: 16),
    //           new GestureDetector(
    //             onTap: () => Navigator.of(context).pop(true),
    //             child: Text("YES"),
    //           ),
    //         ],
    //       ),
    //     ) ??
    bool shouldPop = onPopCallback() && true;
    return Future.value(shouldPop);
  }
}

typedef BoolCallbackAsync = Future<bool> Function();

class HomeScaffold extends StatelessWidget {
  HomeScaffold({Key key, this.child, this.drawer, this.onBackPressed})
      : super(key: key);
  final Widget child;
  final Widget drawer;
  final BoolCallbackAsync onBackPressed;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        drawer: Drawer(
          child: drawer,
        ),
        drawerEnableOpenDragGesture: false,
        body: child,
      ),
    );
  }
}

class HomeDrawer extends StatelessWidget {
  _closeDrawer(BuildContext context) => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('This is the Drawer'),
          RaisedButton(
            onPressed: () => _closeDrawer(context),
            child: const Text('Close Drawer'),
          ),
        ],
      ),
    );
  }
}

class HomeMain extends StatefulWidget {
  HomeMain({Key key, @required this.registerPop}) : super(key: key);

  final void Function(BoolCallback) registerPop;

  @override
  HomeMainState createState() => HomeMainState();
}

class HomeMainState extends State<HomeMain> with TickerProviderStateMixin {
  AnimationController _iconController;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      value: 0,
      duration: Duration(milliseconds: 300),
    );

    _controller = AnimationController(
      vsync: this,
      value: 0.4,
      lowerBound: 0.4,
      upperBound: 1,
      duration: Duration(milliseconds: 300),
    );

    _controller.addListener(() {
      setState(() {
        _animateInset = _controller.value;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      hasInit.complete(true);
      Future.delayed(Duration(milliseconds: 700), () {
        loadMap.complete(true);
        setState(() {});
      });
    });
  }

  Completer<bool> hasInit = Completer();
  Completer<bool> loadMap = Completer();

  @override
  void dispose() {
    _iconController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Initial location of the Map view
  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(0.0, 0.0), zoom: 10);

  final Geolocator _geolocator = Geolocator();
  // For storing the current position
  Position _currentPosition;

  // For controlling the view of the Map
  GoogleMapController mapController;

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
        _currentPosition = position;

        print('CURRENT POS: $_currentPosition');

        // For moving the camera to current location
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14.0,
            ),
          ),
        );
      });
    }).catchError((e) {
      print(e);
    });
  }

  double _bottomInset = DefaultScreen.minHeight;
  double _animateInset = 0.4;
  bool transferControl = false;

  _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  _setBottomInset(double inset, bool animate, bool hasControl) async {
    _bottomInset = inset;

    await hasInit.future;

    if (hasControl != transferControl) {
      transferControl = hasControl;
      if (transferControl)
        _iconController.forward();
      else
        _iconController.reverse();
    }

    if (animate) {
      _controller.value = 0.4;
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  _handleActionButton(BuildContext context) {
    if (transferControl) return onPopCallback();
    _openDrawer(context);
  }

  _registerPop(BoolCallback callback) {
    onPopCallback = callback;
    widget.registerPop(callback);
  }

  BoolCallback onPopCallback;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TripBloc>(
          create: (context) {
            return TripBloc(
              dataRepository: BlocProvider.of<UserBloc>(context).dataRepository,
            )..add(LoadTrip());
          },
        ),
      ],
      child: Stack(
        children: <Widget>[
          loadMap.isCompleted
              ? GoogleMap(
                  initialCameraPosition: _initialLocation,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    _getCurrentLocation();
                  },
                  onCameraMove: (CameraPosition position) {},
                  onCameraIdle: () {},
                  padding:
                      EdgeInsets.only(bottom: (_bottomInset) * _animateInset),
                )
              : Container(),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Transform.scale(
                  scale: 0.85,
                  origin: Offset(0, 0),
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: () => _handleActionButton(context),
                    child: AnimatedIcon(
                      icon: AnimatedIcons.menu_arrow,
                      progress: _iconController,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 15 + _bottomInset * _animateInset,
            right: 15,
            child: Visibility(
              child: FloatingActionButton(
                heroTag: "location",
                backgroundColor: Colors.white,
                onPressed: _getCurrentLocation,
                child: Icon(
                  Icons.my_location,
                  color: Colors.black,
                ),
                mini: true,
              ),
              visible: !transferControl,
            ),
          ),
          HomeScreen(
            inset: _animateInset,
            setInset: _setBottomInset,
            registerOnPop: _registerPop,
          ),
        ],
      ),
    );
  }
}
