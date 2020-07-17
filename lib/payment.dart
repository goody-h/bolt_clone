import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;

import './models/invoice.dart';
import './models/user.dart';

// String backendUrl = 'https://bolt-paystack.herokuapp.com';
// String backendUrl = 'https://bold-prod.herokuapp.com';
String backendUrl = 'https://bolt-clone-server.herokuapp.com';

String paystackPublicKey = 'pk_test_19e6474f7f96efbd9312b241f1c5f4741590d136';
// String paystackPublicKey = 'pk_live_356c081bb700941e5ef1f15d73e253cbcfb42e98';

const String appName = 'Bolt clone';

typedef StatusCallback = void Function(Map<String, dynamic>);

class PaymentManager {
  PaymentManager({this.handleStatus}) {
    PaystackPlugin.initialize(publicKey: paystackPublicKey);
  }
  StatusCallback handleStatus;

  Future<List<Invoice>> getInvoice(List<InvoiceData> requests) async {
    String url = '$backendUrl/get-invoice';

    var invoice = await post(
      url: url,
      body: {
        "requests": requests.map((req) => req.toMap()).toList(),
      },
      dataCheck: ["invoices"],
    );

    if (invoice["status"] == 0) {
      Iterable<dynamic> invoices =
          invoice["data"]["invoices"] as Iterable<dynamic>;
      return invoices.map((invoice) => Invoice.fromMap(invoice)).toList();
    } else {
      return [];
    }
  }

  Future<String> addCard(BuildContext context, User user,
      {Invoice invoice}) async {
    Charge charge = Charge()
      ..email = user.email
      ..addParameter("firstname", user.firstName)
      ..addParameter("lastname", user.lastName);

    var access = await (invoice != null
        ? initializeRideCharge(invoice, user)
        : initializeCardCharge(user));

    if (access["status"] == 0) {
      charge.amount = invoice?.amount ?? access["data"]["charge"];
      charge.accessCode = access["data"]["code"];
    } else {
      _showMessage(access["error"]["message"]);
      return null;
    }

    try {
      CheckoutResponse response = await PaystackPlugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
        fullscreen: false,
        logo: MyLogo(),
      );
      print('Response = $response');
      String ref = response.reference;
      _showMessage("Checking transaction state");

      var result = await (invoice != null
          ? verifyAndAuthorizeRide(
              ref ?? access["extra"]["ref"], user.userId, response.status)
          : verifyCardCharge(
              ref ?? access["extra"]["ref"], user.userId, response.status));

      if (result["status"] == 0) {
        _showMessage("success");
        return result[invoice != null ? "rideId" : "signature"];
      } else if (!response.status) {
        _showMessage(response.message);
      } else if (result["status"] == 2) {
        // TODO: Set retry policies
        _showMessage(
          "Error occured: Check back within 24 hrs for resolution," +
              "or try again. (${result["error"]["message"]})",
        );
      } else {
        // TODO: Set retry policies
        _showMessage(result["error"]["message"]);
      }
    } catch (e) {
      print(e);
      _showMessage("Error occured, try again later");
    }
    return null;
  }

  Future<String> checkout(
      BuildContext context, Invoice invoice, User user) async {
    if (invoice.method == PaymentMethod.cash) {
      var ride = await authorizeRide(invoice, user);

      if (ride["status"] == 0) {
        _showMessage("success");
        return ride["data"]["rideId"];
      } else {
        // TODO: Set retry policies
        _showMessage(ride["error"]["message"]);
      }
    } else if (invoice.method == PaymentMethod.card) {
      var ride = await chargeAndAuthorizeRide(invoice, user);

      if (ride["status"] == 0) {
        _showMessage("success");
        return ride["data"]["rideId"];
      } else if (ride["status"] == 2) {
        // TODO: Set retry policies
        _showMessage(
          "Error occured: Check back within 24 hrs for resolution," +
              "or try again. (${ride["error"]["message"]})",
        );
      } else {
        // TODO: Set retry policies
        _showMessage(ride["error"]["message"]);
      }
    } else {
      addCard(context, user, invoice: invoice);
    }
    return null;
  }

  Future<Map<String, dynamic>> initializeCardCharge(User user) async {
    String url = '$backendUrl/init-card-charge';

    var charge = await post(
      url: url,
      body: {
        "user": user.toMap(),
      },
      dataCheck: ["code", "charge"],
      extraCheck: ["ref"],
    );
    return charge;
  }

  Future<Map<String, dynamic>> initializeRideCharge(
      Invoice invoice, User user) async {
    String url = '$backendUrl/init-ride-charge';

    var charge = await post(
      url: url,
      body: {
        "invoice": invoice.toMap(),
        "signature": invoice.signature,
        "user": user.toMap(),
      },
      dataCheck: ["code"],
      extraCheck: ["ref"],
    );
    return charge;
  }

  Future<Map<String, dynamic>> verifyCardCharge(
      String ref, String userId, bool status) async {
    String url = '$backendUrl/verify-card-charge/$ref';

    var card = await post(
      url: url,
      body: {"ref": ref, "userId": userId, "status": status},
      dataCheck: ["signature"],
    );
    return card;
  }

  Future<Map<String, dynamic>> authorizeRide(Invoice invoice, User user) async {
    String url = '$backendUrl/authorize-ride';

    var ride = await post(
      url: url,
      body: {
        "invoice": invoice.toMap(),
        "signature": invoice.signature,
        "user": user.toMap(),
      },
      dataCheck: ["rideId"],
    );
    return ride;
  }

  Future<Map<String, dynamic>> chargeAndAuthorizeRide(
      Invoice invoice, User user) async {
    String url = '$backendUrl/charge-and-authorize-ride';

    var ride = await post(
      url: url,
      body: {
        "invoice": invoice.toMap(),
        "signature": invoice.signature,
        "user": user.toMap(),
        "authCode": user.activeCardCode,
      },
      dataCheck: ["rideId"],
    );
    return ride;
  }

  Future<Map<String, dynamic>> verifyAndAuthorizeRide(
      String ref, String userId, bool status) async {
    String url = '$backendUrl/verify-and-authorize-ride/$ref';

    var ride = await post(
      url: url,
      body: {"ref": ref, "userId": userId, "status": status},
      dataCheck: ["rideId"],
    );
    return ride;
  }

  Future<Map<String, dynamic>> post({
    String url,
    Map<String, dynamic> body,
    List<String> dataCheck = const [],
    List<String> extraCheck = const [],
  }) async {
    Map<String, dynamic> result;
    try {
      print("Sending post request to url = $url");
      http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(body),
      );
      print("decoding response");
      print(response.body);

      Map<String, dynamic> data = json.decode(response.body);
      print("decoded response");
      if (response.statusCode == 200) {
        result = data..addAll({"status": 0});
        data = result["data"] as Map<String, dynamic>;
        var dCheck = dataCheck.where((e) => !data.containsKey(e));
        assert(
          dCheck.isEmpty,
          "The following keys were not found in the data, $dCheck",
        );
        data = result["extra"] as Map<String, dynamic>;
        var eCheck = extraCheck.where((e) => !data.containsKey(e));
        assert(
          eCheck.isEmpty,
          "The following keys were not found in the extras, $eCheck",
        );
      } else {
        result = data..addAll({"status": 1});
      }
    } catch (e) {
      result = {
        "status": 2,
        "error": {"message": "$e"}
      };
    }
    print("Post finished, url = ${json.encode(result)}");
    return result;
  }

  _showMessage(String message) {
    handleStatus({"message": message});
  }
}

class MyLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.all(10),
      child: Text(
        "BC",
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
