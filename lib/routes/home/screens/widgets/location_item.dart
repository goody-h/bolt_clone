import 'package:bolt_clone/utils.dart';
import 'package:flutter/material.dart';

class LocationItem extends StatelessWidget {
  LocationItem({this.icon, this.title, this.subTitle, this.onClick});
  final IconData icon;
  final String title;
  final String subTitle;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[Text(title)];
    if (subTitle != null) {
      content
          .add(Text(subTitle, style: TextStyle(color: AppColors.textGreySub)));
    }
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: FlatButton(
        onPressed: onClick,
        padding: EdgeInsets.only(right: 20, left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                icon,
                color: AppColors.iconGrey,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: content,
            )
          ],
        ),
      ),
    );
  }
}
