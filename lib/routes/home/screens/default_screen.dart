import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bolt_clone/blocs/trip_bloc/trip.dart';
import 'package:bolt_clone/routes/home/home.dart';
import 'package:bolt_clone/routes/home/models/default_screen_data.dart';
import 'package:bolt_clone/routes/home/screens/screens.dart';
import 'package:bolt_clone/routes/home/screens/widgets/location_item.dart';
import 'package:bolt_clone/routes/home/utils/screen_navigator.dart';
import 'package:bolt_clone/utils.dart';
import 'package:data_repository/data_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './screen.dart';
import 'package:flutter/material.dart';

export 'package:bolt_clone/routes/home/models/default_screen_data.dart';

class DefaultSearchScreen extends Screen {
  DefaultSearchScreen({
    BuildContext Function() context,
    AnimationController gestureController,
    ScreenNavigator navigator,
    this.data,
  }) : super(
          navigator: navigator,
          context: context,
          gestureController: gestureController,
        ) {
    pickupController = AddressSearchController(
      hint: "Pickup location",
      isDestination: false,
      useController: (c) {
        if (!c.isLoading) {
          active = c;
        } else {
          _title = "Set pickup location";
        }
        searchController.sink.add("Set pickup location");
        navigator.push<DefaultSearchScreen>(
          stackType: ScreenNavigator.replaceSub,
          payload: DefaultScreenData(
            isHome: data.isHome,
            useDestnaton: c.isDestination,
            expanded: true,
          ),
        );
      },
    );

    destinationController = AddressSearchController(
      hint: "Where to?",
      isDestination: true,
      useController: (c) {
        if (!c.isLoading) {
          active = c;
        } else {
          _title = "Set destination";
        }
        searchController.sink.add("Set destination");
        navigator.push<DefaultSearchScreen>(
          stackType: ScreenNavigator.replaceSub,
          payload: DefaultScreenData(
            isHome: data.isHome,
            useDestnaton: c.isDestination,
            expanded: true,
          ),
        );
      },
      useExpansion: (c) {
        navigator.push<DefaultSearchScreen>(
          stackType: ScreenNavigator.replaceSub,
          payload: DefaultScreenData(
            isHome: data.isHome,
            useDestnaton: active.isDestination,
            expanded: true,
            expandedTransition: true,
          ),
        );
        navigator.push<StopsScreen>(stackType: ScreenNavigator.pushSub);
      },
    );
    active = data.useDestnaton ? destinationController : pickupController;
    gestureController.addListener(_handleController);

    subscriptions = [
      pickupController.resultStream.listen(_updateTitle),
      destinationController.resultStream.listen(_updateTitle),
    ];
    hasData = !data.isHome;
  }

  _updateTitle(_) {
    searchController.sink.add(_currentTitle);
  }

  List<StreamSubscription> subscriptions;
  String _title;
  String get _currentTitle =>
      _title ??
      (active.isDestination ? "Set destination" : "Set pickup location");

  AddressSearchController pickupController;
  AddressSearchController destinationController;

  AddressSearchController active;

  final DefaultScreenData data;
  final rnd = Random();

  String text(bool isDestination) {
    final tripState = BlocProvider.of<TripBloc>(context()).state;
    if (tripState is TripRequest) {
      //TODO fetch address
      return "";
    }
    return "";
  }

  _handleController() {
    if (gestureController.value == 1.0) {
      if (!active.node.hasFocus) {
        Future.delayed(
            Duration(milliseconds: data.expandedTransition ? 1500 : 300), () {
          if (gestureController.value == 1.0) {
            FocusScope.of(context()).requestFocus(active.node);
          }
          if (data.expandedTransition) {
            data.expandedTransition = false;
          }
        });
      }
      navigator.push<DefaultSearchScreen>(
        stackType: ScreenNavigator.replaceSub,
        payload: DefaultScreenData(
          isHome: true,
          useDestnaton: active.isDestination,
          expanded: true,
        ),
      );

      // TODO screen state change
    } else if (gestureController.value == 0.0) {
      // value only reaches 0 in home. always reset to destination
      active = destinationController;
      destinationController.clear();
      pickupController.setValue(pickupController.text);
      navigator.push<DefaultSearchScreen>(
        stackType: ScreenNavigator.replaceMain,
        payload: DefaultScreenData(
          isHome: true,
          useDestnaton: true,
          expanded: false,
        ),
      );
      // TODO screen state change
    } else {
      if (active.node.hasFocus) {
        active.node.unfocus();
      }
    }
  }

