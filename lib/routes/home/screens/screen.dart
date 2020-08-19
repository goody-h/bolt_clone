import 'package:bolt_clone/routes/home/models/address_search_controller.dart';
import 'package:bolt_clone/routes/home/models/fore_sheet_data.dart';
import 'package:bolt_clone/routes/home/utils/screen_navigator.dart';
import 'package:flutter/material.dart';

export 'package:bolt_clone/routes/home/models/fore_sheet_data.dart';
export 'package:bolt_clone/routes/home/models/address_search_controller.dart';

abstract class Screen {
  Screen({
    @required this.context,
    @required this.transitionController,
    @required this.gestureController,
    @required this.navigator,
  });
  final BuildContext Function() context;
  final AnimationController transitionController;
  final AnimationController gestureController;
  final ScreenNavigator navigator;

  bool hasInit = false;

  // Transition methods
  Future<void> startExit();
  void startEntry() {
    Future.delayed(
      Duration(milliseconds: initDuration),
      () {
        hasInit = true;
        onInit();
        gestureController.notifyListeners();
      },
    );
  }

  // Dimensions method
  double getMinHeight(BuildContext context);
  double getMaxHeight(BuildContext context);
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

  // Animation functions
  bool get useGesture => false;

  VoidCallback get useLowerSheet => null;
  ForeSheetData get useForeSheet => null;
  SearchHeaderData get useSearchHeader => null;

  // bottom sheet
  Widget getBottomSheet(BuildContext context);

  Duration getTransitionDuration() => Duration.zero;

  void onInit() {}

  int get initDuration => 50;

  double getBottomInset() => null;

  void dispose() {}
}
