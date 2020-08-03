import 'package:bolt_clone/routes/home/home.dart';
import 'package:flutter/material.dart';
import './models.dart';
import './screens/screens.dart';
import './utils.dart';

export './screens/default.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  HomeState action;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: 0,
      duration: Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      HomeMainScreen.of(context).menu.registerOnPop(_onPop);
      _showAction(action: HomeState.DEFAULT);
    });
  }

  bool _onPop() {
    if (action == HomeState.DEFAULT) return true;
    _showAction(pop: true);
    return false;
  }

  _showAction({
    HomeState action = HomeState.DEFAULT,
    bool pop = false,
    bool setstate = true,
  }) {
    final home = HomeMainScreen.of(context);
    if (pop) {
      HomeState current = this.action ?? HomeState.DEFAULT;

      switch (current) {
        case HomeState.PLAN_END:
          this.action = HomeState.DEFAULT;
          home.setDefaultView(isChanging: true);
          _controller.reverse();
          break;
        case HomeState.PICK:
          this.action = HomeState.PLAN_END;
          home.setDefaultView(isExpanded: true);
          _controller.forward();
          break;
        case HomeState.RIDE:
          this.action = HomeState.DEFAULT;
          home.setDefaultView();
          break;
        case HomeState.RIDE_DETAILS:
          this.action = HomeState.RIDE;
          home.setDetailsView(isChanging: true);
          _controller.reverse();
          break;
        case HomeState.CONFIRM:
          this.action = HomeState.RIDE;
          home.setDetailsView();
          break;
        case HomeState.PLAN_START:
          this.action = HomeState.CONFIRM;
          home.setReviewView();
          break;
        default:
      }
    } else {
      if (this.action == action) return;
      HomeState current = this.action ?? HomeState.DEFAULT;
      this.action = action;
      switch (action) {
        case HomeState.DEFAULT:
          home.setDefaultView(isChanging: current == HomeState.PLAN_END);
          break;
        case HomeState.PICK:
          home.setChooseDestinationView();
          break;
        case HomeState.PLAN_END:
          home.setDefaultView(
              isExpanded: true, isChanging: current == HomeState.DEFAULT);
          break;
        case HomeState.RIDE:
          if (current == HomeState.PLAN_END || current == HomeState.PICK) {
            _controller.value = 0;
          }
          home.setDetailsView(isChanging: current == HomeState.RIDE_DETAILS);
          break;
        case HomeState.CONFIRM:
          home.setReviewView();
          break;
        case HomeState.PLAN_START:
          break;
        default:
      }
      if (setstate) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get maxHeight =>
      MediaQuery.of(context).size.height -
      MediaQuery.of(context).padding.top -
      20;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        switch (action) {
          case HomeState.DEFAULT:
          case HomeState.PLAN_END:
            // set home display
            return DefaultScreen(
              gestureHandler: GestureHandler(
                controller: _controller,
                maxBound: maxHeight,
              ),
              maxHeight: maxHeight,
              actionCallback: (action, setstate) {
                _showAction(
                  action: action,
                  setstate: setstate,
                );
              },
            );
          case HomeState.PICK:
            // set pick display
            return DestinationScreen(
              actionCallback: (action, setstate) {
                _showAction(
                  action: action,
                  setstate: setstate,
                );
              },
            );
          case HomeState.RIDE:
          case HomeState.RIDE_DETAILS:
            // set ride display
            return DetailsScreen(
              gestureHandler: GestureHandler(
                controller: _controller,
                maxBound: maxHeight - 85,
              ),
              maxHeight: maxHeight - 85,
              actionCallback: (action, setstate) {
                _showAction(
                  action: action,
                  setstate: setstate,
                );
              },
            );
          case HomeState.CONFIRM:
            // set ride display
            return ReviewScreen(
              isPickup: true,
              actionCallback: (action, setstate) {
                _showAction(
                  action: action,
                  setstate: setstate,
                );
              },
            );
          case HomeState.PLAN_START:
            // set pickup
            return PickupScreen(
              isPickup: true,
              maxHeight: maxHeight,
              actionCallback: (action, setstate) {
                _showAction(
                  action: action,
                  setstate: setstate,
                );
              },
            );
          default:
            return Container();
        }
      },
    );
  }
}