  Widget get head => Container(
        height: SearchHeaderData.height(2),
        padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
        child: data.isHome
            ? FadeTransition(
                // TODO FIX ANIMATION
                opacity: AlwaysStoppedAnimation(1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: AppColors.iconGrey,
                        ),
                      ),
                    ),
                    Spacer(flex: 1),
                    Text(
                      "Nice to see you!",
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Spacer(flex: 1),
                    Text(
                      "Where are you going?",
                      style: TextStyle(
                        color: AppColors.blackLight,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(flex: 3),
                    RaisedButton(
                      elevation: 1.5,
                      highlightElevation: 1.5,
                      highlightColor: AppColors.highlightGrey,
                      color: AppColors.white,
                      onPressed: () {
                        gestureController.forward();
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.search,
                              color: AppColors.indigo,
                            ),
                            Container(
                              width: 10,
                            ),
                            Text(
                              "Search destination",
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            : SizedBox.shrink(),
      );

  _onItemClick(int index) {
    BlocProvider.of<TripBloc>(context()).stateId =
        "trip-bloc-${rnd.nextDouble()}";
    BlocProvider.of<TripBloc>(context()).add(TripDestinationUpdated(
      location: Position(
        latitude: 4.902008,
        longitude: 7.005,
        address: "",
      ),
    ));

    navigator.push<DetailsScreen>(stackType: ScreenNavigator.pushMain);
    // TODO GO TO DETAILS
  }

  bool get isExpanded => gestureController.value > 0.5;

  StreamController<String> searchController =
      StreamController<String>.broadcast();

  Stream<String> get titleStream => searchController.stream.asBroadcastStream();

  // TODO remove mock implementation
  bool hasData = false;

  Widget get body => FadeTransition(
        // TODO FIX ANIMATION
        opacity: AlwaysStoppedAnimation(1),
        child: Container(
          height: max(
              lerpDouble(getMinHeight(context()), getMaxHeight(context()),
                      gestureController.value) -
                  SearchHeaderData.height(2),
              0),
          child: StreamBuilder(
            stream: titleStream,
            initialData: "",
            builder: (context, shnapshot) {
              //TODO get results
              final results = active.results;
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
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
                      (!isExpanded && index == 2)
                          ? SizedBox.shrink()
                          : Divider(height: 0.5, indent: 20, endIndent: 20),
                      (isExpanded && index == 4)
                          ? (active.isDestination
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
                itemCount: hasData ? (isExpanded ? 5 : 3) : 0,
              );
            },
          ),
        ),
      );

  @override
  Widget getBottomSheet(BuildContext context) {
    return Column(
      children: <Widget>[
        head,
        body,
      ],
    );
  }

  @override
  double getMaxHeight(BuildContext context) =>
      !hasInit && data.expandedTransition ? 0 : Screen.getScreenHeight(context);

  @override
  double getMinHeight(BuildContext context) {
    if (!hasInit) {
      return 0;
    }
    return data.isHome
        ? (hasData ? minHeight : minHeight2)
        : getMaxHeight(context);
  }

  @override
  double getBottomInset() {
    if (!hasInit) {
      return 0;
    }
    return data.isHome ? (hasData ? minHeight : minHeight2) : null;
  }

  static const double minHeight = 320;
  static const double minHeight2 = 220;

  @override
  Duration getTransitionDuration() {
    if (!hasInit) {
      return super.getTransitionDuration();
    }
    return Duration(
        milliseconds: hasData ? 300 : (data.expandedTransition ? 400 : 200));
  }

  @override
  int get initDuration => data.expandedTransition ? 300 : 50;

  @override
  void onInit() {
    if (data.isHome) {
      HomeMainScreen.of(context()).map.setBaseInset(getMinHeight(context()));
    }
    _handleController();
  }

  @override
  void startEntry() {
    super.startEntry();
    // TODO remove mock implementation of height change
    if (data.isHome) {
      Future.delayed(Duration(milliseconds: 1000), () {
        hasData = true;
        //TODO explain what happened here to "expanded true"
        HomeMainScreen.of(context()).setDefaultView(
            insetHeight: getMinHeight(context()), isExpanded: true);
      });
    }

    if (data.isExanded) {
      gestureController.value = 1.0;
    } else {
      gestureController.value = 0.0;
    }
  }

  @override
  Future<void> startExit() async {
    dispose();
    if (active.node.hasFocus) active.node.unfocus();
  }

  @override
  bool get useGesture => data.isHome;

  @override
  SearchHeaderData get useSearchHeader {
    if (pickupController.text == null) {
      pickupController.text = text(false);
      pickupController.reset();
    }
    if (destinationController.text == null && !data.isHome) {
      destinationController.text = text(true);
      destinationController.reset();
    }
    return SearchHeaderData(
      controllers: [pickupController, destinationController],
      title: _currentTitle,
      titleStream: titleStream.distinct(),
      isWide: false,
      onPop: () {
        if (data.isHome) {
          gestureController.reverse();
        } else {
          navigator.pop();
        }
      },
    );
  }

  @override
  get useLowerSheet => () {
        //TODO goto map
        if (!data.isHome) {
          navigator.push<MapPickScreen>(
            stackType: ScreenNavigator.pushSub,
            payload: MapPickData(
              canGoBackward: true,
              canGoFoward: true,
              type:
                  AddressSearchType(addressIndex: active.isDestination ? 1 : 0),
            ),
          );
        } else if (data.isHome && active.isDestination) {
          navigator.push<MapPickScreen>(
            stackType: ScreenNavigator.pushSub,
            payload: MapPickData(
              canGoBackward: true,
              canGoFoward: true,
              type: AddressSearchType(addressIndex: 1),
            ),
          );
        } else if (data.isHome && !active.isDestination) {
          navigator.push<MapPickScreen>(
            stackType: ScreenNavigator.pushSub,
            payload: MapPickData(
              canGoBackward: true,
              canGoFoward: false,
              type: AddressSearchType(addressIndex: 0),
            ),
          );
        }
      };

  @override
  void dispose() {
    destinationController.dispose();
    pickupController.dispose();
    searchController.close();
    gestureController.removeListener(_handleController);
    subscriptions.forEach((sub) => sub.cancel());
  }
}
