import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class AddImageBox extends StatelessWidget {
  var onTap;
  var child;
  double? height;
  double? width;

  AddImageBox({this.onTap, this.child, this.width, this.height});

  @override
  Widget build(BuildContext context) {

    return DottedBorder(
      dashPattern: [7],
      borderType: BorderType.RRect,
      radius: Radius.circular(12),
      strokeWidth: 1,
      color: Colors.grey,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        height: height,
        width: width,
        child: child,
      ),
    );
  }
}
