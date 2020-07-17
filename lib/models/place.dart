// TODO udate place model
class Place {
  const Place();

  Place.fromMap(Map<String, dynamic> place);
  final String place = "New York";
  Map<String, dynamic> toMap() {
    return {"name": place};
  }
}
