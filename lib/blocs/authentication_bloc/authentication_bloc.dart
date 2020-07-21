import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:data_repository/data_repository.dart';
import 'package:meta/meta.dart';
import 'package:user_repository/user_repository.dart';
import './bloc.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;
  final DataRepository _dataRepository;

  AuthenticationBloc(
      {@required UserRepository userRepository, DataRepository dataRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        _dataRepository = dataRepository,
        super(Uninitialized());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _userRepository.isAuthenticated();
      if (!isSignedIn) {
        await _userRepository.authenticate();
      }
      final userId = await _userRepository.getUserId();
      await _dataRepository.init(userId);
      yield Authenticated(userId);
    } catch (_) {
      yield Unauthenticated();
    }
  }
}
