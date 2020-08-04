import 'dart:async';

import 'package:bolt_clone/routes/home/home.dart';
import 'package:data_repository/data_repository.dart';
import 'package:flutter/material.dart';
import '../models.dart';
import '../utils.dart';

class DefaultScreen extends StatefulWidget {
  DefaultScreen({
    Key key,
    this.gestureHandler,
    this.maxHeight,
    this.actionCallback,
  }) : super(key: key);

  final GestureHandler gestureHandler;
  final HomeStateHandler actionCallback;
  final double maxHeight;

  static final double minHeight = 320;

  @override
  _DefaultScreenState createState() => _DefaultScreenState();
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
  final StreamController sController = StreamController<int>.broadcast();
  final FocusNode node = FocusNode();
  final Function(AddressSearchController) useController;
  String text;
  TextEditingController controller;
  List<AddressResult> _results = [];
  List<AddressResult> _home = [];

  bool showSuffix = false;
  bool isLoading = false;

  AddressSearchController(
      {this.hint, this.text, this.isDestination, this.useController}) {
    node.addListener(_handleFocusChange);

    controller = TextEditingController(text: text);
    controller.addListener(_handleTextChange);

    _init();
  }

  List<AddressResult> get results {}

  Stream get stream => sController.stream.asBroadcastStream();

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
      Future.delayed(Duration(seconds: 1), () {
        isLoading = false;
        if (_home != null || _results != null) {
          _showResult();
        }
        sController.sink.add(0);
      });
      sController.sink.add(0);
    }
  }

  _handleFocusChange() {
    if (node.hasFocus) {
      showSuffix = true;
      isLoading = true;
      Future.delayed(Duration(seconds: 1), () {
        isLoading = false;
        if (_home != null || _results != null) {
          _showResult();
        }
        sController.sink.add(0);
      });
    } else {
      showSuffix = false;
      isLoading = false;
      if ((controller.text == null || controller.text == "") && text != null) {
        controller.text = text;
      }
    }
    sController.sink.add(0);
  }

  _showResult() {
    useController(this);
  }

  _getHome() async {}

  _searchAddress() async {}

  clear() {
    controller.clear();
  }

  setValue(String value) {
    controller.text = value;
  }

  dispose() {
    sController.close();
  }
}

