import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bolt_clone/blocs/user_bloc/user.dart';
import 'package:bolt_clone/utils.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'trip.dart';
import 'package:data_repository/data_repository.dart';
import 'dart:math';

class TripBloc extends Bloc<TripEvent, TripState> {
  final DataRepository _dataRepository;
  final UserBloc userBloc;
  StreamSubscription _tripSubscription;
  StreamSubscription _userSubscription;
  String stateId = "trip-bloc";

  TripBloc({@required this.userBloc})
      : assert(userBloc != null),
        _dataRepository = userBloc.dataRepository,
        super(TripLoading("trip-bloc"));

  @override
  Stream<TripState> mapEventToState(TripEvent event) async* {
    if (event is LoadTrip) {
      yield* _mapLoadTripToState();
    } else if (event is ActiveTripUpdated) {
      yield* _mapTripUpdateToState(event);
    } else if (event is InactiveTrip) {
      yield* _mapInactiveTripToState(event);
    } else if (event is TripRequestInit) {
      yield* _mapTripInitToState(event);
    } else if (event is TripPickupUpdated) {
      yield* _mapTripPickupUpdateToState(event);
    } else if (event is TripDestinationUpdated) {
      yield* _mapTripDestinationUpdateToState(event);
    } else if (event is TripPaymentUpdated) {
      yield* _mapTripPaymentToState(event);
    } else if (event is InitStaging) {
      yield* _mapInitStagingToState(event);
    } else if (event is CommitStaging) {
      yield* _mapCommitStagingToState(event);
    } else if (event is TripTierUpdated) {
      yield* _mapTierUpdateToState(event);
    } else if (event is TripRouteUpdated) {
      yield* _mapRouteUpdateToState(event);
    } else if (event is InvoiceUpdated) {
      yield* _mapInvoiceUpdateToState(event);
    } else if (event is DriverUpdated) {
      yield* _mapDriverUpdateToState(event);
    }
  }

  Stream<TripState> _mapDriverUpdateToState(DriverUpdated event) async* {
    final state = this.state as TripRequest;
    final newState = state.copyWith(drivers: event.drivers, stateId: stateId);
    yield newState;
  }

  Stream<TripState> _mapInvoiceUpdateToState(InvoiceUpdated event) async* {
    final state = this.state as TripRequest;
    final newState = state.copyWith(invoices: event.invoice, stateId: stateId);
    yield newState;
  }

  Stream<TripState> _mapRouteUpdateToState(TripRouteUpdated event) async* {
    final state = this.state as TripRequest;
    state.request.distance = event.distance;
    final newState = state.copyWith(route: event.route, stateId: stateId);
    _getInvoices(newState);
    yield newState;
  }

  Stream<TripState> _mapTierUpdateToState(TripTierUpdated event) async* {
    final state = this.state as TripRequest;
    final newState = state.copyWith(activeTier: event.tier, stateId: stateId);
    yield newState;
  }

  Stream<TripState> _mapCommitStagingToState(CommitStaging event) async* {
    final state = this.state;
    if (state is TripRequest) {
      final request = state.request;
      state.staging.foldStops();
      request.stops = state.staging.stops;
      request.distance = null;
      final newState =
          state.copyWith(invoices: {}, route: Set(), stateId: stateId);
      _getInvoices(newState);
      _getRoute(newState);
      yield newState;
    }
  }

  Stream<TripState> _mapInitStagingToState(InitStaging event) async* {
    final state = this.state;
    if (state is TripRequest) {
      yield state.copyWith(
        staging: InvoiceData(stops: []..addAll(state.request.stops)),
        stateId: stateId,
      );
    }
  }

  Stream<TripState> _mapTripPaymentToState(TripPaymentUpdated event) async* {
    final method = event.method;
    final state = this.state as TripRequest;
    state.request.method = method;
    final newState = state.copyWith(invoices: {}, stateId: stateId);
    _getInvoices(newState);
    yield newState;
  }

  Stream<TripState> _mapTripDestinationUpdateToState(
      TripDestinationUpdated event) async* {
    final index = event.index;
    final location = event.location;
    final state = this.state;
    if (state is TripRequest) {
      final request = event.stage ? state.staging : state.request;
      request.addStop(index, location);
      if (event.stage) {
        yield state.copyWith(stateId: stateId);
      }
      request.distance = null;
      final newState =
          state.copyWith(invoices: {}, route: Set(), stateId: stateId);
      _getInvoices(newState);
      _getRoute(newState);
      yield newState;
    }
  }

