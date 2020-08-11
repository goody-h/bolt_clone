import 'package:bolt_clone/routes/home/screencopy.dart';
import 'package:bolt_clone/routes/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './blocs/authentication_bloc/bloc.dart';
import 'package:data_repository/data_repository.dart';
import './blocs/blocs.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(BoltApp());
}

class BoltApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataRepo = FirebaseDataRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) {
            return UserBloc(
              dataRepository: dataRepo,
            )..add(LoadUser());
          },
          lazy: false,
        ),
        BlocProvider<AuthenticationBloc>(
          create: (context) {
            return AuthenticationBloc(
              userRepository: FirebaseUserRepository(),
              dataRepository: dataRepo,
            )..add(AppStarted());
          },
        ),
      ],
      child: MaterialApp(
        title: 'Bolt Clone',
        routes: {
          '/': (context) {
            return TestHome();
          },
        },
      ),
    );
  }
}
