import 'dart:math';
import 'dart:ui';
import 'package:bolt_clone/routes/home/models/address_search_controller.dart';
import 'package:bolt_clone/utils.dart';
import 'package:flutter/material.dart';

export 'package:bolt_clone/routes/home/models/address_search_controller.dart';

class AddressSearchHeader extends StatelessWidget {
  AddressSearchHeader({
    @required this.inputControllers,
    @required this.onPop,
    @required this.title,
    this.titleStream,
    this.isWide = true,
    this.revealValue = 1,
    this.isAnimating,
  });

  final List<AddressSearchController> inputControllers;
  final VoidCallback onPop;
  final double revealValue;
  final bool isWide;
  final String title;
  final Stream<String> titleStream;
  final bool isAnimating;

  final animationDratiion = Duration(milliseconds: 400);

  double topPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  double maxHeight(BuildContext context) {
    return topPadding(context) +
        SearchHeaderData.height(inputControllers.length);
  }

  bool get useReverseReveal => revealValue != 1.0;

  Widget _getHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: SearchHeaderData.backButtonHeight,
          child: FlatButton(
            onPressed: onPop,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.arrow_back),
                Container(width: 10),
                StreamBuilder<String>(
                  key: ValueKey(title),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    );
                  },
                  initialData: title,
                  stream: titleStream ?? Stream<String>.value(title),
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
                children: inputControllers
                    .map<Widget>((c) => _getTextField(c))
                    .toList(),
              ),
            ),
          ],
        ),
        Container(height: 5)
      ],
    );
  }

  Widget _getTextField(AddressSearchController search) {
    Widget field = Container(
      width: double.infinity,
      height: SearchHeaderData.textFieldHeight,
      decoration: !search.isButton
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: AppColors.inputGrey,
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: !search.isButton
                ? TextField(
                    readOnly: search.isButton,
                    maxLines: 1,
                    controller: search.controller,
                    focusNode: search.node,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: search.hint,
                      contentPadding: EdgeInsets.all(10),
                      isDense: true,
                      hintStyle: TextStyle(
                          fontSize: 16,
                          color: AppColors.textGrey,
                          letterSpacing: 1),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.inputGrey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.inputGrey,
                        ),
                      ),
                    ),
                    cursorColor: AppColors.greenIcon.withOpacity(0.5),
                    style: TextStyle(fontSize: 16),
                  )
                : Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      search.hasValue ? search.controller.text : search.hint,
                      style: TextStyle(
                        fontSize: 16,
                        color: search.hasValue
                            ? AppColors.blackLight
                            : AppColors.textGrey,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
          ),
          _getSuffix(search)
        ],
      ),
    );

    if (search.isButton) {
      field = SizedBox(
        height: SearchHeaderData.textFieldHeight,
        child: FlatButton(
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
          color: AppColors.inputGrey,
          padding: EdgeInsets.zero,
          onPressed: () => search.useController(search),
          child: field,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: field,
        ),
        !isWide
            ? (search.useExpansion != null
                ? SizedBox(
                    width: 55,
                    height: SearchHeaderData.inputHeight,
                    child: FlatButton(
                      padding: EdgeInsets.zero,
                      shape: CircleBorder(side: BorderSide.none),
                      onPressed: () {
                        search.useExpansion(search);
                      },
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                            begin: 0.0,
                            end: search.reverseIcon ? -pi / 4 : 0.0),
                        duration: animationDratiion,
                        builder: (context, rotation, child) {
                          return Transform.rotate(
                            angle: rotation,
                            child: Icon(
                              Icons.add,
                              size: 28,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Container(width: 55, height: SearchHeaderData.inputHeight))
            : Container(width: 25, height: SearchHeaderData.inputHeight),
      ],
    );
  }

  Widget _getSuffix(final AddressSearchController search) {
    return SizedBox(
      height: 40,
      width: 40,
      child: StreamBuilder<String>(
        stream: search.resultStream,
        builder: (context, snap) {
          if (!search.showSuffix ||
              (!search.isLoading && (search.controller.text ?? "") == "")) {
            return Container();
          } else if (search.isLoading) {
            return Padding(
              padding: EdgeInsets.all(13),
              child: CircularProgressIndicator(
                strokeWidth: 1,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenIcon),
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
                color: AppColors.iconGrey,
              ),
            );
          }
        },
        initialData: "",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: AnimatedContainer(
        duration:
            revealValue == 1.0 && !isAnimating && inputControllers.length > 1
                ? animationDratiion
                : Duration.zero,
        height: lerpDouble(0, maxHeight(context), revealValue),
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
        child: SingleChildScrollView(
          reverse: useReverseReveal,
          physics: NeverScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.only(top: topPadding(context)),
            height: maxHeight(context),
            width: double.infinity,
            child: _getHeader(),
          ),
        ),
      ),
    );
  }
}
