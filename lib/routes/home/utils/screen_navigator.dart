import 'package:bolt_clone/blocs/trip_bloc/trip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../home.dart';
import '../screens/screens.dart';

class _ScreenData {
  const _ScreenData({this.type, this.payload});
  final Type type;
  final dynamic payload;
  static const empty = _ScreenData();
}

class ScreenNavigator {
  List<_ScreenData> mainStack = [];
  List<_ScreenData> subStack = [];
  final VoidCallback setState;
  final BuildContext Function() context;
  TripBloc bloc;

  Screen _currentScreen;
  bool hasInit = false;

  TripState state;

  static const replaceMain = 0;
  static const pushMain = 1;
  static const replaceSub = 2;
  static const pushSub = 3;

  final AnimationController gestureController;
  AnimationController _transitionController;
  AnimationController _modalTransitionController;

  ScreenNavigator({this.context, this.setState, this.gestureController});

  init() {
    hasInit = true;
    onSetScreen(last.type, true);
  }

  List<_ScreenData> get currentStack =>
      subStack.isNotEmpty ? subStack : mainStack;

  modifyPayload<T extends Screen>(dynamic payload) {
    if (last.type == T) {
      currentStack[currentStack.length - 1] = _ScreenData(
        type: T,
        payload: payload,
      );
    }
  }

  push<T extends Screen>({@required int stackType, dynamic payload}) {
    final shouldSetScreen = T != last.type;

    final stack = stackType < 2
        ? (() {
            subStack.clear();
            return mainStack;
          })()
        : subStack;

    // clear stack if is a replacement
    if (stackType % 2 == 0) {
      stack.clear();
    }

    final shouldAdd = stack.isEmpty || T != stack.last.type;

    if (shouldAdd) {
      stack.add(
        _ScreenData(
          type: T,
          payload: payload,
        ),
      );
    }

    if (shouldSetScreen) {
      setScreen();
    }
    if (hasInit) {
      onSetScreen(T, shouldSetScreen);
    }
  }

  checkTripState(TripState state) {
    if (state.runtimeType != this.state?.runtimeType) {
      this.state = state;
      // TODO Check state before creating screen
      push<DefaultSearchScreen>(
        stackType: pushMain,
        payload: DefaultScreenData(
          isHome: true,
          useDestnaton: true,
          expanded: false,
        ),
      );
    }
  }

  setScreen() {
    final current = _currentScreen;
    if (last.type == DefaultSearchScreen) {
      _currentScreen = DefaultSearchScreen(
        context: context,
        gestureController: gestureController,
        data: last.payload as DefaultScreenData,
        navigator: this,
      );
    } else if (last.type == DetailsScreen) {
      _currentScreen = DetailsScreen(
        context: context,
        gestureController: gestureController,
        navigator: this,
        invoiceCount: last.payload ?? 2,
      );
    } else if (last.type == MapPickScreen) {
      _currentScreen = MapPickScreen(
        context: context,
        gestureController: gestureController,
        data: last.payload as MapPickData,
        navigator: this,
      );
    } else if (last.type == StopsScreen) {
      _currentScreen = StopsScreen(
        context: context,
        gestureController: gestureController,
        setState: setState,
        navigator: this,
      );
    } else if (last.type == AddressSearchScreen) {
      _currentScreen = AddressSearchScreen(
        context: context,
        gestureController: gestureController,
        type: last.payload as AddressSearchType,
        navigator: this,
      );
    }
    beginTransition(current);
  }

  beginTransition(Screen old) async {
    if (old != null) {
      await old.startExit();
      setState();
    }
    _currentScreen.startEntry();
  }

  onSetScreen(Type type, bool isNewScreen) {
    // TODO FIX MAP HANDLER
    final home = HomeMainScreen.of(context());
    if (type == DefaultSearchScreen) {
      final data = last.payload as DefaultScreenData;
      if (data.isHome) {
        home.setDefaultView(
            isChanging: !isNewScreen, isExpanded: data.expanded);
      }
    } else if (type == DetailsScreen) {
      home.setDetailsView(
          isChanging: !isNewScreen,
          insetHeight: DetailsScreen.getHeight(last.payload));
    } else if (type == MapPickScreen) {
      final data = last.payload as MapPickData;
      if (data.isReview) {
        home.setReviewView();
      } else if (data.type.isDestination) {
        home.setChooseDestinationView(data.type);
      } else {
        home.setCoosePickupView();
      }
    }
  }

  _ScreenData get last => subStack.isNotEmpty
      ? subStack.last
      : (mainStack.isNotEmpty ? mainStack.last : _ScreenData.empty);

  bool pop({dynamic payload, List<Type> until}) {
    if (mainStack.isEmpty) {
      return true;
    }

    final pop =
        subStack.isNotEmpty ? subStack.removeLast() : mainStack.removeLast();
    if (mainStack.isEmpty) {
      return true;
    }

    if (until != null && !until.contains(last.type)) {
      while (!until.contains(last.type)) {
        subStack.isNotEmpty ? subStack.removeLast() : mainStack.removeLast();
        if (mainStack.isEmpty) {
          return true;
        }
      }
    }

    // TODO check that final stack is not empty
    if (last.type != pop.type) {
      setScreen();
    } else {
      // TODO handle modals
      gestureController.reverse();
    }
    onSetScreen(last.type, last.type != pop.type);

    return false;
  }

  Screen get currentScreen {
    if (_currentScreen == null) {
      bloc = BlocProvider.of<TripBloc>(context());
      bloc.listen(checkTripState);
      final trip = bloc.state;
      checkTripState(trip);
    }
    return _currentScreen;
  }
}
