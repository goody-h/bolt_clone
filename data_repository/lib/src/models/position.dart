import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
class Position extends Equatable {
  final double longitude;
  final double latitude;
  final String address;

  const Position({
    this.longitude,
    this.latitude,
    this.address,
  });

  @override
  List<Object> get props => [longitude, latitude];

  @override
  String toString() {
    return 'Position { longitude: $longitude, latitude: $latitude, ' +
        'address: $address}';
  }

  Map<String, dynamic> toJson() {
    return {
      "longitude": longitude,
      "latitude": latitude,
      "address": address,
    };
  }

  static Position fromJson(Map<String, Object> json) {
    return Position(
      longitude: json["longitude"] as double,
      latitude: json["latitude"] as double,
      address: json["address"] as String,
    );
  }
}
