import 'package:equatable/equatable.dart';
import 'package:data_repository/data_repository.dart';

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

// External and internal events
class TripTierUpdated extends TripEvent {
  final String tier;

  const TripTierUpdated(this.tier);

  @override
  List<Object> get props => [tier];
}

// External events
class TripRequestInit extends TripEvent {
  final dynamic location;

  const TripRequestInit(this.location);

  @override
  List<Object> get props => [location];
}

class TripDestinationUpdated extends TripEvent {
  final dynamic location;

  const TripDestinationUpdated(this.location);

  @override
  List<Object> get props => [location];
}

class TripDistanceUpdated extends TripEvent {
  final double distance;

  const TripDistanceUpdated(this.distance);

  @override
  List<Object> get props => [distance];
}

class TripPickupUpdated extends TripEvent {
  final dynamic location;

  const TripPickupUpdated(this.location);

  @override
  List<Object> get props => [location];
}
