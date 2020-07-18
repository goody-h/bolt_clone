import 'package:flutter/material.dart';
import './models.dart';
import './screens/default.dart';
import './screens/destination.dart';
import './screens/details.dart';
import './screens/pickup.dart';
import './screens/review.dart';
import './utils.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.inset, this.setInset, this.registerOnPop})
      : super(key: key);
  final double inset;
  final InsetHandler setInset;
  final PopStackHandler registerOnPop;
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
      duration: Duration(milliseconds: 600),
    );
    widget.registerOnPop(_onPop);
    _showAction(action: HomeState.DEFAULT);
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
    if (pop) {
      HomeState current = this.action ?? HomeState.DEFAULT;

      switch (current) {
        case HomeState.PLAN_END:
          this.action = HomeState.DEFAULT;
          _controller.reverse();
          break;
        case HomeState.PICK:
          this.action = HomeState.PLAN_END;
          widget.setInset(DefaultScreen.minHeight, false, false);
          _controller.forward();
          break;
        case HomeState.RIDE:
          this.action = HomeState.DEFAULT;
          widget.setInset(DefaultScreen.minHeight, true, false);
          break;
        case HomeState.RIDE_DETAILS:
          this.action = HomeState.RIDE;
          _controller.reverse();
          break;
        case HomeState.CONFIRM:
          this.action = HomeState.RIDE;
          widget.setInset(DetailsScreen.minHeight, true, true);
          break;
        case HomeState.PLAN_START:
          this.action = HomeState.CONFIRM;
          widget.setInset(DestinationScreen.minHeight, true, true);
          break;
        default:
      }
    } else {
      if (this.action == action) return;
      HomeState current = this.action ?? HomeState.DEFAULT;
      this.action = action;
      switch (action) {
        case HomeState.DEFAULT:
          if (setstate)
            widget.setInset(
                PickupScreen.minHeight, current != HomeState.PLAN_END, false);
          break;
        case HomeState.PICK:
          widget.setInset(DestinationScreen.minHeight, false, true);
          break;
        case HomeState.RIDE:
          if (current == HomeState.PLAN_END || current == HomeState.PICK) {
            _controller.value = 0;
          }

          if (setstate)
            widget.setInset(DetailsScreen.minHeight,
                current != HomeState.RIDE_DETAILS, true);
          break;
        case HomeState.CONFIRM:
          widget.setInset(DestinationScreen.minHeight, true, true);
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

  double get maxHeight => MediaQuery.of(context).size.height;

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
              inset: widget.inset,
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
                maxBound: maxHeight - 120,
              ),
              inset: widget.inset,
              maxHeight: maxHeight - 120,
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
              insets: widget.inset,
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