  Stream<TripState> _mapTripPickupUpdateToState(
      TripPickupUpdated event) async* {
    final location = event.location;
    final state = this.state as TripRequest;
    final request = state.request;
    request.pickUp = location;
    request.distance = null;
    final newState = state
        .copyWith(invoices: {}, drivers: [], route: Set(), stateId: stateId);
    _getInvoices(newState);
    _getRoute(newState);
    _getAvailableDrivers(newState);
    yield newState;
  }

  Stream<TripState> _mapTripInitToState(TripRequestInit event) async* {
    final location = event.location;
    final request = InvoiceData(
        pickUp: location, method: _getMethodFromUserState(userBloc.state));
    final newState =
        TripRequest(request: request, activeTier: "lite", stateId: stateId);
    _getAvailableDrivers(newState);
    yield newState;
  }

  Stream<TripState> _mapInactiveTripToState(InactiveTrip event) async* {
    yield TripRequest(
        request: InvoiceData(), activeTier: "lite", stateId: stateId);
  }

  Stream<TripState> _mapLoadTripToState() async* {
    _tripSubscription?.cancel();
    _userSubscription?.cancel();
    _tripSubscription = _dataRepository.getCurrentTrip().listen(
          (trip) => trip != null &&
                  ["assigning", "active", "started"].contains(trip.status)
              ? add(ActiveTripUpdated(trip))
              : add(InactiveTrip()),
        );
    userBloc.listen((user) {
      final state = this.state;
      final method = _getMethodFromUserState(user);
      if (user is UserLoaded &&
          state is TripRequest &&
          state.request.method != method) {
        add(TripPaymentUpdated(method));
      }
    });
    _dataRepository.seedStream("trip");
  }

  Stream<TripState> _mapTripUpdateToState(ActiveTripUpdated event) async* {
    yield TripActive(event.trip, stateId);
  }

  PaymentMethod _getMethodFromUserState(UserState user) {
    if (user is UserLoaded) {
      return paymentMethodFromString(user.user.paymentMethod);
    }
    return null;
  }

  _getAvailableDrivers(TripRequest request) async {
    // TODO implment get drivers
  }

  _getInvoices(TripRequest request) async {
    // TODO IMPLEMENT GET INVOICES
  }

  _getRoute(TripRequest state) async {
    final request = state.request;
    if (request.pickUp != null &&
        request.stops.where((p) => p != null).length != 0) {
      request.foldStops();
      final positions = [request.pickUp]
        ..addAll(request.stops.where((p) => p != null));
      // Map storing polylines created by connecting two points
      Map<PolylineId, Polyline> polylines = {};
      double totalDistance = 0.0;

      // Adding the polyline to the map
      for (var i = 0; i < positions.length - 1; i++) {
        totalDistance += await _createPolylines(
            request.pickUp, request.stops[0], i, polylines);
      }

      add(TripRouteUpdated(
          distance: totalDistance, route: Set<Polyline>.of(polylines.values)));
    }
  }

  Future<double> _createPolylines(Position start, Position destination,
      int index, Map<PolylineId, Polyline> polylines) async {
    // Initializing PolylinePoints
    PolylinePoints polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.MAPS_API_KEY, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );

    print(
        "polyline result {status: ${result.status}, error: ${result.errorMessage}}");

    // List of coordinates to join
    List<LatLng> polylineCoordinates = [];
    double totalDistance = 0.0;

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      print("polypoints ${result.points}");
      for (var i = 0; i < result.points.length; i++) {
        final point = result.points[i];
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        if (i != result.points.length - 1) {
          totalDistance += _coordinateDistance(
            point.latitude,
            point.longitude,
            result.points[i + 1].latitude,
            result.points[i + 1].longitude,
          );
        }
      }
    }

    PolylineId id = PolylineId('poly-$index');

    // Initializing Polyline
    polylines[id] = Polyline(
      polylineId: id,
      color: AppColors.indigo,
      points: polylineCoordinates,
      width: 3,
      // patterns: [PatternItem.dot, PatternItem.gap(10)]
    );

    return totalDistance;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Future<void> close() {
    _tripSubscription?.cancel();
    _userSubscription?.cancel();
    return super.close();
  }
}
