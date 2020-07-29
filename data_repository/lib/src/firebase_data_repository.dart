// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_repository/data_repository.dart';
import 'entities/entities.dart';

class FirebaseDataRepository implements DataRepository {
  CollectionReference usersCollection = Firestore.instance.collection('users');
  DocumentReference docRef;

  var userStream = StreamController<User>.broadcast();
  var tripStream = StreamController<Trip>.broadcast();
  var hasInit = Completer<bool>();

  @override
  init(dynamic data) async {
    // _getDataFromFirestore(data as String);
    _getMockData();
    await hasInit.future;
  }

  _getMockData() async {
    final user = UserEntity.fromJson(mockData);
    await Future.delayed(Duration(seconds: 2));
    userStream.sink.add(User.fromEntity(user));
    if (!hasInit.isCompleted) hasInit.complete(true);
  }

  _getDataFromFirestore(String userId) async {
    docRef = usersCollection.document(userId);
    docRef.snapshots(includeMetadataChanges: true).listen(_handleUserSnapshot);
  }

  _handleUserSnapshot(DocumentSnapshot snap) {
    if (snap.exists && snap.data != null) {
      final user = UserEntity.fromSnapshot(snap);
      userStream.sink.add(User.fromEntity(user));
      if (snap.data.containsKey("trip")) {
        final trip = Trip.fromJson(snap.data["trip"]);
        tripStream.sink.add(trip);
      }
      if (!hasInit.isCompleted) hasInit.complete(true);
    }
  }

  @override
  dispose() async {
    userStream.close();
    tripStream.close();
  }

  @override
  Stream<User> getUserProfile() {
    return userStream.stream.distinct();
  }

  @override
  Stream<Trip> getCurrentTrip() {
    return tripStream.stream.distinct();
  }

  @override
  Future<void> updateUserProfile(User user) {
    return docRef.setData(user.toEntity().toJson(), merge: true);
  }

  @override
  seedStream(dynamic data) async {
    try {
      if (data is String && data == "trip") {
        final previous = await tripStream.stream.last;
        tripStream.sink.add(null);
        tripStream.sink.add(previous);
      }
    } catch (e) {
      print(e);
    }
  }

  final mockData = {
    "email": "goodhopeordu@yahoo.com",
    "userId": "XAE20b2x30v",
    "firstname": "Goodhope",
    "lastname": "Ordu",
    "phoneNumber": "+2348121451240",
    "paymentMethod": "signature0",
    "home": {
      "longitude": 7.005,
      "latitude": 4.902008,
      "address": "Rukpokwu",
    },
    "work": {
      "longitude": 7.005,
      "latitude": 4.902008,
      "address": "Rukpokwu",
    },
    "cards": {
      "signature0": {
        "signature": "signature0",
        "authCode": "authCode",
        "type": "visa",
        "last4": "1234",
      },
    },
    "trip": {
      "id": "trip1",
      "status": "assigning",
      "driver": {
        "id": "driver1",
        "rating": 4.3,
        "carModel": "Toyota",
        "carColor": "Black",
        "name": "John",
        "imageUrl": "https://image-url.com",
        "phoneNumber": "+2348121451240",
        "location": {
          "longitude": 1121.212121212,
          "latitude": 22221.323232323,
          "address": "Rukpokwu",
        },
      },
      "invoice": {
        "tier": "lite",
        "method": "card",
        "distance": 2121222232,
        "destination": {
          "longitude": 1121.212121212,
          "latitude": 22221.323232323,
          "address": "Alakahia",
        },
        "pickup": {
          "longitude": 1121.212121212,
          "latitude": 22221.323232323,
          "address": "Rukpokwu",
        },
        "time": 11181811911919
      },
      "pickupTime": 4000000000000,
      "tripTime": 4000000000000,
    }
  };
}
