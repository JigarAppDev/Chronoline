import 'dart:convert';

import 'package:chronoline/Componets/CustomAppbar.dart';
import 'package:chronoline/Screen/MainScreen.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:chronoline/componets/CustomWidget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _loading = false;
  var jsonData;
  TextEditingController currrentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPass = TextEditingController();
  Dio dio = Dio();
  var userToken;

  Future getData() async {
    var user_token = await getPrefData(key: 'user_token');
    setState(() {
      userToken = user_token;
    });
  }

  void changePass() async {
    setState(() {
      _loading = true;
    });
    try {
      var response = await dio.post(
        CHANGE_PASSWORD,
        data: {
          'current_password': currrentPassword.text,
          'new_password': newPassword.text,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $userToken',
          },
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
          jsonData = jsonDecode(response.toString());
        });
        if (jsonData['status'] == 1) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));
          Toasty.showtoast(jsonData['message']);
        }
        if (jsonData['status'] == 0) {
          Toasty.showtoast(jsonData['message']);
        }
      } else {
        return null;
      }
    } catch (e) {}
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: CustomAppbar(
        text: 'Change Password',
        visible: true,
        color: Colors.white,
        color1: Colors.white,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Container(
          padding: EdgeInsets.fromLTRB(18, 30, 18, 0),
          height: height,
          width: width,
          decoration: BoxDecoration(color: Color(0xffF5F7F9), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: [
                  Image.asset(
                    'assets/icons/Group 63085.png',
                    height: height * 0.25,
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  CustomTextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    controller: currrentPassword,
                    labelColor: Colors.black,
                    label: 'Current Password',
                    hintText: "Enter Current Password",
                    suffixVisibility: true,
                    obscureText: true,
                  ),
                  SizedBox(
                    height: height * 0.015,
                  ),
                  CustomTextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    controller: newPassword,
                    suffixVisibility: true,
                    obscureText: true,
                    labelColor: Colors.black,
                    label: 'New Password',
                    hintText: "Enter New Password",
                  ),
                  SizedBox(
                    height: height * 0.015,
                  ),
                  CustomTextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    controller: confirmPass,
                    suffixVisibility: true,
                    obscureText: true,
                    labelColor: Colors.black,
                    label: 'Confirm New Password',
                    hintText: "Enter Confirm New Password",
                  ),
                  SizedBox(
                    height: height * 0.15,
                  ),
                  CustomButton(
                    title: 'Submit',
                    onPressed: () {
                      if (_validate(currentPass: currrentPassword.text, newPass: newPassword.text, confPass: confirmPass.text)) {
                        changePass();
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validate({required String currentPass, required String newPass, required String confPass}) {
    if (currentPass.isEmpty && newPass.isEmpty && confPass.isEmpty) {
      Toasty.showtoast('Please Enter Your Credentials');
      return false;
    } else if (currentPass.isEmpty) {
      Toasty.showtoast('Please Enter Your Current Password');
      return false;
    } else if (newPass.isEmpty) {
      Toasty.showtoast('Please Enter New Password');
      return false;
    } else if (confPass.isEmpty) {
      Toasty.showtoast('Please Re-Enter Your Password');
      return false;
    } else if (newPass.length < 8) {
      Toasty.showtoast('Password Must Contains 8 Characters');
      return false;
    } else if (newPass != confPass) {
      Toasty.showtoast('Password Must Be Same');
      return false;
    } else if (currentPass == confPass) {
      Toasty.showtoast('Same Password Try To Another');
      return false;
    } else {
      return true;
    }
  }
}
