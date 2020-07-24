// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:data_repository/data_repository.dart';

abstract class DataRepository {
  Stream<User> getUserProfile();

  Stream<Trip> getCurrentTrip();

  Future<void> updateUserProfile(User user);

  Future<void> init(dynamic data);

  Future<void> dispose();
}
