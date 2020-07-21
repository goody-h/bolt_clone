import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import './user.dart';
import 'package:data_repository/data_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final DataRepository dataRepository;
  StreamSubscription _userSubscription;

  UserBloc({@required DataRepository dataRepository})
      : assert(dataRepository != null),
        dataRepository = dataRepository,
        super(UserLoading());

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is LoadUser) {
      yield* _mapLoadUserToState();
    } else if (event is UpdateUser) {
      yield* _mapUpdateUserToState(event);
    } else if (event is UserUpdated) {
      yield* _mapUserUpdateToState(event);
    }
  }

  Stream<UserState> _mapLoadUserToState() async* {
    _userSubscription?.cancel();
    _userSubscription = dataRepository.getUserProfile().listen(
          (user) => add(UserUpdated(user)),
        );
  }

  Stream<UserState> _mapUpdateUserToState(UpdateUser event) async* {
    dataRepository.updateUserProfile(event.user);
  }

  Stream<UserState> _mapUserUpdateToState(UserUpdated event) async* {
    yield UserLoaded(event.user);
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
