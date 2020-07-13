import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import './action-sheet.dart';
import './bool-callback.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with TickerProviderStateMixin {
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
  }

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
              zoom: 18.0,
            ),
          ),
        );
      });
    }).catchError((e) {
      print(e);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double _bottomInset = 0;
  double _animateInset = 0.4;
  bool transferControl = false;

  _openDrawer() {
    _scaffoldKey.currentState.openDrawer();
  }

  _setBottomInset(double inset, bool animate, bool hasControl) {
    _bottomInset = inset;

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

  _closeDrawer() {
    Navigator.of(context).pop();
  }

  _handleActionButton() {
    if (transferControl) return onPopCallback();
    _openDrawer();
  }

  _registerPop(BoolCallback callback) {
    onPopCallback = callback;
  }

  BoolCallback onPopCallback;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('This is the Drawer'),
                RaisedButton(
                  onPressed: _closeDrawer,
                  child: const Text('Close Drawer'),
                ),
              ],
            ),
          ),
        ),
        drawerEnableOpenDragGesture: false,
        body: Stack(
          children: <Widget>[
            GoogleMap(
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
                  EdgeInsets.only(bottom: (_bottomInset + 10) * _animateInset),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: _handleActionButton,
                    child: AnimatedIcon(
                      icon: AnimatedIcons.menu_arrow,
                      progress: _iconController,
                      color: Colors.black,
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
            ActionSheet(
              inset: _animateInset,
              setInset: _setBottomInset,
              registerOnPop: _registerPop,
            ),
          ],
        ),
      ),
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
