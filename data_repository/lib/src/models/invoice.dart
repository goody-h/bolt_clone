import 'package:cloud_firestore/cloud_firestore.dart';

import 'position.dart';

enum PaymentMethod { cash, card, newcard }

PaymentMethod paymentMethodFromString(String method) {
  switch (method) {
    case "cash":
      return PaymentMethod.cash;
    case "card":
      return PaymentMethod.card;
    case "newCard":
      return PaymentMethod.newcard;
    default:
      return PaymentMethod.cash;
  }
}

class Invoice extends InvoiceData {
  Invoice({this.amount = 4000, this.id}) {
    this.id =
        "BOLT_XXXXXXXXXXXX_${Timestamp.now().millisecondsSinceEpoch}_Lite";
    print(id);
  }
  Invoice.fromJson(Map<String, dynamic> invoice)
      : amount = invoice["amount"],
        signature = invoice["signature"],
        id = invoice["id"],
        pickupTime = invoice["pickupTime"],
        currency = invoice["currency"],
        super.fromJson(invoice);
  int amount;
  String signature;
  String id;
  String pickupTime;
  String currency;

  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        "amount": amount,
        "pickupTime": pickupTime,
        "currency": currency,
        "id": id,
      });
  }
}

//TODO
class InvoiceData {
  InvoiceData({
    this.tier,
    this.pickUp = const Position(),
    this.destination = const Position(),
    this.distance,
    this.time,
    this.method = PaymentMethod.newcard,
  });

  InvoiceData.fromJson(Map<String, dynamic> data)
      : this(
            tier: data["tier"],
            pickUp: Position.fromJson(data["pickup"]),
            destination: Position.fromJson(data["destination"]),
            distance: data["distance"],
            time: data["time"],
            method: paymentMethodFromString(data["method"]));

  String tier;
  Position pickUp;
  Position destination;
  double distance;
  int time;
  PaymentMethod method;

  Map<String, dynamic> toJson() {
    return {
      "tier": tier,
      "method": method.toString().split('.')[1],
      "distance": distance,
      "destination": destination.toJson(),
      "pickup": pickUp.toJson(),
      "time": time
    };
  }
}
