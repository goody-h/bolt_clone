import 'package:equatable/equatable.dart';
import 'package:data_repository/data_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class TripState extends Equatable {
  const TripState(this.stateId);
  final String stateId;

  @override
  List<Object> get props => [];
}

class TripLoading extends TripState {
  const TripLoading(String stateId) : super(stateId);
}

class TripActive extends TripState {
  final Trip trip;

  const TripActive(this.trip, String stateId) : super(stateId);

  @override
  List<Object> get props => [trip];

  @override
  String toString() => 'TripLoaded { trip: $trip }';
}

class TripRequest extends TripState {
  final InvoiceData request;
  final InvoiceData staging;
  final Map<String, Invoice> invoices;
  final String activeTier;
  final List<Driver> drivers;
  final Set<Polyline> route;

  const TripRequest({
    String stateId,
    this.request,
    this.drivers = const [],
    this.activeTier,
    this.invoices,
    this.route,
    this.staging,
  }) : super(stateId);

  @override
  List<Object> get props =>
      [request, invoices, activeTier, drivers, staging, route, stateId];

  @override
  String toString() => 'TripRequest { InvoiceData: ${request.toJson()} }';

  List<String> getavailableTiers(List<Driver> drivers) =>
      drivers.map((d) => d.tier).toSet().toList();

  TripRequest copyWith({
    InvoiceData request,
    List<Driver> drivers,
    String activeTier,
    Map<String, Invoice> invoices,
    InvoiceData staging,
    Set<Polyline> route,
    String stateId,
  }) {
    return TripRequest(
      request: request ?? this.request,
      drivers: drivers ?? this.drivers,
      activeTier: activeTier ?? this.activeTier,
      invoices: invoices ?? this.invoices,
      route: route ?? this.route,
      staging: staging ?? this.staging,
      stateId: stateId ?? this.stateId,
    );
  }
}
