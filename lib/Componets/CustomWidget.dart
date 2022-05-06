import 'package:chronoline/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppText extends StatelessWidget {
  final String text, fontFamily;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final double? letterSpacing;
  final double? height;
  final TextDecoration textDecoration;
  final TextAlign textAlign;
  final int maxLines;
  final FontStyle fontStyle;

  AppText(
    this.text, {
    this.fontSize = 14,
    this.color = kPrimaryColor,
    this.fontWeight = FontWeight.w500,
    this.fontFamily = 'Regular',
    this.letterSpacing,
    this.textDecoration = TextDecoration.none,
    this.textAlign = TextAlign.start,
    this.height = 1.4,
    this.maxLines = 100,
    this.fontStyle = FontStyle.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        height: height,
        color: color,
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        decoration: textDecoration,
      ),
    );
  }
}

class AppText1 extends StatelessWidget {
  final String text, fontFamily;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final double? letterSpacing;
  final double? height;
  final TextDecoration textDecoration;
  final TextAlign textAlign;
  final int maxLines;
  final FontStyle fontStyle;

  AppText1(
    this.text, {
    this.fontSize = 14,
    this.color = kPrimaryColor,
    this.fontWeight = FontWeight.w300,
    this.fontFamily = 'Sbold',
    this.letterSpacing,
    this.textDecoration = TextDecoration.none,
    this.textAlign = TextAlign.start,
    this.height = 1.4,
    this.maxLines = 100,
    this.fontStyle = FontStyle.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        height: height,
        color: color,
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        decoration: textDecoration,
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  CustomTextField({
    this.controller,
    this.input,
    this.label = '',
    this.right_lable = '',
    this.maxLines,
    this.fieldHeight = 50,
    this.focusNode,
    this.hintText,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.initialValue,
    this.readOnly = false,
    this.suffix,
    this.prefixIcon = '',
    this.suffixVisibility = false,
    this.obscureText = false,
    this.img_suffix = '',
    this.enable = true,
    this.preftext,
    this.minLine,
    this.labelColor,
    this.onpressed,
    this.maxnumber,
  });

  final TextEditingController? controller;
  final TextInputType? input;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? label;
  final String? right_lable;
  final String? prefixIcon;
  final Color? labelColor;
  final int? maxLines;
  final double fieldHeight;
  final FocusNode? focusNode;
  final String? hintText;
  final Function()? onTap;
  final Function()? onpressed;
  final String? initialValue;
  final bool readOnly;
  final Widget? suffix;
  final String? img_suffix;
  final Widget? preftext;
  final int? minLine;
  final int? maxnumber;
  bool suffixVisibility;
  bool obscureText;
  bool enable;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  toggle() {
    setState(() {
      widget.obscureText = !widget.obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(widget.label!,
                color: widget.labelColor!,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                fontFamily: 'Regular'),
            AppText(widget.right_lable!,
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                fontFamily: 'Regular'),
          ],
        ),
        SizedBox(height: 5.0),
        Container(
          height: widget.fieldHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(color: Colors.grey, blurRadius: 1),
            ],
          ),
          child: TextField(
            maxLength: widget.maxnumber,
            minLines: widget.minLine,
            obscureText: widget.obscureText,
            obscuringCharacter: '*',
            readOnly: widget.readOnly,
            cursorColor: Color(0xffAFAFAF),
            focusNode: widget.focusNode,
            //maxLines: widget.maxLines,
            controller: widget.controller,
            keyboardType: widget.input,
            onChanged: widget.onChanged,
            enabled: widget.enable,
            onTap: widget.onTap,
            inputFormatters: widget.inputFormatters,
            style: TextStyle(
                color: Colors.black,
                fontFamily: 'Regular',
                fontSize: 16,
                decoration: TextDecoration.none),
            decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                suffix: widget.suffixVisibility == true
                    ? GestureDetector(
                        child: widget.obscureText
                            ? Image.asset("assets/icons/Hide.png", scale: 4.8)
                            : Image.asset("assets/icons/Show.png", scale: 6),
                        onTap: toggle)
                    : widget.preftext,
                filled: true,
                fillColor: Colors.white,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                    color: Colors.grey, fontFamily: 'Regular', fontSize: 16),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                focusedBorder: kOutlineInputBorder,
                enabledBorder: kOutlineInputBorder,
                disabledBorder: kOutlineInputBorder,
                errorBorder: kOutlineInputBorder,
                focusedErrorBorder: kOutlineInputBorder),
          ),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String title;
  final String icon;
  final double height;

  final onPressed;

  const CustomButton({
    this.title = '',
    this.onPressed,
    this.icon = '',
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size(250, height),
        backgroundColor: Color(0xffA2ABDB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: onPressed,
      child: icon == ''
          ? AppText(title,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              fontFamily: 'Sbold',
              color: Color(0xff000059))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('$ICON_URL/$icon', height: 26, width: 26),
                  AppText(title,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      fontFamily: 'Sbold',
                      color: Color(0xff000059)),
                  SizedBox(width: 20),
                ],
              ),
            ),
    );
  }
}
