import 'package:equatable/equatable.dart';
import 'package:data_repository/data_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object> get props => [];
}

class LoadTrip extends TripEvent {}

// Internal events
class ActiveTripUpdated extends TripEvent {
  final Trip trip;

  const ActiveTripUpdated(this.trip);

  @override
  List<Object> get props => [trip];
}

class InactiveTrip extends TripEvent {}

class InvoiceUpdated extends TripEvent {
  final Map<String, Invoice> invoice;

  const InvoiceUpdated(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class DriverUpdated extends TripEvent {
  final List<Driver> drivers;

  const DriverUpdated(this.drivers);

  @override
  List<Object> get props => [drivers];
}

class TripPaymentUpdated extends TripEvent {
  final PaymentMethod method;

  const TripPaymentUpdated(this.method);

  @override
  List<Object> get props => [method];
}

class TripRouteUpdated extends TripEvent {
  final double distance;
  final Set<Polyline> route;

  const TripRouteUpdated({this.distance, this.route});

  @override
  List<Object> get props => [distance, this.route];
}

// External and internal events
class TripTierUpdated extends TripEvent {
  final String tier;

  const TripTierUpdated(this.tier);

  @override
  List<Object> get props => [tier];
}

// External events
class TripRequestInit extends TripEvent {
  final Position location;

  const TripRequestInit(this.location);

  @override
  List<Object> get props => [location];
}

class CommitStaging extends TripEvent {
  const CommitStaging();
}

class InitStaging extends TripEvent {
  const InitStaging();
}

class TripDestinationUpdated extends TripEvent {
  final Position location;
  final int index;
  final bool stage;

  const TripDestinationUpdated(
      {this.location, this.index = 0, this.stage = false});

  @override
  List<Object> get props => [location, index, stage];
}

class TripPickupUpdated extends TripEvent {
  final Position location;

  const TripPickupUpdated(this.location);

  @override
  List<Object> get props => [location];
}
