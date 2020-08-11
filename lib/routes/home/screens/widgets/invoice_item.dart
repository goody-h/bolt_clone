import 'package:bolt_clone/utils.dart';
import 'package:flutter/material.dart';

class InvoiceItem extends StatelessWidget {
  InvoiceItem(
      {this.icon, this.title, this.subTitle, this.isSelected, this.onClick});

  final IconData icon;
  final String title;
  final String subTitle;
  final bool isSelected;
  final VoidCallback onClick;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 82,
      child: FlatButton(
        color: isSelected ? AppColors.greenLight : AppColors.white,
        highlightColor: AppColors.greenHighlight,
        onPressed: onClick,
        padding: EdgeInsets.only(right: 20, left: 20, bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                icon,
                color: AppColors.iconGrey,
                size: 28,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(title),
                  Text(
                    subTitle,
                    style: TextStyle(color: AppColors.textGreySub),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("N 300"),
                Text(
                  "N 500",
                  style: TextStyle(
                      color: AppColors.textGreySub,
                      decoration: TextDecoration.lineThrough),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
