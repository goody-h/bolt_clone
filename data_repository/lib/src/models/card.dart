import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
class Card extends Equatable {
  final String last4;
  final String type;
  final String authCode;
  final String signature;

  const Card({this.signature, this.authCode, this.type, this.last4});

  @override
  List<Object> get props => [authCode];

  @override
  String toString() {
    return 'Card { signature: $signature, type: $type, authCode: $authCode, last4: $last4 }';
  }

  Map<String, dynamic> toJson() {
    return {
      "signature": signature,
      "authCode": authCode,
      "type": type,
      "last4": last4,
    };
  }

  static Card fromJson(Map<String, Object> json) {
    return Card(
      signature: json["signature"] as String,
      authCode: json["authCode"] as String,
      type: json["type"] as String,
      last4: json["last4"] as String,
    );
  }
}
