import '../../models/types.dart';

enum HomeState {
  DEFAULT,
  PLAN_END,
  PICK,
  RIDE,
  RIDE_DETAILS,
  CONFIRM,
  PLAN_START
}

typedef InsetHandler = void Function(double, bool, bool);
typedef PopStackHandler = void Function(BoolCallback);
typedef HomeStateHandler = void Function(HomeState, bool);
