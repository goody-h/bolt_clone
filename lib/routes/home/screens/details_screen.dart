import 'dart:async';
import 'dart:ui';

import 'package:bolt_clone/blocs/user_bloc/user.dart';
import 'package:bolt_clone/blocs/trip_bloc/trip.dart';
import 'package:bolt_clone/routes/home/home.dart';
import 'package:bolt_clone/routes/home/screens/widgets/invoice_item.dart';
import 'package:bolt_clone/routes/home/utils/screen_navigator.dart';
import 'package:bolt_clone/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './screen.dart';
import 'address_pick_screen.dart';
import 'default_screen.dart';

class DetailsScreen extends Screen {
  DetailsScreen({
    BuildContext Function() context,
    AnimationController transitionController,
    AnimationController gestureController,
    ScreenNavigator navigator,
    this.invoiceCount,
  }) : super(
          navigator: navigator,
          context: context,
          transitionController: transitionController,
          gestureController: gestureController,
        ) {
    gestureController.addListener(_handleGesture);
  }

  _handleGesture() {
    if (gestureController.value == 1.0) {
      navigator.push<DetailsScreen>(
        stackType: ScreenNavigator.replaceSub,
      );
      // TODO screen state change
    } else if (gestureController.value == 0.0) {
      // value only reaches 0 in home. always reset to destination

      navigator.push<DetailsScreen>(
        stackType: ScreenNavigator.pushMain,
      );
      // TODO screen state change
    }
  }

  StreamController textController = StreamController<String>.broadcast();
  String buttonText;

  bool get isExpanded => gestureController.value > 0.5;
  static const double footerHeight = 135;

  // TODO REMOVE TEST IMPLEMENTATION
  bool hasThree = false;

  Widget body(TripState state) {
    if (state is TripRequest) {
      //TODO get invoices and current tier
      final invoices = state.invoices;
      final tier = state.activeTier;
    }

    // TODO REMOVE TEST IMPLEMENTATION
    // if (!hasThree) {
    //   hasThree = true;
    //   Future.delayed(Duration(milliseconds: 500), () {
    //     invoiceCount = 3;
    //     navigator.modifyPayload<DetailsScreen>(3);
    //     HomeMainScreen.of(context()).setDetailsView(
    //         insetHeight: getMinHeight(context()), tag: "details3");
    //   });
    // }

    buttonText = "CONFIRM LITE";
    print(buttonText);
    textController.sink.add(buttonText);

    return FadeTransition(
      // TODO FIX ANIMATION
      opacity: AlwaysStoppedAnimation(1),
      child: Container(
        height: lerpDouble(getMinHeight(context()), getMaxHeight(context()),
            gestureController.value),
        child: !isExpanded
            ? Container(
                height: getMinHeight(context()),
                padding: EdgeInsets.only(bottom: footerHeight, top: 20),
                //possible scroll view
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    InvoiceItem(
                      icon: Icons.local_taxi,
                      title: "Lite",
                      subTitle: "6 min",
                      isSelected: true,
                      onClick: () {
                        gestureController.forward();
                      },
                    ),
                    InvoiceItem(
                      icon: Icons.directions_transit,
                      title: "Premium",
                      subTitle: "10 min",
                      isSelected: false,
                      onClick: () {
                        gestureController.forward();
                      },
                    ),
                  ],
                ),
              )
            : Container(
                margin: EdgeInsets.only(top: 20),
                height: getMaxHeight(context()) - 20,
                color: Colors.blue,
                width: double.infinity,
                child: Text("details"),
              ),
      ),
    );
  }

  Widget footer(TripState state) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: lerpDouble(0, -footerHeight, gestureController.value),
      child: Container(
        height: footerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white, //background color of box
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.2),
              blurRadius: 2, // soften the shadow
              spreadRadius: 1.0, //extend the shadow
            )
          ],
        ),
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoaded) {
              //TODO get current payment method from user
              final method = state.user.paymentMethod;
              // get card if is not cash
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: FlatButton(
                    onPressed: () {
                      // TODO fix payment method
                      navigator.push<DefaultSearchScreen>(
                        stackType: ScreenNavigator.replaceSub,
                        payload: DefaultScreenData(
                          isHome: false,
                          useDestnaton: true,
                          expanded: true,
                        ),
                      );
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.credit_card),
                        Container(width: 10),
                        Text('Cash'),
                        Icon(Icons.keyboard_arrow_down),
                        Spacer(flex: 1),
                        Container(
                          child: Text("-40% promo",
                              style: TextStyle(
                                  color: AppColors.white, fontSize: 12)),
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            color: AppColors.orangeTag,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget getBottomSheet(BuildContext context) {
    return Container(
      height: lerpDouble(getMinHeight(context), getMaxHeight(context),
          gestureController.value),
      width: double.infinity,
      child: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          return Stack(
            children: <Widget>[
              body(state),
              footer(state),
            ],
          );
        },
      ),
    );
  }

  int invoiceCount;

  @override
  double getMaxHeight(BuildContext context) =>
      Screen.getScreenHeight(context) - 85;

  @override
  double getMinHeight(BuildContext context) {
    if (!hasInit) {
      return 0;
    }
    return (invoiceCount ?? 2) < 3 ? minHeight : minHeight3;
  }

  bool hasInit = false;

  @override
  double getBottomInset() => getMinHeight(context());

  static double getHeight(int count) =>
      (count ?? 2) < 3 ? minHeight : minHeight3;

  static const double minHeight = 320;
  static const double minHeight3 = 350;

  @override
  Duration getTransitionDuration() {
    if (!hasInit) {
      return super.getTransitionDuration();
    }
    return Duration(milliseconds: 200);
  }

  @override
  void onInit() {
    HomeMainScreen.of(context()).map.setBaseInset(getMinHeight(context()));
  }

  @override
  void startEntry() {
    super.startEntry();
    gestureController.value = 0;
  }

  @override
  Future<void> startExit() async {
    dispose();
  }

  @override
  bool get useGesture => gestureController.value != 0.0;

  @override
  ForeSheetData get useForeSheet => ForeSheetData(
        offsetHeight: minHeight,
        text: () => buttonText,
        height: hasInit ? minHeight : 0,
        duration: getTransitionDuration(),
        gestureOffset: footerHeight,
        onTap: () {
          navigator.push<MapPickScreen>(
            stackType: ScreenNavigator.pushMain,
            payload: MapPickData(
              canGoBackward: false,
              canGoFoward: true,
              type: AddressSearchType(addressIndex: -1),
            ),
          );
        },
        textStream: textController.stream.distinct(),
      );

  @override
  void dispose() {
    textController.close();
    gestureController.removeListener(_handleGesture);
  }
}
