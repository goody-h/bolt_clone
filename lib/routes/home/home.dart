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
import 'dart:math';

class Home extends StatefulWidget {
  Home({Key key, this.mapDelay = const Duration(milliseconds: 400)})
      : super(key: key);

  final Duration mapDelay;
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
      child: HomeMain(
        registerPop: _registerPop,
        mapDelay: widget.mapDelay,
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
  HomeMain({Key key, @required this.registerPop, this.mapDelay})
      : super(key: key);

  final void Function(BoolCallback) registerPop;
  final Duration mapDelay;

  @override
  HomeMainState createState() => HomeMainState();
}

class HomeMainState extends State<HomeMain>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController _iconController;
  AnimationController _controller;

  MenuButtonController menu;
  InsetController inset;
  CameraController camera;
  LocationButtonController locationBtn;
  MarkerController marker;
  LocationController location;

  @override
  void initState() {
    super.initState();

    menu = MenuButtonController(
      controller: AnimationController(
        vsync: this,
        value: 0,
        duration: Duration(milliseconds: 300),
      ),
      registerPop: widget.registerPop,
    );

    inset = InsetController(
      controller: AnimationController(
        vsync: this,
        value: 0.4,
        lowerBound: 0.4,
        upperBound: 1,
        duration: Duration(milliseconds: 300),
      ),
      hasInit: hasInit,
    );

    camera = CameraController(controller: mapController);

    locationBtn = LocationButtonController();

    marker = MarkerController();

    location = LocationController();

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
      Future.delayed(widget.mapDelay, () {
        loadMap.complete(true);
        setState(() {});
      });
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  Completer<bool> hasInit = Completer();
  Completer<bool> loadMap = Completer();

  @override
  void dispose() {
    _iconController.dispose();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Initial location of the Map view
  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(0.0, 0.0), zoom: 10);

  final Geolocator _geolocator = Geolocator();
  // For storing the current position
  Position _currentPosition;

  // For controlling the view of the Map
  Completer<GoogleMapController> mapController = Completer();

  // Method for retrieving the current location
  Future<Position> _getCurrentLocation() async {
    final position = await _geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    _currentPosition = position;
    return position;
  }

  __animateToCurrentPosition() async {
    final map = await mapController.future;
    try {
      final position = await _getCurrentLocation();
      setState(() {
        // Store the position in the variable
        _currentPosition = position;

        print('CURRENT POS: $_currentPosition');

        // For moving the camera to current location
        map.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17.2,
            ),
          ),
        );
      });
    } catch (e) {
      print(e);
    }
  }

  _animateToCurrentPosition() async {
    try {
      Position otherPosition = Position(
        latitude: 4.902008,
        longitude: 7.005,
      );
      final map = await mapController.future;

      final position = await _getCurrentLocation();
      setState(() {
        print('FIT POS: $otherPosition');
        // Define two position variables
        Position _northeastCoordinates;
        Position _southwestCoordinates;

        // Calculating to check that
        // southwest coordinate <= northeast coordinate
        if (otherPosition.latitude <= position.latitude) {
          _southwestCoordinates = otherPosition;
          _northeastCoordinates = position;
        } else {
          _southwestCoordinates = position;
          _northeastCoordinates = otherPosition;
        }

        map.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                _northeastCoordinates.latitude,
                _northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                _southwestCoordinates.latitude,
                _southwestCoordinates.longitude,
              ),
            ),
            50.0, // padding
          ),
        );
      });
    } catch (e) {
      print(e);
    }
  }

  Set<Marker> markers = {
    Marker(
      markerId: MarkerId('vvvvvv'),
      position: LatLng(
        4.902008,
        7.005,
      ),
      infoWindow: InfoWindow(
        title: 'Destination',
        snippet: "Destination Address",
      ),
      icon: BitmapDescriptor.defaultMarker,
    )
  };

  final defaultZoom = 16.95;
  final destinationZoom = 15;
  final pickupZoom = 17;
  final assigningZoom = 17.2;

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

  Set<Marker> _buildMarkers(BuildContext context, TripState state) {}

  BoolCallback onPopCallback;

  @override
  Widget build(BuildContext context) {
    print("render");
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
          BlocBuilder<TripBloc, TripState>(
            builder: (context, state) {
              if (!loadMap.isCompleted) {
                return Container();
              }
              final markers = _buildMarkers(context, state);

              return GoogleMap(
                initialCameraPosition: _initialLocation,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  mapController.complete(controller);
                  _animateToCurrentPosition();
                },
                onCameraMove: (CameraPosition position) {
                  // print(position.target);
                },
                onCameraIdle: () {},
                padding:
                    EdgeInsets.only(bottom: (_bottomInset) * _animateInset),
                markers: markers != null ? Set<Marker>.from(markers) : null,
              );
            },
          ),
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
                onPressed: _animateToCurrentPosition,
                child: Icon(
                  Icons.my_location,
                  color: Colors.black,
                ),
                mini: true,
              ),
              visible: !transferControl,
            ),
          ),
          HomeMainScreen(
            child: HomeScreen(
              inset: _animateInset,
              setInset: _setBottomInset,
              registerOnPop: _registerPop,
            ),
            context: context,
            menu: menu,
            inset: inset,
            camera: camera,
            locationBtn: locationBtn,
            marker: marker,
            location: location,
            setState: () => setState(() {}),
          ),
        ],
      ),
    );
  }
}

// microcontrollers
class LocationButtonController {
  bool isVisible = true;
}

