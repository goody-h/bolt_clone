import './card.dart';

//TODO
class User {
  User();

  String userId = "XXXXXXXXXXXX";
  String email = "goodhopeordu@yahoo.com";
  String firstName = "Jane";
  String lastName = "Doe";
  String phoneNumber = "+2348121451240";
  Map<String, Card> cards;
  String activeMethod;

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "userId": userId,
      "firstname": firstName,
      "lastname": lastName,
      "phoneNumber": phoneNumber,
    };
  }

  String get activeCardCode {
    var code = cards[activeMethod]?.authCode;
    if (code == null)
      throw Exception("There are no active cards for this user");
    return code;
  }
}
