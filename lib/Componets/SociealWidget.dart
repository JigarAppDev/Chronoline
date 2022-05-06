import 'package:chronoline/Utils/Constant.dart';
import 'package:chronoline/componets/CustomWidget.dart';
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String imagePath;
  final String socialText;
  var onTap;

  SocialButton({required this.imagePath, required this.socialText, this.onTap});
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.only(left: 20, right: 70),
        height: height * 0.062,
        width: width * 0.8,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey)),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: height * 0.035,
            ),
            Spacer(),
            AppText1(
              socialText,
              color: kBlackColor,
            )
          ],
        ),
      ),
    );
  }
}
