import 'package:bolt_clone/blocs/trip_bloc/trip.dart';
import 'package:bolt_clone/routes/home/screens/widgets/location_item.dart';
import 'package:bolt_clone/routes/home/utils/screen_navigator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './screen.dart';
import 'package:flutter/material.dart';

import 'address_pick_screen.dart';

class AddressSearchScreen extends Screen {
  AddressSearchScreen({
    BuildContext Function() context,
    AnimationController gestureController,
    ScreenNavigator navigator,
    this.type,
  }) : super(
          navigator: navigator,
          context: context,
          gestureController: gestureController,
        ) {
    searchController = AddressSearchController(
      hint: type.isDestination ? "Address" : "Pickup location",
      isDestination: type.isDestination,
    );
  }

  final AddressSearchType type;
  AddressSearchController searchController;

  static const inputCount = 1;

  String get text {
    final tripState = BlocProvider.of<TripBloc>(context()).state;
    if (tripState is TripRequest) {
      final index = type.index;
      //TODO fetch address using index;
      return "";
    }
    return "";
  }

  _onItemClick(int index) {
    final index = type.index;
    //TODO update location using index
    navigator.pop();
  }

  @override
  Widget getBottomSheet(BuildContext context) {
    return Container(
      height: getMaxHeight(context),
      width: double.infinity,
      padding: EdgeInsets.only(top: SearchHeaderData.height(inputCount)),
      child: StreamBuilder<String>(
        stream: searchController.resultStream,
        builder: (context, snapshot) {
          final results = searchController.results;

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  LocationItem(
                    icon: Icons.home,
                    title: "Port Harcourt",
                    subTitle: "rumuapu",
                    onClick: () {
                      _onItemClick(index);
                    },
                  ),
                  Divider(height: 0.5, indent: 20, endIndent: 20),
                  index == 4
                      ? (type.isDestination
                          ? Container(
                              color: Colors.yellow,
                              height: 25,
                              width: double.infinity,
                            )
                          : Container(
                              color: Colors.blue,
                              height: 25,
                              width: double.infinity,
                            ))
                      : SizedBox.shrink(),
                ],
              );
            },
            itemCount: 5,
          );
        },
        initialData: "",
      ),
    );
  }

  @override
  double getMaxHeight(BuildContext context) => Screen.getScreenHeight(context);

  @override
  double getMinHeight(BuildContext context) => getMaxHeight(context);

  @override
  void startEntry() {
    gestureController.value = 1;
    searchController.node.requestFocus();
  }

  @override
  Future<void> startExit() async {
    FocusManager.instance.primaryFocus.unfocus();
    dispose();
  }

  @override
  SearchHeaderData get useSearchHeader {
    if (searchController.text == null) {
      searchController.text = text;
      searchController.reset();
    }
    return SearchHeaderData(
      controllers: [searchController],
      title: type.isDestination ? "Add stop" : "Set pickup location",
      isWide: true,
      onPop: navigator.pop,
    );
  }

  @override
  get useLowerSheet => () {
        if (type.isReview) {
          navigator.pop();
        } else {
          navigator.push<MapPickScreen>(
            stackType: ScreenNavigator.pushSub,
            payload: MapPickData(
              canGoBackward: true,
              canGoFoward: false,
              type: type,
            ),
          );
        }
        // TODO
      };

  @override
  void dispose() {
    searchController.dispose();
  }
}
