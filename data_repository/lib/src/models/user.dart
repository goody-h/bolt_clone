import 'package:meta/meta.dart';
import 'dart:convert';
import '../entities/entities.dart';
import 'card.dart';

@immutable
class User {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String paymentMethod;
  final Map<String, Card> cards;

  User({
    this.userId,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.paymentMethod,
    this.cards,
  });

  User copyWith({
    String firstName,
    String lastName,
    String phoneNumber,
    String paymentMethod,
  }) {
    return User(
      userId: this.userId,
      email: this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cards: this.cards,
    );
  }

  @override
  int get hashCode =>
      userId.hashCode ^
      email.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      phoneNumber.hashCode ^
      paymentMethod.hashCode ^
      cards.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          email == other.email &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          phoneNumber == other.phoneNumber &&
          paymentMethod == other.paymentMethod &&
          cards == other.cards;

  @override
  String toString() {
    return 'User ' + jsonEncode(toEntity().toJson());
  }

  UserEntity toEntity() {
    return UserEntity(
      userId: this.userId,
      email: this.email,
      firstName: this.firstName,
      lastName: this.lastName,
      phoneNumber: this.phoneNumber,
      paymentMethod: this.paymentMethod,
      cards: this.cards,
    );
  }

  static User fromEntity(UserEntity entity) {
    return User(
      userId: entity.userId,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phoneNumber: entity.phoneNumber,
      paymentMethod: entity.paymentMethod,
      cards: entity.cards,
    );
  }
}
