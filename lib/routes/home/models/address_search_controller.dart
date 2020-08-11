import 'package:flutter/material.dart';
import 'package:data_repository/data_repository.dart';
import 'dart:async';

class AddressSearchType {
  AddressSearchType({this.addressIndex});
  final int addressIndex;

  int get index => (addressIndex + addressIndex.abs()) ~/ 2;
  bool get isDestination => addressIndex > 0;
  bool get isReview => addressIndex == -1;
}

class SearchHeaderData {
  SearchHeaderData({
    @required this.controllers,
    @required this.onPop,
    @required this.title,
    this.isWide = false,
    this.titleStream,
  });
  final List<AddressSearchController> controllers;
  final bool isWide;
  final String title;
  final VoidCallback onPop;
  final Stream<String> titleStream;

  static const double backButtonHeight = 54;
  static const double inputHeight = 47.5;
  static const double textFieldHeight = 40.5;

  static double height(int inputCount) {
    return (backButtonHeight + 5) + (inputHeight * inputCount);
  }
}

class AddressResult {
  IconData icon;
  String title;
  String subTitle;
  String text;
  Position position;
}

class AddressSearchController {
  final String hint;
  final bool isDestination;
  final StreamController resultController =
      StreamController<String>.broadcast();
  final FocusNode node = FocusNode();
  final Function(AddressSearchController) useController;
  final Function(AddressSearchController) useExpansion;
  String text;
  TextEditingController controller;
  List<AddressResult> _results = [];
  List<AddressResult> _home = [];

  bool showSuffix = false;
  bool isLoading = false;

  final bool isButton;
  final bool reverseIcon;

  AddressSearchController({
    this.hint,
    this.text,
    this.isDestination,
    this.useController,
    this.isButton = false,
    this.useExpansion,
    this.reverseIcon = false,
  }) {
    node.addListener(_handleFocusChange);

    controller = TextEditingController(text: text);
    controller.addListener(_handleTextChange);

    _init();
  }

  List<AddressResult> get results {}

  Stream<String> get resultStream =>
      resultController.stream.asBroadcastStream();

  _init() async {
    if (isDestination) {
      _getHome();
    }
    if (text != null) {
      _searchAddress();
    }
  }

  _handleTextChange() {
    if (showSuffix) {
      isLoading = true;
      _searchAddress();
      _showResult();
      resultController.sink.add("");
    }
  }

  bool get hasValue => controller.text != null && controller.text != "";

  _handleFocusChange() {
    if (node.hasFocus) {
      showSuffix = true;
      isLoading = true;
      useController?.call(this);
      _showResult();
    } else {
      showSuffix = false;
      isLoading = false;
      if ((controller.text == null || controller.text == "") && text != null) {
        controller.text = text;
      }
    }
    resultController.sink.add("");
  }

  _showResult() {
    Future.delayed(Duration(seconds: 1), () {
      isLoading = false;
      // check that object has not been disposed
      if (!resultController.isClosed) {
        if (_home != null || _results != null) {
          if (useController != null) useController(this);
        }
        resultController.sink.add("");
      }
    });
  }

  _getHome() async {
    // when data is gotten add to controller sink
  }

  _searchAddress() async {
    // when data is gotten add to controller sink
  }

  clear() {
    controller.clear();
  }

  reset() {
    controller.text = text;
    _init();
  }

  setValue(String value) {
    controller.text = value;
  }

  dispose() {
    resultController.close();
    node.removeListener(_handleFocusChange);
    controller.removeListener(_handleTextChange);
  }
}
