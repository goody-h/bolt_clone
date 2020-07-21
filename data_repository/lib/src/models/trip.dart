import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'driver.dart';
import 'invoice.dart';

@immutable
class Trip extends Equatable {
  final String id;
  final String status;
  final Driver driver;
  final Invoice invoice;
  final double pickupTime;
  final double tripTime;

  Trip({
    this.id,
    this.status,
    this.driver,
    this.invoice,
    this.pickupTime,
    this.tripTime,
  });

  @override
  List<Object> get props => [id, status, driver, pickupTime];

  @override
  String toString() {
    return 'Trip $id';
  }

  static Trip fromJson(Map<String, Object> json) {
    return Trip(
      id: json["id"] as String,
      status: json["status"] as String,
      driver: Driver.fromJson(json["driver"] as Map<String, dynamic>),
      invoice: Invoice.fromJson(json["invoice"] as Map<String, dynamic>),
      pickupTime: json["pickupTime"] as double,
      tripTime: json["tripTime"] as double,
    );
  }
}
