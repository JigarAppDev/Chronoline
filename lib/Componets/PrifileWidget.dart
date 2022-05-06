import 'package:flutter/material.dart';

class DetailsWidget extends StatelessWidget {
  final String text;
  var onTap;

  DetailsWidget({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        margin: EdgeInsets.symmetric(vertical: 10),
        height: height * 0.055,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1)],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right,
              size: height * 0.03,
            )
          ],
        ),
      ),
    );
  }
}