class MenuButtonController {
  AnimationController controller;
  Function(BoolCallback) registerPop;
  Function(BuildContext) onClick;
  BoolCallback _onPopCallback;
  bool _canPop = false;

  MenuButtonController({this.controller, this.registerPop}) {
    onClick = _openDrawer;
  }

  registerOnPop(BoolCallback onPop) {
    _onPopCallback = onPop;
    registerPop(onPop);
  }

  setCanPop(bool canPop) {
    if (canPop != _canPop) {
      _canPop = canPop;
      onClick = _canPop && _onPopCallback != null
          ? (context) => _onPopCallback()
          : _openDrawer;
      _canPop ? controller.forward() : controller.reverse();
    }
  }

  _openDrawer(BuildContext context) => Scaffold.of(context).openDrawer();
}

class SelectionPinController {
  bool isVisible = false;
  bool isPinMoving = false;
  bool isPickup;
  LatLng position;
  String pinAddress;

  initPin({bool isPickup, LatLng position}) {
    this.isPickup = isPickup;
    this.position = position;
  }

  movePinPosition(LatLng position) {
    this.position = position;
  }

  updatePinPosition(BuildContext context) {
    // send event to TripBloc
  }
}

class CameraController {
  Completer<GoogleMapController> controller;
  List<LatLng> positionVectors;
  double zoom;

  CameraController({this.controller});

  justifyCamera({List<LatLng> positionVectors, double zoom}) async {
    this.positionVectors = positionVectors ?? this.positionVectors;
    this.zoom = zoom ?? this.zoom;
    if (this.positionVectors == null ||
        this.positionVectors.length == 0 ||
        this.zoom == null) return;

    final map = await controller.future;

    final CameraUpdate update =
        positionVectors.length > 1 ? _getBounds() : _getPosition();

    map.animateCamera(update);
  }

  CameraUpdate _getPosition() {
    return CameraUpdate.newCameraPosition(
      CameraPosition(
        target: positionVectors[0],
        zoom: zoom,
      ),
    );
  }

  CameraUpdate _getBounds() {
    final bounds = positionVectors.fold<List<double>>(
      [
        positionVectors[0].latitude, // max latitude
        positionVectors[0].longitude, // max longitude
        positionVectors[0].latitude, // min latitude
        positionVectors[0].longitude // min longitude
      ],
      (previous, element) => [
        max(previous[0], element.latitude),
        max(previous[1], element.longitude),
        min(previous[2], element.latitude),
        min(previous[2], element.longitude)
      ],
    );

    return CameraUpdate.newLatLngBounds(
      LatLngBounds(
        northeast: LatLng(
          bounds[0],
          bounds[1],
        ),
        southwest: LatLng(
          bounds[2],
          bounds[3],
        ),
      ),
      50.0, // padding
    );
  }
}

class InsetController {
  AnimationController controller;
  double _baseBottomInset;
  Completer<bool> hasInit;

  InsetController({this.controller, this.hasInit});

  double get inset => _baseBottomInset * controller.value;

  setBaseInset(double inset, {bool shouldAnimate}) async {
    await hasInit.future;
    if (shouldAnimate) {
      controller.value = 0.4;
      controller.forward();
    } else {
      controller.value = 0.99;
      controller.value = 1;
    }
  }
}

class MarkerController {
  bool showDrivers;
}

class LocationController {
  final Geolocator _geolocator = Geolocator();
  Position _location;
  LocationController() {
    _geolocator
        .getPositionStream(
            LocationOptions(accuracy: LocationAccuracy.bestForNavigation))
        .listen((position) {
      _location = position;
    });
  }

  Future<LatLng> get location async {
    if (_location == null) {
      _location = await _geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
    }
    return LatLng(_location.latitude, _location.longitude);
  }
}

class HomeMainScreen extends InheritedWidget {
  HomeMainScreen({
    Widget child,
    this.context,
    this.menu,
    this.setState,
    this.inset,
    this.camera,
    this.locationBtn,
    this.marker,
    this.location,
  }) : super(child: child);

  final BuildContext context;
  final MenuButtonController menu;
  final InsetController inset;
  final VoidCallback setState;
  final LocationButtonController locationBtn;
  final CameraController camera;
  final MarkerController marker;
  final LocationController location;

  TripBloc getTrip() => BlocProvider.of<TripBloc>(context);
  UserBloc getUser() => BlocProvider.of<UserBloc>(context);

  setDefaultView({bool isExpanded = false, bool isChanging = false}) async {
    //(double inset, bool animate, bool hasControl)
    if (!isExpanded) {
      final myLocation = await location.location;
      getTrip().add(TripRequestInit(myLocation));
    }
    if (!isChanging) {
      menu.setCanPop(false);
      locationBtn.isVisible = true;
      inset.setBaseInset(250, shouldAnimate: !isExpanded);
      marker.showDrivers = true;
      setState();

      final myLocation = await location.location;
      final user = getUser().state;
      final pVectors = [myLocation];

      if (user is UserLoaded) {
        pVectors.addAll([user.user.home, user.user.work]
            .where((p) => p != null)
            .map((p) => LatLng(p.latitude, p.longitude)));
      }
      camera.justifyCamera(positionVectors: pVectors, zoom: 16.95);
    }
  }

  setChooseDestinationView() {}

  setCoosePickupView() {}

  setDetailsView() {}

  setReviewView() {}
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static HomeMainScreen of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeMainScreen>();
}
