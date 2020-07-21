import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'position.dart';

@immutable
class Driver extends Equatable {
  final String name;
  final String carModel;
  final String carColor;
  final double rating;
  final String imageUrl;
  final String id;
  final Position location;
  final String phoneNumber;

  const Driver({
    this.id,
    this.rating,
    this.carModel,
    this.carColor,
    this.name,
    this.imageUrl,
    this.location,
    this.phoneNumber,
  });

  @override
  List<Object> get props => [id, location];

  @override
  String toString() {
    return 'Driver { id: $id, carModel: $carModel, carColor: $carColor, ' +
        'rating: $rating, name: $name, image: $imageUrl, location: $location, ' +
        'phoneNumber: $phoneNumber }';
  }

  static Driver fromJson(Map<String, Object> json) {
    return Driver(
      id: json["id"] as String,
      rating: json["rating"] as double,
      carModel: json["carModel"] as String,
      carColor: json["carColor"] as String,
      name: json["name"] as String,
      imageUrl: json["imageUrl"] as String,
      phoneNumber: json["phoneNumber"] as String,
      location: Position.fromJson(json["location"] as Map<String, dynamic>),
    );
  }
}
