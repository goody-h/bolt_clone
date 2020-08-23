import 'dart:async';
import 'package:bolt_clone/blocs/trip_bloc/trip.dart';
import 'package:bolt_clone/routes/home/map.dart';
import 'package:bolt_clone/routes/home/widgets/drop_pin.dart';
import 'package:bolt_clone/utils.dart';
import 'package:data_repository/data_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'
    show LocationOptions, LocationAccuracy, Geolocator;
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

class HomeMainState extends State<HomeMain> with WidgetsBindingObserver {
  TripBloc trip;
  MenuButtonController menu;
  MapDataController map;
  CameraController camera;
  LocationButtonController locationBtn;
  MarkerController marker;
  LocationController location;
  SelectionPinController pin;
  RouteController route;

  @override
  void initState() {
    super.initState();
    trip = TripBloc(userBloc: BlocProvider.of<UserBloc>(context));
    menu = MenuButtonController(registerPop: widget.registerPop);
    map = MapDataController();
    camera = CameraController(controller: mapController);
    locationBtn = LocationButtonController();
    marker = MarkerController(camera);
    location = LocationController(camera);
    pin =
        SelectionPinController(setState: () => setState(() {}), camera: camera);
    route = RouteController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
      map.refresh();
    }
  }

  Completer<bool> loadMap = Completer();

  @override
  void dispose() {
    map.dispose();
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
              controller: map,
              loadMap: loadMap,
              onLoad: (GoogleMapController controller) async {
                mapController.complete(controller);
              },
              pin: pin,
              marker: marker,
              route: route,
            ),
          ),
          Visibility(
            visible: pin.isVisible,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              padding: EdgeInsets.only(bottom: map.secondaryInset),
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
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: menu._canPop ? 1 : 0),
                      duration: Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return AnimatedIcon(
                          icon: AnimatedIcons.menu_arrow,
                          progress: AlwaysStoppedAnimation(value),
                          color: AppColors.blackLight,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          HomeMainScreen(
            child: HomeScreen(),
            context: context,
            trip: trip,
            menu: menu,
            map: map,
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
  Function(BoolCallback) registerPop;
  Function(BuildContext) onClick;
  BoolCallback _onPopCallback;
  bool _canPop = false;

  MenuButtonController({this.registerPop}) {
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
    }
  }

  _openDrawer(BuildContext context) => Scaffold.of(context).openDrawer();
}

class SelectionPinController {
  bool isVisible = false;
  bool isDown = true;
  Position position;
  Position _positionHolder;
  String pinAddress;
  AddressSearchType type;
  bool isInitializing = false;
  final VoidCallback setState;
  final CameraController camera;

  SelectionPinController({this.setState, this.camera});

  bool get isPickup => !(type?.isDestination ?? true);

  initPin({AddressSearchType type, Position position}) {
    print("pin init position $position");
    this.type = type;
    this.isVisible = true;
    this.position = position;
    isInitializing = true;
    _positionToAddress();
  }

  positionMap(TripState state) {
    if (state is TripRequest &&
        isInitializing &&
        type?.isReview == true &&
        position != state.request.pickUp) {
      position = state.request.pickUp;
      final myLocation = camera.positionVectors[0];
      final pVectors = [LatLng(position.latitude, position.longitude)];
      Future.delayed(
        HomeMainScreen.mapDuration,
        () {
          if (isInitializing) {
            final pickupZoom = HomeMainScreen.pickupZoom;
            camera.justifyCamera(
              positionVectors: pVectors,
              zoom: camera.zoom != pickupZoom ? pickupZoom : pickupZoom + 0.001,
              fix: [LatLng(myLocation.latitude, myLocation.longitude)],
            );
          }
        },
      );
    }
  }

  disable() {
    isVisible = false;
    pinAddress = null;
    position = null;
    _positionHolder = null;
    type = null;
    isInitializing = false;
  }

  setIsDown(bool isDown) {
    if (this.isDown != isDown) {
      this.isDown = isDown;
      setState();
    }
  }

  movePinPosition(LatLng position) {
    if (isVisible) {
      this._positionHolder = Position(
        latitude: position.latitude,
        longitude: position.longitude,
        address: "",
      );
      setIsDown(false);
    }
  }

