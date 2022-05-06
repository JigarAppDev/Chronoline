
import 'package:flutter/material.dart';

import 'CustomWidget.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final String image;
  final Color color;
  final Color color1;
  var visible;
  bool required = true;
  CustomAppbar({required this.text, this.visible, required this.color, required this.color1, this.image = ''});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 0,
        leading: Visibility(
            visible: visible,
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset("assets/icons/Fill 4.png", scale: 7, color: color1))),

        centerTitle: true,
        title: AppText1(text, fontSize: 22, color: Colors.white),
        backgroundColor: Colors.transparent);
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}
