import 'dart:async';
import 'package:bolt_clone/blocs/trip_bloc/trip.dart';
import 'package:bolt_clone/routes/home/map.dart';
import 'package:bolt_clone/routes/home/widgets/drop_pin.dart';
import 'package:bolt_clone/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/types.dart';
import 'screen.dart';

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

    location = LocationController(camera);

    pin = SelectionPinController(setState: () => setState(() {}));

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

  Completer<GoogleMapController> mapController = Completer();

  @override
  Widget build(BuildContext context) {
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
          Positioned.fill(
            child: Map(
              loadMap: loadMap.isCompleted,
              onLoad: (GoogleMapController controller) async {
                mapController.complete(controller);
              },
              pin: pin,
              marker: marker,
              route: route,
              baseBottomInset: inset._baseBottomInset,
            ),
          ),
          Visibility(
            visible: pin.isVisible,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              padding: EdgeInsets.only(bottom: inset._baseBottomInset),
              child: Center(
                child: DropPin(
                  isDown: pin.isDown,
                  isDestination: !pin.isPickup,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: FloatingActionButton(
                    backgroundColor: AppColors.white,
                    onPressed: () => menu.onClick(context),
                    child: AnimatedIcon(
                      icon: AnimatedIcons.menu_arrow,
                      progress: menu.controller,
                      color: AppColors.blackLight,
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
                        backgroundColor: AppColors.white,
                        onPressed: camera.justifyCamera,
                        child: Icon(
                          Icons.my_location,
                          color: AppColors.black,
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
  bool isDown = true;
  LatLng position;
  LatLng _positionHolder;
  String pinAddress;
  AddressSearchType type;
  final VoidCallback setState;

  SelectionPinController({this.setState});

  bool get isPickup => !(type?.isDestination ?? true);

  initPin({AddressSearchType type, LatLng position}) {
    this.type = type;
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

  setIsDown(bool isDown) {
    if (this.isDown != isDown) {
      this.isDown = isDown;
      setState();
    }
  }

  movePinPosition(LatLng position) {
    print("move pin $position");
    if (isVisible) {
      this._positionHolder = position;
      setIsDown(false);
    }
  }

  updatePinPosition(BuildContext context) {
    print("set pin $position");
    if (isVisible) {
      if (position != _positionHolder) {
        // send event to TripBloc
        _positionToAddress();
      }
      setIsDown(true);
    }
  }

  _positionToAddress() {}
}

class CameraController {
  Completer<GoogleMapController> controller;
  List<LatLng> positionVectors = [LatLng(0.0, 0.0)];
  bool hasLayout = false;
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
  double _baseBottomInset = DefaultSearchScreen.minHeight;
  String tag;
  Completer<bool> hasInit;

  InsetController({this.controller, this.hasInit}) {
    setBaseInset("default", _baseBottomInset, shouldAnimate: true);
  }

  // double get inset => _baseBottomInset * controller.value;
  double get inset => _baseBottomInset;

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
          state.request.stops != null &&
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
  final CameraController controller;
  bool canMoveMap = true;
  Position _location;
  LocationController(this.controller) {
    _geolocator
        .getPositionStream(LocationOptions(
            accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 100))
        .listen((position) {
      _location = position;
      controller.positionVectors[0] =
          LatLng(position.latitude, position.longitude);
      if (canMoveMap && controller.hasLayout) {
        controller.justifyCamera();
      }
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

  final mapDuration = Duration(milliseconds: 700);

  setDefaultView({bool isExpanded = false, bool isChanging = false}) async {
    if (!isExpanded) {
      final myLocation = await location.location;
      getTrip().add(TripRequestInit(myLocation));
    }
    if (!isChanging) {
      menu.setCanPop(false);
      locationBtn.isVisible = true;
      inset.setBaseInset("default", DefaultSearchScreen.minHeight,
          shouldAnimate: !isExpanded);
      marker.showDrivers = true;
      marker.showHomeAndWork = true;
      marker.showPickupAndDestination = false;
      // more marker update
      pin.disable();
      location.canMoveMap = true;
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
      if (camera.hasLayout) {
        Future.delayed(
          mapDuration,
          () => camera.justifyCamera(
              positionVectors: pVectors, zoom: defaultZoom),
        );
      } else {
        camera.justifyCamera(positionVectors: [myLocation], zoom: defaultZoom);
        await camera.controller.future;
        Future.delayed(
          Duration(seconds: 3),
          () {
            camera.hasLayout = true;
            pVectors[0] = camera.positionVectors[0];
            camera.justifyCamera(positionVectors: pVectors, zoom: defaultZoom);
          },
        );
      }
    }
  }

  setChooseDestinationView(AddressSearchType type) async {
    final myLocation = await location.location;

    menu.setCanPop(true);
    locationBtn.isVisible = false;
    inset.setBaseInset("dest", MapPickScreen.minHeight, shouldAnimate: false);
    marker.showDrivers = false;
    marker.showHomeAndWork = false;
    marker.showPickupAndDestination = false;
    // more marker update

    location.canMoveMap = false;
    pin.initPin(type: type, position: myLocation);
    route.isVisible = false;
    setState();

    final pVectors = [myLocation];

    Future.delayed(
      mapDuration,
      () => camera.justifyCamera(
          positionVectors: pVectors, zoom: destinationZoom),
    );
  }

  setCoosePickupView() async {
    final myLocation = await location.location;
    // possibly shift location slightly

    menu.setCanPop(true);
    locationBtn.isVisible = true;
    inset.setBaseInset("pick", MapPickScreen.minHeight, shouldAnimate: false);
    marker.showDrivers = false;
    marker.showHomeAndWork = false;
    marker.showPickupAndDestination = false;
    // more marker update

    location.canMoveMap = false;
    pin.initPin(type: AddressSearchType(addressIndex: 0), position: myLocation);
    route.isVisible = false;
    setState();

    final pVectors = [myLocation];

    Future.delayed(
      mapDuration,
      () => camera.justifyCamera(positionVectors: pVectors, zoom: pickupZoom),
    );
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
      location.canMoveMap = true;
      route.isVisible = true;
      setState();

      final myLocation = await location.location;
      final trip = getTrip().state;
      final pVectors = [myLocation];

      if (trip is TripRequest) {
        final locations = [trip.request.pickUp]..addAll(trip.request.stops);
        pVectors.addAll(locations
            .where((p) => p != null)
            .map((p) => LatLng(p.latitude, p.longitude)));
      }
      Future.delayed(
        mapDuration,
        () => camera.justifyCamera(positionVectors: pVectors, zoom: 15.0),
      );
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
    inset.setBaseInset("review", MapPickScreen.minHeight, shouldAnimate: true);
    marker.showDrivers = false;
    marker.showHomeAndWork = false;
    marker.showPickupAndDestination = false;
    // more marker update

    location.canMoveMap = false;
    pin.initPin(type: AddressSearchType(addressIndex: -1), position: position);
    route.isVisible = false;
    setState();

    final pVectors = [position];

    Future.delayed(
      mapDuration,
      () => camera.justifyCamera(positionVectors: pVectors, zoom: pickupZoom),
    );
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static HomeMainScreen of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeMainScreen>();
}
