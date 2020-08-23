import 'package:bolt_clone/blocs/blocs.dart';
import 'package:bolt_clone/resources/payment.dart';
import 'package:bolt_clone/routes/home/home.dart';
import 'package:bolt_clone/routes/home/models/map_pick_data.dart';
import 'package:bolt_clone/routes/home/screens/screens.dart';
import 'package:bolt_clone/routes/home/utils/screen_navigator.dart';
import 'package:bolt_clone/utils.dart';
import 'package:data_repository/data_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './screen.dart';
import 'address_search_screen.dart';
import 'details_screen.dart';

export 'package:bolt_clone/routes/home/models/map_pick_data.dart';

class MapPickScreen extends Screen {
  final MapPickData data;

  MapPickScreen({
    BuildContext Function() context,
    AnimationController gestureController,
    ScreenNavigator navigator,
    this.data,
  }) : super(
          navigator: navigator,
          context: context,
          gestureController: gestureController,
        );

  Widget get pickup => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Confirm pickup",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 12),
            child: data.isReview
                ? Text(
                    "Pickup in 1 min  N850",
                    style: TextStyle(color: AppColors.textGrey),
                  )
                : Text(
                    "Move the map to set your exact pickup " +
                        "spot before requesting",
                    style: TextStyle(color: AppColors.textGrey),
                  ),
          ),
          Divider(height: 1),
          SizedBox(
            height: 55,
            width: double.infinity,
            child: Row(
              children: <Widget>[
                Icon(Icons.album, size: 14, color: AppColors.greenIcon),
                Container(width: 10),
                Text(
                  'Unnamed Road',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(flex: 1),
                SizedBox(
                  height: 55,
                  width: 55,
                  child: FlatButton(
                    onPressed: () {
                      if (data.canGoBackward) {
                        navigator.pop();
                      } else {
                        navigator.push<AddressSearchScreen>(
                          stackType: ScreenNavigator.pushSub,
                          payload: AddressSearchType(
                            addressIndex: data.type.addressIndex,
                          ),
                        );
                      }
                      // TODO FIX EDIT BUTTON CLICK
                    },
                    shape: CircleBorder(side: BorderSide.none),
                    child: Icon(Icons.edit, color: AppColors.iconGrey),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget get destination => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Set stop location",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackLight,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: FlatButton(
              highlightColor: AppColors.highlightGrey,
              color: AppColors.inputGrey,
              onPressed: () {
                if (data.canGoBackward) {
                  navigator.pop();
                } else {
                  navigator.push<AddressSearchScreen>(
                    stackType: ScreenNavigator.pushSub,
                    payload: AddressSearchType(
                      addressIndex: data.type.addressIndex,
                    ),
                  );
                }
              },
              child: Container(
                height: 50,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Unnamed Road",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Spacer(flex: 1),
                    Icon(
                      Icons.search,
                      size: 28,
                      color: AppColors.blackLight,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  @override
  Widget getBottomSheet(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: data.type.isDestination ? destination : pickup,
    );
  }

  static final double minHeight = 210;

  @override
  double getMaxHeight(BuildContext context) => getMinHeight(context);

  @override
  double getMinHeight(BuildContext context) =>
      hasInit || data.type.isDestination ? minHeight : 0;

  @override
  Duration getTransitionDuration() {
    if (!hasInit) {
      return super.getTransitionDuration();
    }
    return Duration(milliseconds: 200);
  }

  @override
  void onInit() {
    if (!data.type.isDestination) {
      HomeMainScreen.of(context()).map.setBaseInset(getMinHeight(context()));
    }
  }

  @override
  void startEntry() {
    super.startEntry();
    gestureController.value = 0;
    FocusManager.instance.primaryFocus.unfocus();
  }

  @override
  double getBottomInset() => getMinHeight(context());

  @override
  Future<void> startExit() async {}

  @override
  ForeSheetData get useForeSheet => ForeSheetData(
        offsetHeight: minHeight,
        height: minHeight,
        text: () => data.isReview ? "CONFIRM ORDER" : "CONFIRM",
        onTap: () async {
          if (data.canViewDetails) {
            navigator.push<DetailsScreen>(stackType: ScreenNavigator.pushMain);
          } else if (data.isReview) {
            // TODO start payment
            var manager = PaymentProvider(handleStatus: (m) {
              _showMessage(context(), m["message"]);
            });
            final state = BlocProvider.of<UserBloc>(context()).state;
            if (state is UserLoaded) {
              await manager.checkout(context(), Invoice(), state.user);
            }
          } else {
            navigator.pop(until: [StopsScreen, DefaultSearchScreen]);
          }
          // TODO FIX BUTTON CLICK
        },
      );

  _showMessage(BuildContext context, String message,
      [Duration duration = const Duration(seconds: 5)]) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(message),
      duration: duration,
      action: new SnackBarAction(
          label: 'CLOSE',
          onPressed: () => Scaffold.of(context).removeCurrentSnackBar()),
    ));
  }
}
