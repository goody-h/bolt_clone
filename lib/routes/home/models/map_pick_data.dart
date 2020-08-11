import './address_search_controller.dart';
export './address_search_controller.dart';

class MapPickData {
  final AddressSearchType type;
  final bool canGoFoward;
  final bool canGoBackward;

  MapPickData({this.type, this.canGoFoward, this.canGoBackward});

  bool get isReview => canGoFoward && !canGoBackward;
  bool get canViewDetails => canGoFoward && canGoBackward;
}
