import 'package:equatable/equatable.dart';
import 'package:data_repository/data_repository.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object> get props => [];
}

class TripLoading extends TripState {}

class TripActive extends TripState {
  final Trip trip;

  const TripActive(this.trip);

  @override
  List<Object> get props => [trip];

  @override
  String toString() => 'TripLoaded { trip: $trip }';
}

class TripRequest extends TripState {
  final InvoiceData request;
  final Map<String, Invoice> invoices;
  final String activeTier;
  final List<Driver> drivers;

  const TripRequest(
      {this.request, this.drivers, this.activeTier, this.invoices});

  @override
  List<Object> get props => [request, invoices, activeTier, drivers];

  @override
  String toString() => 'TripRequest { InvoiceData: ${request.toJson()} }';

  List<String> getavailableTiers(List<Driver> drivers) =>
      drivers.map((d) => d.tier).toSet().toList();

  TripRequest copyWith({
    InvoiceData request,
    List<Driver> drivers,
    String activeTier,
    Map<String, Invoice> invoices,
  }) {
    return TripRequest(
      request: request ?? this.request,
      drivers: drivers ?? this.drivers,
      activeTier: activeTier ?? this.activeTier,
      invoices: invoices ?? this.invoices,
    );
  }
}
