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
    this.stops,
    this.distance,
    this.time,
    this.method = PaymentMethod.newcard,
  });

  InvoiceData.fromJson(Map<String, dynamic> data)
      : this(
            tier: data["tier"],
            pickUp: Position.fromJson(data["pickup"]),
            stops: (data["stops"] as List<Map<String, dynamic>>)
                .map((d) => Position.fromJson(d))
                .toList(),
            distance: data["distance"],
            time: data["time"],
            method: paymentMethodFromString(data["method"]));

  String tier;
  Position pickUp;
  List<Position> stops = List.filled(2, null, growable: true);
  double distance;
  int time;
  PaymentMethod method;

  addStop(int index, Position position) {
    stops[index] = position;
    if (!stops.contains(null) && stops.length < 3) {
      stops.add(null);
    }
  }

  removeStop(int index) {
    if (![0, stops.length - 1].contains(index)) {
      stops.removeAt(index);
    }
  }

  resetStops() {
    stops = List.filled(2, null, growable: true);
  }

  foldStops() {
    final list = <Position>[];
    for (var item in stops) {
      if (item != null) {
        list.add(item);
      }
    }
    if (list.length == 0) {
      list.add(null);
    }
    if (list.length < 3) {
      list.add(null);
    }
    stops = list;
  }

  Map<String, dynamic> toJson() {
    return {
      "tier": tier,
      "method": method.toString().split('.')[1],
      "distance": distance,
      "stops": stops?.where((d) => d != null)?.map((d) => d.toJson())?.toList(),
      "pickup": pickUp.toJson(),
      "time": time
    };
  }
}
