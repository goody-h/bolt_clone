import 'dart:async';
import 'package:bolt_clone/blocs/trip_bloc/trip.dart';
import 'package:bolt_clone/routes/home/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/types.dart';
import './screen.dart';

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
        resizeToAvoidBottomInset: false,
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
  TripBloc trip;
  MenuButtonController menu;
  InsetController inset;
  CameraController camera;
  LocationButtonController locationBtn;
  MarkerController marker;
  LocationController location;
  SelectionPinController pin;
  RouteController route;

  @override
  void initState() {
    super.initState();
    trip = TripBloc(
      dataRepository: BlocProvider.of<UserBloc>(context).dataRepository,
    );
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

    pin = SelectionPinController();

    route = RouteController(trip: trip);

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
    inset.dispose();
    menu.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Initial location of the Map view
  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(0.0, 0.0), zoom: 10);

  Completer<GoogleMapController> mapController = Completer();

  @override
  Widget build(BuildContext context) {
    print("render");
    return MultiBlocProvider(
      providers: [
        BlocProvider<TripBloc>(
          create: (context) {
            return trip..add(LoadTrip());
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
              final markers = marker.getMarkers(context, state);

              final polylines = route.getRoute();

              return StreamBuilder<double>(
                  initialData: inset._baseBottomInset,
                  stream: inset.stream,
                  builder: (context, data) {
                    return GoogleMap(
                      initialCameraPosition: _initialLocation,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      zoomGesturesEnabled: true,
                      zoomControlsEnabled: false,
                      onMapCreated: (GoogleMapController controller) async {
                        mapController.complete(controller);
                        try {
                          final List<LatLng> positions =
                              camera.positionVectors ??
                                  [await location.location];
                          camera.justifyCamera(
                              positionVectors: positions, zoom: 16.95);
                        } catch (e) {
                          print(e);
                        }
                      },
                      onCameraMove: (CameraPosition position) {
                        pin.movePinPosition(position.target);
                      },
                      onCameraIdle: () {
                        pin.updatePinPosition(context);
                      },
                      padding: EdgeInsets.only(bottom: inset._baseBottomInset),
                      markers:
                          markers != null ? Set<Marker>.from(markers) : null,
                      polylines: polylines != null
                          ? Set<Polyline>.from(polylines)
                          : null,
                    );
                  });
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
                    onPressed: () => menu.onClick(context),
                    child: AnimatedIcon(
                      icon: AnimatedIcons.menu_arrow,
                      progress: menu.controller,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: inset.controller,
            builder: (context, child) {
              return Stack(
                children: <Widget>[
                  Positioned(
                    bottom: 15 + inset.inset,
                    right: 15,
                    child: Visibility(
                      child: FloatingActionButton(
                        heroTag: "location",
                        backgroundColor: Colors.white,
                        onPressed: camera.justifyCamera,
                        child: Icon(
                          Icons.my_location,
                          color: Colors.black,
                        ),
                        mini: true,
                      ),
                      visible: locationBtn.isVisible,
                    ),
                  )
                ],
              );
            },
          ),
          HomeMainScreen(
            child: HomeScreen(),
            context: context,
            trip: trip,
            menu: menu,
            inset: inset,
            camera: camera,
            locationBtn: locationBtn,
            marker: marker,
            location: location,
            pin: pin,
            route: route,
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

  dispose() {
    controller.dispose();
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
  LatLng _positionHolder;
  String pinAddress;

  initPin({bool isPickup, LatLng position}) {
    this.isPickup = isPickup;
    this.isVisible = true;
    this.position = position;
    _positionToAddress();
  }

  disable() {
    isVisible = false;
    pinAddress = null;
    position = null;
    _positionHolder = null;
  }

  movePinPosition(LatLng position) {
    print("move pin $position");
    if (isVisible) {
      this._positionHolder = position;
    }
  }

  updatePinPosition(BuildContext context) {
    print("set pin $position");
    if (isVisible) {
      if (position != _positionHolder) {
        // send event to TripBloc
        _positionToAddress();
      }
    }
  }

  _positionToAddress() {}
}

class CameraController {
  Completer<GoogleMapController> controller;
  List<LatLng> positionVectors;
  double zoom;

  CameraController({this.controller});

  justifyCamera({List<LatLng> positionVectors, double zoom}) async {
    this.positionVectors = positionVectors ?? this.positionVectors;
    this.zoom = zoom ?? this.zoom;

    print(this.positionVectors);
    if (this.positionVectors == null ||
        this.positionVectors.length == 0 ||
        this.zoom == null) return;

    final map = await controller.future;

    final CameraUpdate update =
        (this.positionVectors?.length ?? 0) > 1 ? _getBounds() : _getPosition();
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
        min(previous[3], element.longitude)
      ],
    );

    print("bounds $bounds");

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
  final streamController = StreamController<double>.broadcast();
  double _baseBottomInset = DefaultScreen.minHeight;
  String tag;
  Completer<bool> hasInit;

  InsetController({this.controller, this.hasInit}) {
    setBaseInset("default", _baseBottomInset, shouldAnimate: true);
  }

  double get inset => _baseBottomInset * controller.value;

  Stream<double> get stream => streamController.stream;

  setBaseInset(String tag, double inset, {bool shouldAnimate}) async {
    if (tag != this.tag) {
      this.tag = tag;
      this._baseBottomInset = inset;
      await hasInit.future;
      streamController.sink.add(inset);
      if (shouldAnimate) {
        controller.value = 0.4;
        controller.forward();
      } else {
        controller.value = 0.99;
        controller.value = 1;
      }
    }
  }

  dispose() {
    controller.dispose();
    streamController.close();
  }
}

class MarkerController {
  bool showDrivers = true;
  bool showPickupAndDestination = false;
  bool showHomeAndWork = true;

  Set<Marker> getMarkers(BuildContext context, TripState state) {
    // get marker
    final user = BlocProvider.of<UserBloc>(context).state;
    Set<Marker> markers;

    if (user is UserLoaded && showHomeAndWork) {
      markers = Set<Marker>();
      markers.addAll([user.user.home, user.user.work]
          .where((p) => p != null)
          .map((p) => LatLng(p.latitude, p.longitude))
          .map((pos) => marker(pos)));
    }

    return markers;
  }

  Marker marker(LatLng pos) {
    return Marker(
      markerId: MarkerId('vvvvvv'),
      position: pos,
      infoWindow: InfoWindow(
        title: 'Destination',
        snippet: "Destination Address",
      ),
      icon: BitmapDescriptor.defaultMarker,
    );
  }
}

class RouteController {
  TripBloc trip;
  bool isVisible = false;

  RouteController({this.trip}) {
    trip.asBroadcastStream().listen((state) async {
      if (state is TripRequest &&
          state.request.destination != null &&
          state.request.pickUp != null &&
          state.request.distance == null) {
        // calculate distance
      }
    });
  }

  _plotTrip() {}

  _calculateDistance() {}

  _setDistance() {}

  Set<Polyline> getRoute() {
    return null;
  }
}

class LocationController {
  final Geolocator _geolocator = Geolocator();
  Position _location;
  LocationController() {
    _geolocator
        .getPositionStream(LocationOptions(
            accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 100))
        .listen((position) {
      _location = position;
      print("location update $_location");
    });
  }

  Future<LatLng> get location async {
    if (_location == null) {
      _location = await _geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      print("location $_location");
    }
    return LatLng(_location.latitude, _location.longitude);
  }
}

class HomeMainScreen extends InheritedWidget {
  HomeMainScreen({
    Widget child,
    this.trip,
    this.context,
    this.menu,
    this.setState,
    this.inset,
    this.camera,
    this.locationBtn,
    this.marker,
    this.location,
    this.pin,
    this.route,
  }) : super(child: child);

  final TripBloc trip;
  final BuildContext context;
  final MenuButtonController menu;
  final InsetController inset;
  final VoidCallback setState;
  final LocationButtonController locationBtn;
  final CameraController camera;
  final MarkerController marker;
  final LocationController location;
  final SelectionPinController pin;
  final RouteController route;

  TripBloc getTrip() => trip;
  UserBloc getUser() => BlocProvider.of<UserBloc>(context);

  final defaultZoom = 16.95;
  final destinationZoom = 15.0;
  final pickupZoom = 17.0;
  final assigningZoom = 17.2;

  setDefaultView({bool isExpanded = false, bool isChanging = false}) async {
    if (!isExpanded) {
      final myLocation = await location.location;
      getTrip().add(TripRequestInit(myLocation));
    }
    if (!isChanging) {
      menu.setCanPop(false);
      locationBtn.isVisible = true;
      inset.setBaseInset("default", DefaultScreen.minHeight,
          shouldAnimate: !isExpanded);
      marker.showDrivers = true;
      marker.showHomeAndWork = true;
      marker.showPickupAndDestination = false;
      // more marker update
      pin.disable();
      route.isVisible = false;
      setState();

      final myLocation = await location.location;
      final user = getUser().state;
      final pVectors = [myLocation];

      if (user is UserLoaded) {
        pVectors.addAll([user.user.home, user.user.work]
            .where((p) => p != null)
            .map((p) => LatLng(p.latitude, p.longitude)));
      }
      camera.justifyCamera(positionVectors: pVectors, zoom: defaultZoom);
    }
  }

  setChooseDestinationView() async {
    final myLocation = await location.location;

    menu.setCanPop(true);
    locationBtn.isVisible = false;
    inset.setBaseInset("dest", DestinationScreen.minHeight,
        shouldAnimate: false);
    marker.showDrivers = false;
    marker.showHomeAndWork = false;
    marker.showPickupAndDestination = false;
    // more marker update

    pin.initPin(isPickup: false, position: myLocation);
    route.isVisible = false;
    setState();

    final pVectors = [myLocation];

    camera.justifyCamera(positionVectors: pVectors, zoom: destinationZoom);
  }

  setCoosePickupView() async {
    final myLocation = await location.location;
    // possibly shift location slightly

    menu.setCanPop(true);
    locationBtn.isVisible = true;
    inset.setBaseInset("pick", PickupScreen.minHeight, shouldAnimate: false);
    marker.showDrivers = false;
    marker.showHomeAndWork = false;
    marker.showPickupAndDestination = false;
    // more marker update

    pin.initPin(isPickup: true, position: myLocation);
    route.isVisible = false;
    setState();

    final pVectors = [myLocation];

    camera.justifyCamera(positionVectors: pVectors, zoom: pickupZoom);
  }

  setDetailsView({bool isChanging = false}) async {
    if (!isChanging) {
      menu.setCanPop(true);
      locationBtn.isVisible = false;
      inset.setBaseInset("details", DetailsScreen.minHeight,
          shouldAnimate: true);
      marker.showDrivers = true;
      marker.showHomeAndWork = false;
      marker.showPickupAndDestination = true;
      // more marker update
      pin.disable();
      route.isVisible = true;
      setState();

      final myLocation = await location.location;
      final trip = getTrip().state;
      final pVectors = [myLocation];

      if (trip is TripRequest) {
        pVectors.addAll([trip.request.destination, trip.request.pickUp]
            .where((p) => p != null)
            .map((p) => LatLng(p.latitude, p.longitude)));
      }
      camera.justifyCamera(positionVectors: pVectors, zoom: 15.0);
    }
  }

  setReviewView() async {
    final trip = getTrip().state;
    var position = await location.location;
    if (trip is TripRequest) {
      final pickupLocation = trip.request.pickUp;
      position = LatLng(pickupLocation.latitude, pickupLocation.longitude);
    }
    // possibly shift location slightly

    menu.setCanPop(true);
    locationBtn.isVisible = true;
    inset.setBaseInset("review", ReviewScreen.minHeight, shouldAnimate: true);
    marker.showDrivers = false;
    marker.showHomeAndWork = false;
    marker.showPickupAndDestination = false;
    // more marker update

    pin.initPin(isPickup: true, position: position);
    route.isVisible = false;
    setState();

    final pVectors = [position];

    camera.justifyCamera(positionVectors: pVectors, zoom: pickupZoom);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static HomeMainScreen of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeMainScreen>();
}
