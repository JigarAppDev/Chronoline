import 'dart:convert';

import 'package:chronoline/Componets/CustomWidget.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'LoginScreen.dart';

class ResetPasswordScreen extends StatefulWidget {
  var emailr;

  ResetPasswordScreen({this.emailr});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _loading = false;
  var jsonData;
  TextEditingController otp = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController rePassword = TextEditingController();
  Dio dio = Dio();

  void reset() async {
    setState(() {
      _loading = true;
    });
    try {
      var response = await dio.post(
        RESET,
        data: {
          'email': widget.emailr,
          'temp_pass': otp.text,
          'new_pass': newPassword.text,
        },
      );

      if (response.statusCode == 200) {

        setState(() {
          _loading = false;
          jsonData = jsonDecode(response.toString());
        });
        if (jsonData['status'] == 1) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LogInScreen()));
          Toasty.showtoast(jsonData['message']);
        }
        if (jsonData['status'] == 0) {
          Toasty.showtoast(jsonData['message']);
        }
      } else {
        return null;
      }
    } catch (e) {

    }
  }

  void resend() async {
    setState(() {
      _loading = true;
    });
    try {
      var response = await dio.post(
        FORGOT,
        data: {
          'email': widget.emailr,
        },
      );

      if (response.statusCode == 200) {

        setState(() {
          _loading = false;
          jsonData = jsonDecode(response.toString());
        });
        if (jsonData['status'] == 1) {
          Toasty.showtoast(jsonData['message']);
        }
        if (jsonData['status'] == 0) {
          Toasty.showtoast(jsonData['message']);
        }
      } else {
        return null;
      }
    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height * .1),
              Container(
                height: height,
                decoration: BoxDecoration(color: Color(0xffF5F7F9), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.close_rounded,
                              size: 30,
                              color: kBlackColor,
                            ),
                          ),
                        ),
                        Image.asset('assets/icons/Group 63085.png', height: height * 0.25),
                        SizedBox(height: height * 0.04),
                        AppText1('Reset Password', color: kBlackColor, fontSize: 30),
                        AppText('Enter The Verification Code And\nLogin Your Account', textAlign: TextAlign.center, color: kBlackColor),
                        SizedBox(height: height * 0.01),
                        CustomTextField(
                            controller: otp,
                            preftext: GestureDetector(
                                onTap: () {
                                  resend();
                                },
                                child: AppText('Resend OTP')),
                            labelColor: Colors.black,
                            input: TextInputType.number,
                            label: 'Enter Your OTP',
                            hintText: "Enter Your OTP"),
                        SizedBox(height: height * 0.01),
                        CustomTextField(inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ], controller: newPassword, suffixVisibility: true, obscureText: true, labelColor: Colors.black, label: 'Password', hintText: "Enter Password"),
                        SizedBox(height: height * 0.01),
                        CustomTextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            ],
                            controller: rePassword,
                            suffixVisibility: true,
                            obscureText: true,
                            labelColor: Colors.black,
                            label: 'Confirm New Password',
                            hintText: "Enter Confirm New Password"),
                        SizedBox(height: height * 0.05),
                        CustomButton(
                          title: 'Submit',
                          onPressed: () {
                            if (validate(otp: otp.text, newPass: newPassword.text, confPass: rePassword.text)) reset();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool validate({required String otp, required String newPass, required String confPass}) {
    if (otp.isEmpty && newPass.isEmpty && confPass.isEmpty) {
      Toasty.showtoast('Please Enter Your Credentials');
      return false;
    } else if (otp.isEmpty) {
      Toasty.showtoast('Please Enter Your OTP');
      return false;
    } else if (otp == '112233') {
      Toasty.showtoast('Wrong OTP');
      return false;
    } else if (otp.length < 6) {
      Toasty.showtoast('OTP Must Contains 6 Digits');
      return false;
    } else if (newPass.isEmpty) {
      Toasty.showtoast('Please Enter Password');
      return false;
    } else if (confPass.isEmpty) {
      Toasty.showtoast('Please Enter Confirm Password');
      return false;
    } else if (newPass.length < 8) {
      Toasty.showtoast('Password Must Contains 8 Characters');
      return false;
    } else if (newPass != confPass) {
      Toasty.showtoast('Password Must Be Same');
      return false;
    } else {
      return true;
    }
  }
}
