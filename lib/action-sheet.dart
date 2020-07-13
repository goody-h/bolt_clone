import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import './bool-callback.dart';

typedef InsetCallback = void Function(double, bool, bool);
typedef PopCallback = void Function(BoolCallback);
typedef ActionCallback = void Function(Action, bool);

class ActionSheet extends StatefulWidget {
  ActionSheet({Key key, this.inset, this.setInset, this.registerOnPop})
      : super(key: key);
  final double inset;
  final InsetCallback setInset;
  final PopCallback registerOnPop;
  @override
  _ActionSheetState createState() => _ActionSheetState();
}

enum Action { HOME, PLAN_END, PICK, RIDE, RIDE_DETAILS, CONFIRM, PLAN_START }

class _ActionSheetState extends State<ActionSheet>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Action action;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: 0,
      duration: Duration(milliseconds: 600),
    );
    widget.registerOnPop(_onPop);
    _showAction(action: Action.HOME);
  }

  bool _onPop() {
    if (action == Action.HOME) return true;
    _showAction(pop: true);
    return false;
  }

  _showAction({
    Action action = Action.HOME,
    bool pop = false,
    bool setstate = true,
  }) {
    if (pop) {
      Action current = this.action ?? Action.HOME;

      switch (current) {
        case Action.PLAN_END:
          this.action = Action.HOME;
          _controller.reverse();
          // return to home display
          break;
        case Action.PICK:
          this.action = Action.PLAN_END;
          widget.setInset(HomeAction.minHeight, false, false);
          _controller.forward();
          // set plan display
          break;
        case Action.RIDE:
          this.action = Action.HOME;
          widget.setInset(HomeAction.minHeight, true, false);
          // set home display
          break;
        case Action.RIDE_DETAILS:
          this.action = Action.RIDE;
          _controller.reverse();
          // set ride display
          break;
        case Action.CONFIRM:
          this.action = Action.RIDE;
          widget.setInset(RideAction.minHeight, true, true);
          // set ride display
          break;
        case Action.PLAN_START:
          this.action = Action.CONFIRM;
          widget.setInset(PickAction.minHeight, true, true);
          // set ride display
          break;
        default:
      }
    } else {
      if (this.action == action) return;
      Action current = this.action ?? Action.HOME;
      this.action = action;
      switch (action) {
        case Action.HOME:
          widget.setInset(
              HomeAction.minHeight, current != Action.PLAN_END, false);
          // set home display
          break;
        case Action.PICK:
          widget.setInset(PickAction.minHeight, false, true);
          // set pick display
          break;
        case Action.RIDE:
          if (current == Action.PLAN_END || current == Action.PICK) {
            _controller.value = 0;
          }
          widget.setInset(
              RideAction.minHeight, current != Action.RIDE_DETAILS, true);
          // set ride display
          break;
        case Action.CONFIRM:
          // set ride display
          widget.setInset(PickAction.minHeight, true, true);
          break;
        case Action.PLAN_START:
          // set pickup display
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
          case Action.HOME:
          case Action.PLAN_END:
            // set home display
            return HomeAction(
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
          case Action.PICK:
            // set pick display
            return PickAction(
              actionCallback: (action, setstate) {
                _showAction(
                  action: action,
                  setstate: setstate,
                );
              },
            );
          case Action.RIDE:
          case Action.RIDE_DETAILS:
            // set ride display
            return RideAction(
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
          case Action.CONFIRM:
            // set ride display
            return PickAction(
              insets: widget.inset,
              isPickup: true,
              actionCallback: (action, setstate) {
                _showAction(
                  action: action,
                  setstate: setstate,
                );
              },
            );
          case Action.PLAN_START:
            // set pickup
            return HomeAction(
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

class GestureHandler {
  GestureHandler({this.controller, this.maxBound});
  final AnimationController controller;
  final double maxBound;

  double lerp(double min, double max) => lerpDouble(min, max, controller.value);

  void handleDragUpdate(DragUpdateDetails details) {
    controller.value -= details.primaryDelta /
        maxBound; //<-- Update the _controller.value by the movement done by user.
  }

  void handleDragEnd(DragEndDetails details) {
    if (controller.isAnimating ||
        controller.status == AnimationStatus.completed) return;

    final double flingVelocity = details.velocity.pixelsPerSecond.dy /
        maxBound; //<-- calculate the velocity of the gesture
    if (flingVelocity < 0.0)
      controller.fling(
          velocity: max(2.0, -flingVelocity)); //<-- either continue it upwards
    else if (flingVelocity > 0.0)
      controller.fling(
          velocity: min(-2.0, -flingVelocity)); //<-- or continue it downwards
    else
      controller.fling(
          velocity: controller.value < 0.5
              ? -2.0
              : 2.0); //<-- or just continue to whichever edge is closer
  }
}

class RideAction extends StatelessWidget {
  RideAction({
    Key key,
    this.gestureHandler,
    this.inset,
    this.maxHeight,
    this.actionCallback,
  }) : super(key: key);

  final GestureHandler gestureHandler;
  final double inset;
  final double maxHeight;
  final ActionCallback actionCallback;
  static final double minHeight = 200;

  @override
  Widget build(BuildContext context) {
    if (gestureHandler.controller.value == 1) {
      actionCallback(Action.RIDE_DETAILS, false);
    } else if (gestureHandler.controller.value == 0) {
      actionCallback(Action.RIDE, false);
    }
    return Stack(
      children: <Widget>[
        IgnorePointer(
          child: GestureDetector(
            child: Container(
              color: Colors.black.withOpacity(gestureHandler.lerp(0, 0.75)),
              height: double.infinity,
              width: double.infinity,
            ),
            onTap: () {},
          ),
          ignoring: gestureHandler.controller.value == 0,
        ),
        Positioned(
          height: gestureHandler.lerp(minHeight, maxHeight) * inset,
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onVerticalDragUpdate: gestureHandler.handleDragUpdate,
            onVerticalDragEnd: gestureHandler.handleDragEnd,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                color: Colors.white, //background color of box
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 20.0, // soften the shadow
                    spreadRadius: 1.0, //extend the shadow
                    offset: Offset(
                      17.0, // Move to right 10  horizontally
                      17.0, // Move to bottom 10 Vertically
                    ),
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: 100),
                child: FlatButton(
                  onPressed: () {},
                  child: Text("Comfort"),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          height: (100 - gestureHandler.lerp(0, 100)) * inset,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, //background color of box
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2, // soften the shadow
                  spreadRadius: 1.0, //extend the shadow
                )
              ],
            ),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Container(
                height: 100,
                width: double.infinity,
                child: RaisedButton(
                  child: Text("Confirm ride"),
                  onPressed: () {
                    actionCallback(Action.CONFIRM, true);
                  },
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

// recover camera position from google camera
class PickAction extends StatelessWidget {
  PickAction({
    Key key,
    this.insets = 1,
    this.actionCallback,
    this.isPickup = false,
  }) : super(key: key);

  final double insets;
  final ActionCallback actionCallback;
  final bool isPickup;
  static final double minHeight = 150;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      height: minHeight * insets,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          color: Colors.white, //background color of box
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 20.0, // soften the shadow
              spreadRadius: 1.0, //extend the shadow
              offset: Offset(
                17.0, // Move to right 10  horizontally
                17.0, // Move to bottom 10 Vertically
              ),
            )
          ],
        ),
        child: Column(
          children: <Widget>[
            FlatButton(
              child: Text("edit"),
              onPressed: () {
                if (!isPickup) {
                  actionCallback(Action.PLAN_END, true);
                } else {
                  actionCallback(Action.PLAN_START, true);
                }
              },
            ),
            RaisedButton(
              child: Text("Confirm"),
              onPressed: () {
                if (!isPickup) {
                  actionCallback(Action.RIDE, true);
                } else {}
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomeAction extends StatelessWidget {
  HomeAction({
    Key key,
    this.gestureHandler,
    this.inset,
    this.maxHeight,
    this.isPickup = false,
    this.actionCallback,
  }) : super(key: key);

  final bool isPickup;
  final GestureHandler gestureHandler;
  final ActionCallback actionCallback;
  final double inset;
  final double maxHeight;

  static final double minHeight = 250;

  @override
  Widget build(BuildContext context) {
    if (isPickup) {
      actionCallback(Action.PLAN_START, false);
    } else if (gestureHandler.controller.value == 1) {
      actionCallback(Action.PLAN_END, false);
    } else if (gestureHandler.controller.value == 0) {
      actionCallback(Action.HOME, false);
    }

    return Stack(
      children: <Widget>[
        IgnorePointer(
          child: Container(
            color: !isPickup
                ? Colors.black.withOpacity(gestureHandler.lerp(0, 0.75))
                : Colors.black,
            height: double.infinity,
            width: double.infinity,
          ),
          ignoring: isPickup || gestureHandler.controller.value == 0,
        ),
        Positioned(
          height: !isPickup
              ? gestureHandler.lerp(minHeight, maxHeight) * inset
              : maxHeight,
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onVerticalDragUpdate:
                !isPickup ? gestureHandler.handleDragUpdate : null,
            onVerticalDragEnd: !isPickup ? gestureHandler.handleDragEnd : null,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                color: Colors.white, //background color of box
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 20.0, // soften the shadow
                    spreadRadius: 1.0, //extend the shadow
                    offset: Offset(
                      17.0, // Move to right 10  horizontally
                      17.0, // Move to bottom 10 Vertically
                    ),
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: 100),
                child: FlatButton(
                  onPressed: () {
                    if (!isPickup) {
                      actionCallback(Action.RIDE, true);
                    } else {
                      actionCallback(Action.CONFIRM, true);
                    }
                  },
                  child: Text("Rukpokwu"),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          height: !isPickup ? gestureHandler.lerp(0, 180) : 180,
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, //background color of box
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 20.0, // soften the shadow
                  spreadRadius: 1.0, //extend the shadow
                  offset: Offset(
                    -17.0, // Move to right 10  horizontally
                    -17.0, // Move to bottom 10 Vertically
                  ),
                )
              ],
            ),
            child: SingleChildScrollView(
              reverse: true,
              physics: NeverScrollableScrollPhysics(),
              child: Container(
                height: 180,
                width: double.infinity,
              ),
            ),
          ),
        ),
        Positioned(
          height: !isPickup ? gestureHandler.lerp(0, 50) : 50,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, //background color of box
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2, // soften the shadow
                  spreadRadius: 1.0, //extend the shadow
                )
              ],
            ),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Container(
                height: 50,
                width: double.infinity,
                child: FlatButton(
                  onPressed: () {
                    if (!isPickup) {
                      actionCallback(Action.PICK, true);
                    } else {
                      actionCallback(Action.CONFIRM, true);
                    }
                  },
                  child: Text("Choose on map"),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
