import 'package:bolt_clone/blocs/trip_bloc/trip.dart';
import 'package:bolt_clone/routes/home/screens/screens.dart';
import 'package:bolt_clone/routes/home/utils/screen_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './screen.dart';

class StopsScreen extends Screen {
  final VoidCallback setState;
  List<AddressSearchController> controllers = [];

  StopsScreen({
    BuildContext Function() context,
    AnimationController transitionController,
    AnimationController gestureController,
    ScreenNavigator navigator,
    this.setState,
  }) : super(
          navigator: navigator,
          context: context,
          transitionController: transitionController,
          gestureController: gestureController,
        ) {
    final trip = BlocProvider.of<TripBloc>(context()).state;

    // TODO if (trip is TripRequest) {
    if (true) {
      controllers.add(
        AddressSearchController(
          hint: "Pickup location",
          isDestination: false,
          // text: trip.request.pickUp.address,
          text: "Unnamed",
          useController: (c) {
            navigator.push<AddressSearchScreen>(
              stackType: ScreenNavigator.pushSub,
              payload: AddressSearchType(
                addressIndex: 0,
              ),
            );
          },
          isButton: true,
        ),
      );
      // final locations = trip.request.stops;
      final locations = [null, null];
      for (var i = 0; i < locations.length; i++) {
        final d = locations[i];
        controllers.add(
          AddressSearchController(
            hint: "Add stop",
            isDestination: true,
            text: d?.address,
            useController: (c) {
              final i = controllers.indexOf(c);
              navigator.push<AddressSearchScreen>(
                stackType: ScreenNavigator.pushSub,
                payload: AddressSearchType(
                  addressIndex: i,
                ),
              );
              // TODO use value of i here
            },
            isButton: true,
            useExpansion: i == locations.length - 1
                ? null
                : (c) {
                    final i = controllers.indexOf(c);
                    controllers.removeAt(i);
                    // TODO do some removals
                    setState();
                  },
            reverseIcon: true,
          ),
        );
      }
    }
  }

  @override
  Widget getBottomSheet(BuildContext context) {
    return Container(
      height: Screen.getScreenHeight(context),
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 110, right: 20, left: 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Keep the stops short"),
          Text("Please don't let the driver wait for more than 3 minutes, " +
              "otherwise the ride fare may change"),
        ],
      ),
    );
  }

  bool hasInit = false;

  @override
  double getMaxHeight(BuildContext context) =>
      hasInit ? Screen.getScreenHeight(context) : 0;

  @override
  double getMinHeight(BuildContext context) => getMaxHeight(context);

  @override
  Duration getTransitionDuration() {
    if (!hasInit) {
      return super.getTransitionDuration();
    }
    return Duration(milliseconds: 400);
  }

  @override
  void startEntry() {
    super.startEntry();
    gestureController.value = 1;
    FocusManager.instance.primaryFocus.unfocus();
  }

  @override
  Future<void> startExit() async {
    dispose();
  }

  @override
  SearchHeaderData get useSearchHeader => SearchHeaderData(
        controllers: controllers,
        onPop: navigator.pop,
        title: "Confirm route",
      );

  @override
  ForeSheetData get useForeSheet => ForeSheetData(
        text: () => "Done",
        offsetHeight: getMaxHeight(context()),
        height: hasInit ? getMaxHeight(context()) : 0,
        duration: getTransitionDuration(),
        onTap: () {
          // TODO got to details
          navigator.push<DetailsScreen>(stackType: ScreenNavigator.pushMain);
        },
        reverseGesture: true,
      );

  @override
  void dispose() {
    controllers.forEach((c) => c.dispose());
  }
}
