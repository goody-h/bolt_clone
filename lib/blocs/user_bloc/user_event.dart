import 'package:equatable/equatable.dart';
import 'package:data_repository/data_repository.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUser extends UserEvent {}

class UpdateUser extends UserEvent {
  final User user;

  const UpdateUser(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'UpdateUser { user: $user }';
}

class UserUpdated extends UserEvent {
  final User user;

  const UserUpdated(this.user);

  @override
  List<Object> get props => [user];
}