class _DefaultScreenState extends State<DefaultScreen> {
  @override
  void initState() {
    super.initState();
    s1 = AddressSearchController(
      isDestination: false,
      hint: "Where ?",
      text: "Unamed Road",
      useController: (c) {
        print("set s1");
        active = c;
      },
    );
    s2 = AddressSearchController(
      isDestination: true,
      hint: "Where ?",
      useController: (c) {
        print("set s2");
        active = c;
      },
    );
    widget.gestureHandler.controller.addListener(_handleController);
    active = s2;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _handleController();
    });
  }

  AddressSearchController active;

  _handleController() {
    print(widget.gestureHandler.controller.value);
    if (widget.gestureHandler.controller.value == 1.0) {
      if (!active.node.hasFocus) {
        FocusScope.of(context).requestFocus(active.node);
      }
    } else if (widget.gestureHandler.controller.value == 0.0) {
      active = s2;
      s2.clear();
      s1.setValue(s1.text);
    } else {
      if (active.node.hasFocus) {
        active.node.unfocus();
      }
    }
  }

  AddressSearchController s1;
  AddressSearchController s2;

  Widget _getHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 50,
          child: FlatButton(
            onPressed: () {
              widget.gestureHandler.controller.reverse();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.arrow_back),
                Container(width: 10),
                Text(
                  "Set destination",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 45,
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: _getTextField(s1),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: _getTextField(s2),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 40),
              child: SizedBox(
                width: 55,
                height: 55,
                child: FlatButton(
                  shape: CircleBorder(side: BorderSide.none),
                  onPressed: () {},
                  child: Icon(Icons.add),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _getTextField(AddressSearchController search) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Color(int.parse("0xFFF4F4F6")),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: TextField(
              maxLines: 1,
              controller: search.controller,
              focusNode: search.node,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: search.hint,
                contentPadding: EdgeInsets.all(10),
                isDense: true,
                hintStyle: TextStyle(
                    fontSize: 16, color: Colors.grey, letterSpacing: 1),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(int.parse("0xFFF4F4F6")),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(int.parse("0xFFF4F4F6")),
                  ),
                ),
              ),
              cursorColor: Colors.green,
              style: TextStyle(fontSize: 16),
            ),
          ),
          _getSuffix(search)
        ],
      ),
    );
  }

  Widget _getSuffix(final AddressSearchController search) {
    return SizedBox(
      height: 40,
      width: 40,
      child: StreamBuilder<int>(
        stream: search.stream,
        builder: (context, snap) {
          if (!search.showSuffix ||
              (!search.isLoading && (search.controller.text ?? "") == "")) {
            return Container();
          } else if (search.isLoading) {
            return Padding(
              padding: EdgeInsets.all(13),
              child: CircularProgressIndicator(
                strokeWidth: 1,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          } else {
            return FlatButton(
              padding: EdgeInsets.only(right: 0, left: 0),
              onPressed: () {
                search.clear();
              },
              shape: CircleBorder(side: BorderSide.none),
              child: Icon(
                Icons.close,
                size: 18,
                color: Colors.grey,
              ),
            );
          }
        },
        initialData: 0,
      ),
    );
  }

  Widget _getListItem(IconData icon, String title, String subTitle) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: FlatButton(
        onPressed: () {
          widget.actionCallback(HomeState.RIDE, true);
        },
        padding: EdgeInsets.only(right: 20, left: 20, bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                icon,
                color: Colors.grey,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(title),
                Text(
                  subTitle,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gestureHandler.controller.value == 1) {
      widget.actionCallback(HomeState.PLAN_END, false);
    } else if (widget.gestureHandler.controller.value == 0) {
      widget.actionCallback(HomeState.DEFAULT, false);
    }

    return Stack(
      children: <Widget>[
        IgnorePointer(
          child: Container(
            color:
                Colors.black.withOpacity(widget.gestureHandler.lerp(0, 0.75)),
            height: double.infinity,
            width: double.infinity,
          ),
          ignoring: widget.gestureHandler.controller.value == 0,
        ),
        AnimatedBuilder(
          animation: HomeMainScreen.of(context).inset.controller,
          child: GestureDetector(
            onVerticalDragUpdate: widget.gestureHandler.handleDragUpdate,
            onVerticalDragEnd: widget.gestureHandler.handleDragEnd,
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
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2, // soften the shadow
                    spreadRadius: 1.0, //extend the shadow
                  )
                ],
              ),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Padding(
                  //TODO remove unecessary padding
                  padding: EdgeInsets.only(
                    bottom: 0,
                    // right: 20,
                    // left: 20,
                  ), // update with animation value
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 135,
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, right: 20, left: 20),
                        child: Opacity(
                          opacity: 1 - widget.gestureHandler.controller.value,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Container(
                                  height: 4,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Spacer(flex: 1),
                              Text(
                                "Nice to see you!",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Spacer(flex: 1),
                              Text(
                                "Where are you going?",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(flex: 3),
                              RaisedButton(
                                elevation: 1.5,
                                highlightElevation: 1.5,
                                highlightColor: Color(int.parse("0xFFDCDCDC")),
                                color: Colors.white,
                                onPressed: () {
                                  widget.gestureHandler.controller.forward();
                                },
                                child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Icon(
                                        Icons.search,
                                        color: Colors.blueAccent,
                                      ),
                                      Container(
                                        width: 10,
                                      ),
                                      Text(
                                        "Search destination",
                                        style: TextStyle(
                                          color: Colors.grey,
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
                        ),
                      ),
                      Opacity(
                        opacity: (0.5 - widget.gestureHandler.controller.value)
                                .abs() /
                            0.5,
                        child: Container(
                          height: 185,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _getListItem(Icons.home, "Home",
                                  "1 Imenwo Str. Rukpoku, Port Harcourt"),
                              Divider(height: 0.5, indent: 20, endIndent: 20),
                              _getListItem(Icons.work, "Work",
                                  "Choba Campus Business Area, Uniport"),
                              Divider(height: 0.5, indent: 20, endIndent: 20),
                              _getListItem(
                                  Icons.location_on,
                                  "Peter Odlili Road",
                                  "Port Harcourt, Nigeria"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          builder: (context, child) {
            return Stack(
              children: <Widget>[
                Positioned(
                  height: widget.gestureHandler
                          .lerp(DefaultScreen.minHeight, widget.maxHeight) *
                      HomeMainScreen.of(context).inset.controller.value,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: child,
                ),
              ],
            );
          },
        ),
        Positioned(
          height: widget.gestureHandler
              .lerp(0, MediaQuery.of(context).padding.top + 145),
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            height: MediaQuery.of(context).padding.top + 145,
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
              reverse: true,
              physics: NeverScrollableScrollPhysics(),
              child: Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                height: MediaQuery.of(context).padding.top + 145,
                width: double.infinity,
                child: _getHeader(),
              ),
            ),
          ),
        ),
        Positioned(
          height: widget.gestureHandler.lerp(0, 50),
          left: 0,
          right: 0,
          bottom: widget.gestureHandler.controller.value == 1
              ? MediaQuery.of(context).viewInsets.bottom
              : 0,
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
                    widget.actionCallback(HomeState.PICK, true);
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
