import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'trip.dart';
import 'package:data_repository/data_repository.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final DataRepository _dataRepository;
  StreamSubscription _tripSubscription;

  TripBloc({@required DataRepository dataRepository})
      : assert(dataRepository != null),
        _dataRepository = dataRepository,
        super(TripLoading());

  @override
  Stream<TripState> mapEventToState(TripEvent event) async* {
    if (event is LoadTrip) {
      yield* _mapLoadTripToState();
    } else if (event is TripUpdated) {
      yield* _mapTripUpdateToState(event);
    }
  }

  Stream<TripState> _mapLoadTripToState() async* {
    _tripSubscription?.cancel();
    _tripSubscription = _dataRepository.getCurrentTrip().listen(
          (trip) => add(TripUpdated(trip)),
        );
  }

  Stream<TripState> _mapTripUpdateToState(TripUpdated event) async* {
    yield TripLoaded(event.trip);
  }

  @override
  Future<void> close() {
    _tripSubscription?.cancel();
    return super.close();
  }
}
