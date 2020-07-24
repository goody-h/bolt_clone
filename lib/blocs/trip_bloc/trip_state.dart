import 'package:equatable/equatable.dart';
import 'package:data_repository/data_repository.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object> get props => [];
}

class TripLoading extends TripState {}

class TripLoaded extends TripState {
  final Trip trip;

  const TripLoaded(this.trip);

  @override
  List<Object> get props => [trip];

  @override
  String toString() => 'TripLoaded { trip: $trip }';
}

class TripNotLoaded extends TripState {}