  updatePinPosition(BuildContext context) {
    if (isVisible) {
      if (position != _positionHolder && !isInitializing) {
        //TODO calculate address name
        // send event to TripBloc
        _positionToAddress();
      }
      isInitializing = false;
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

  justifyCamera(
      {List<LatLng> positionVectors, double zoom, List<LatLng> fix}) async {
    this.positionVectors = positionVectors ?? this.positionVectors;
    this.zoom = zoom ?? this.zoom;

    if (this.positionVectors == null ||
        this.positionVectors.length == 0 ||
        this.zoom == null) return;

    final map = await controller.future;

    final CameraUpdate update =
        (this.positionVectors?.length ?? 0) > 1 ? _getBounds() : _getPosition();
    map.animateCamera(update);
    if (fix != null) {
      this.positionVectors = fix;
    }
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

class MapDataController {
  final streamController = StreamController<MapData>.broadcast();
  MapData data;
  Random rnd = Random();

  MapDataController() {
    data = MapData(
      mapTag: "g-map",
      bottomPadding: 0,
      secondaryPadding: 0,
    );
    setBaseInset(0);
  }

  double get inset => data.bottomPadding;
  double get secondaryInset => data.secondaryPadding;

  Stream<MapData> get stream => streamController.stream;

  setBaseInset(double inset, {double secondaryInset}) async {
    this.data.bottomPadding = inset;
    this.data.secondaryPadding = secondaryInset ?? inset;
    streamController.sink.add(data);
    print("set base inset value ${data.bottomPadding}");
  }

  refresh() {
    streamController.sink.add(data);
  }

  dispose() {
    streamController.close();
  }
}

class MarkerController {
  bool showDrivers = true;
  bool showPickupAndDestination = false;
  bool showHomeAndWork = true;
  final CameraController camera;

  MarkerController(this.camera);

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

    if (showPickupAndDestination && state is TripRequest) {
      final locations = [state.request.pickUp]..addAll(state.request.stops);
      final pVectors = [camera.positionVectors[0]]..addAll(locations
          .where((p) => p != null)
          .map((p) => LatLng(p.latitude, p.longitude)));
      bool animateMap = false;
      for (var p in pVectors) {
        if (!camera.positionVectors.contains(p)) {
          animateMap = true;
          break;
        }
      }
      if (animateMap)
        Future.delayed(
          HomeMainScreen.mapDuration,
          () => camera.justifyCamera(positionVectors: pVectors, zoom: 15.0),
        );
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
  bool isVisible = false;

  Set<Polyline> getRoute(TripState state) {
    return isVisible && state is TripRequest ? state.route : null;
  }
}

// TODO
class LocationController {
  final Geolocator _geolocator = Geolocator();
  final CameraController controller;
  bool canMoveMap = true;
  Position _location;
  LocationController(this.controller) {
    _geolocator
        .getPositionStream(LocationOptions(
            accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 10))
        .listen((position) {
      //TODO calculate addresss name
      _location = Position(
        latitude: position.latitude,
        longitude: position.longitude,
        address: "",
      );
      controller.positionVectors[0] =
          LatLng(position.latitude, position.longitude);
      if (canMoveMap && controller.hasLayout) {
        controller.justifyCamera();
      }
    });
  }

  Future<Position> get location async {
    if (_location == null) {
      final position = await _geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      _location = Position(
        latitude: position.latitude,
        longitude: position.longitude,
        address: "",
      );
    }
    print("get Current location $_location");
    return _location;
  }
}

class HomeMainScreen extends InheritedWidget {
  HomeMainScreen({
    Widget child,
    this.trip,
    this.context,
    this.menu,
    this.setState,
    this.map,
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
  final MapDataController map;
  final VoidCallback setState;
  final LocationButtonController locationBtn;
  final CameraController camera;
  final MarkerController marker;
  final LocationController location;
  final SelectionPinController pin;
  final RouteController route;

  TripBloc getTrip() => trip;
  UserBloc getUser() => BlocProvider.of<UserBloc>(context);

  static const defaultZoom = 16.95;
  static const destinationZoom = 15.0;
  static const pickupZoom = 17.0;
  static const assigningZoom = 17.2;

  static final mapDuration = Duration(milliseconds: 700);

  setDefaultView({
    bool isExpanded = false,
    bool isChanging = false,
    double insetHeight = DefaultSearchScreen.minHeight2,
  }) async {
    if (!isChanging) {
      menu.setCanPop(false);
      locationBtn.isVisible = true;
      marker.showDrivers = true;
      marker.showHomeAndWork = true;
      marker.showPickupAndDestination = false;
      // more marker update
      pin.disable();
      location.canMoveMap = true;
      route.isVisible = false;
      map.setBaseInset(insetHeight /*, shouldAnimate: !isExpanded */);
      setState();

      final myLocation = await location.location;
      final user = getUser().state;
      final pVectors = [LatLng(myLocation.latitude, myLocation.longitude)];

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
        camera.justifyCamera(positionVectors: [
          LatLng(myLocation.latitude, myLocation.longitude)
        ], zoom: defaultZoom);
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
    // call this section last to prevent blocking at the begining of app init
    if (!isExpanded) {
      final myLocation = await location.location;
      getTrip().add(TripRequestInit(myLocation));
    }
  }

  setChooseDestinationView(AddressSearchType type) async {
    final myLocation = await location.location;
    Position stop;
    final trip = getTrip().state;
    if (trip is TripRequest &&
        trip.request.stops[type.addressIndex - 1] != null) {
      stop = trip.request.stops[type.addressIndex - 1];
    }

    final usePosition = stop ?? myLocation;

    menu.setCanPop(true);
    locationBtn.isVisible = false;
    marker.showDrivers = false;
    marker.showHomeAndWork = false;
    marker.showPickupAndDestination = false;
    // more marker update

    location.canMoveMap = false;
    pin.initPin(type: type, position: usePosition);
    route.isVisible = false;
    map.setBaseInset(MapPickScreen.minHeight,
        secondaryInset: MapPickScreen.minHeight);
    setState();

    final pVectors = [LatLng(usePosition.latitude, usePosition.longitude)];

    Future.delayed(
      mapDuration,
      () => camera.justifyCamera(
          positionVectors: pVectors,
          zoom: camera.zoom != destinationZoom
              ? destinationZoom
              : destinationZoom + 0.001,
          fix: [LatLng(myLocation.latitude, myLocation.longitude)]),
    );
  }

  setCoosePickupView() async {
    final myLocation = await location.location;
    Position pickup;
    final trip = getTrip().state;
    if (trip is TripRequest && trip.request.pickUp != null) {
      pickup = trip.request.pickUp;
    }

    final usePosition = pickup ?? myLocation;
    // possibly shift location slightly

    menu.setCanPop(true);
    locationBtn.isVisible = true;
    marker.showDrivers = false;
    marker.showHomeAndWork = false;
    marker.showPickupAndDestination = false;
    // more marker update

    location.canMoveMap = false;
    pin.initPin(
        type: AddressSearchType(addressIndex: 0), position: usePosition);
    route.isVisible = false;
    map.setBaseInset(0, secondaryInset: MapPickScreen.minHeight);
    setState();

    final pVectors = [LatLng(usePosition.latitude, usePosition.longitude)];

    Future.delayed(
      mapDuration,
      () => camera.justifyCamera(
        positionVectors: pVectors,
        zoom: camera.zoom != pickupZoom ? pickupZoom : pickupZoom + 0.001,
        fix: [LatLng(myLocation.latitude, myLocation.longitude)],
      ),
    );
  }

  setDetailsView({
    bool isChanging = false,
    double insetHeight = DetailsScreen.minHeight,
  }) async {
    if (!isChanging) {
      menu.setCanPop(true);
      locationBtn.isVisible = false;
      marker.showDrivers = true;
      marker.showHomeAndWork = false;
      marker.showPickupAndDestination = true;
      // more marker update
      pin.disable();
      location.canMoveMap = true;
      route.isVisible = true;
      map.setBaseInset(insetHeight);
      setState();

      final myLocation = await location.location;
      final pVectors = [LatLng(myLocation.latitude, myLocation.longitude)];

      Future.delayed(
        mapDuration,
        () {
          final trip = getTrip().state;
          if (trip is TripRequest) {
            final locations = [trip.request.pickUp]..addAll(trip.request.stops);
            pVectors.addAll(locations
                .where((p) => p != null)
                .map((p) => LatLng(p.latitude, p.longitude)));
          }
          camera.justifyCamera(positionVectors: pVectors, zoom: 15.0);
        },
      );
    }
  }

  setReviewView() async {
    menu.setCanPop(true);
    locationBtn.isVisible = true;
    marker.showDrivers = false;
    marker.showHomeAndWork = false;
    marker.showPickupAndDestination = false;
    // more marker update

    location.canMoveMap = false;
    pin.initPin(type: AddressSearchType(addressIndex: -1));
    route.isVisible = false;
    map.setBaseInset(0, secondaryInset: MapPickScreen.minHeight);
    setState();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static HomeMainScreen of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeMainScreen>();
}
