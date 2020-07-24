import 'package:equatable/equatable.dart';
import 'package:data_repository/data_repository.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object> get props => [];
}

class LoadTrip extends TripEvent {}

class TripUpdated extends TripEvent {
  final Trip trip;

  const TripUpdated(this.trip);

  @override
  List<Object> get props => [trip];
}
