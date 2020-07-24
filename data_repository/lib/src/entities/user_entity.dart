// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../models/card.dart';
import '../models/position.dart';
import 'dart:convert';

class UserEntity extends Equatable {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String paymentMethod;
  final Position home;
  final Position work;
  final Map<String, Card> cards;

  const UserEntity({
    this.userId,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.paymentMethod,
    this.cards,
    this.home,
    this.work,
  });

  Map<String, Object> toJson() {
    return {
      "email": email,
      "userId": userId,
      "firstname": firstName,
      "lastname": lastName,
      "phoneNumber": phoneNumber,
      "paymentMethod": paymentMethod,
      "home": home.toJson(),
      "work": work.toJson(),
      "cards": cards.map((key, value) => MapEntry(key, value.toJson()))
    };
  }

  @override
  List<Object> get props => [
        userId,
        email,
        firstName,
        lastName,
        phoneNumber,
        paymentMethod,
        cards,
        home,
        work
      ];

  @override
  String toString() {
    return 'UserEntity' + jsonEncode(toJson());
  }

  static UserEntity fromJson(Map<String, Object> json) {
    return UserEntity(
      email: json["email"] as String,
      userId: json["userId"] as String,
      firstName: json["firstname"] as String,
      lastName: json["lastname"] as String,
      phoneNumber: json["phoneNumber"] as String,
      home: Position.fromJson(json["home"] as Map<String, dynamic>),
      work: Position.fromJson(json["work"] as Map<String, dynamic>),
      paymentMethod: json["paymentMethod"] as String,
      cards: (json["cards"] as Map<String, dynamic>)
          .map((key, card) => MapEntry(key, Card.fromJson(card))),
    );
  }

  static UserEntity fromSnapshot(DocumentSnapshot snap) {
    return fromJson({"userId": snap.documentID}..addAll(snap.data));
  }
}
