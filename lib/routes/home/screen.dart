import 'package:bolt_clone/routes/home/utils/screen_navigator.dart';
import 'package:bolt_clone/routes/home/widgets/searchHeader.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'widgets/widgets.dart';
import 'screens/screens.dart';
import 'home.dart';

export 'screens/screens.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  AnimationController _gestureController;
  AnimationController _transitionController;
  AnimationController _modalTransitionController;

  GestureController controller;
  ScreenNavigator navigator;

  @override
  void initState() {
    super.initState();

    _gestureController = AnimationController(
      vsync: this,
      value: 0,
      duration: Duration(milliseconds: 350),
    );

    navigator = ScreenNavigator(
      context: () => context,
      gestureController: _gestureController,
      setState: () => setState(() {}),
    );

    controller = GestureController(
      onVerticalDragUpdate: _dragUpdate,
      onVerticalDragEnd: _dragEnd,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      HomeMainScreen.of(context).menu.registerOnPop(navigator.pop);
      navigator.init();
    });
  }

  Screen get currentScreen => navigator.currentScreen;

  _dragUpdate(DragUpdateDetails details) {
    _gestureController.value -= details.primaryDelta /
        (currentScreen.getMaxHeight(context) -
            currentScreen.getMinHeight(context));
  }

  _dragEnd(DragEndDetails details) {
    if (_gestureController.isAnimating ||
        _gestureController.status == AnimationStatus.completed) return;

    final double flingVelocity = details.velocity.pixelsPerSecond.dy /
        (currentScreen.getMaxHeight(context) -
            currentScreen.getMinHeight(
                context)); //<-- calculate the velocity of the gesture
    if (flingVelocity < 0.0)
      _gestureController.fling(
          velocity: max(2.0, -flingVelocity)); //<-- either continue it upwards
    else if (flingVelocity > 0.0)
      _gestureController.fling(
          velocity: min(-2.0, -flingVelocity)); //<-- or continue it downwards
    else
      _gestureController.fling(
          velocity: _gestureController.value < 0.5 ? -2.0 : 2.0);
  }

  @override
  void dispose() {
    _gestureController.dispose();
    super.dispose();
  }

  double previousAValue = 0;

  getLowerSheet(List<Widget> stack, bool isAnimating) {
    if (currentScreen.useLowerSheet != null) {
      stack.add(LowerSheet(
        isAnimating: isAnimating,
        revealValue: _gestureController.value,
        onTap: currentScreen.useLowerSheet,
      ));
    }
  }

  getForeSheet(List<Widget> stack) {
    final data = currentScreen.useForeSheet;
    if (data != null) {
      stack.add(ForeSheet(
        text: data.text,
        textStream: data.textStream,
        offsetHeight: data.offsetHeight,
        revealValue: _gestureController.value,
        useSlide: data.useSlide,
        onTap: data.onTap,
        reverseGesture: data.reverseGesture,
      ));
    }
  }

  getSearchHeader(List<Widget> stack, bool isAnimating) {
    final data = currentScreen.useSearchHeader;
    if (data != null) {
      stack.add(
        AddressSearchHeader(
          inputControllers: data.controllers,
          titleStream: data.titleStream,
          onPop: data.onPop,
          title: data.title,
          isWide: data.isWide,
          revealValue: _gestureController.value,
          isAnimating: isAnimating,
        ),
      );
    }
  }

  Widget getModal() {
    if (false) {
      return AnimatedBuilder(
        animation: null,
        builder: (context, child) {
          return Stack(
            children: <Widget>[
              Scrim(
                scrimValue: _modalTransitionController.value,
              ),
              child,
            ],
          );
        },
        child: BottomSheetWrapper(),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Future<bool> onPop() async {
    return navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gestureController,
      builder: (context, modal) {
        final isAnimating = _gestureController.isAnimating ||
            previousAValue != _gestureController.value;
        previousAValue = _gestureController.value;

        final layers = <Widget>[
          Scrim(scrimValue: _gestureController.value, onTap: navigator.pop),
          BottomSheetWrapper(
            revealValue: _gestureController.value,
            maxHeight: currentScreen.getMaxHeight(context),
            minHeight: currentScreen.getMinHeight(context),
            useGesture: currentScreen.useGesture ? controller : null,
            useSlide: currentScreen.useSlide,
            child: currentScreen.getBottomSheet(context),
          ),
        ];

        getLowerSheet(layers, isAnimating);
        getForeSheet(layers);
        getSearchHeader(layers, isAnimating);
        // layers.add(modal);

        return Stack(
          children: layers,
        );
      },
      child: getModal(),
    );
  }
}
