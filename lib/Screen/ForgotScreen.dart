import 'dart:convert';

import 'package:chronoline/Componets/CustomWidget.dart';
import 'package:chronoline/Screen/ResetPasswordScreen.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({Key? key}) : super(key: key);

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  bool _loading = false;
  var jsonData;

  TextEditingController email = TextEditingController();
  Dio dio = Dio();

  void forgot() async {
    setState(() {
      _loading = true;
    });
    try {
      var response = await dio.post(
        FORGOT,
        data: {
          'email': email.text,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
          jsonData = jsonDecode(response.toString());
        });
        if (jsonData['status'] == 1) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ResetPasswordScreen(emailr: email.text)));
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

  var string;
  Map _source = {ConnectivityResult.none: false};
  final MyConnectivity _connectivity = MyConnectivity.instance;

  @override
  void initState() {
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (mounted) {
        setState(() => _source = source);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_source.keys.toList()[0]) {
      case ConnectivityResult.mobile:
        string = 1;
        break;
      case ConnectivityResult.wifi:
        string = 2;
        break;
      case ConnectivityResult.none:
        string = 3;
        break;
      default:
        string = 4;
    }
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
                width: width,
                decoration: BoxDecoration(color: Color(0xffF5F7F9), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.close_rounded, size: 30, color: kBlackColor),
                          ),
                        ),
                        Image.asset('assets/icons/Group 63084.png', height: height * 0.25),
                        SizedBox(height: height * 0.04),
                        AppText1('Forgot Password?', color: kBlackColor, fontSize: 30),
                        AppText('Enter The Email Address Associated\nWith Your Account', textAlign: TextAlign.center, color: kBlackColor),
                        SizedBox(height: height * 0.05),
                        CustomTextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          controller: email,
                          labelColor: Colors.black,
                          label: 'Email',
                          hintText: "Enter Email",
                          input: TextInputType.emailAddress,
                        ),
                        SizedBox(height: height * 0.1),
                        CustomButton(
                          title: 'Send',
                          onPressed: () {
                            if (validate(email: email.text)) {
                              forgot();
                            }
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

  bool validate({required String email}) {
    if (string == 3) {
      Toasty.showtoast('Please Check Your Internet');
      return false;
    } else if (email.isEmpty) {
      Toasty.showtoast('Please Enter Your Register Email');
      return false;
    } else {
      return true;
    }
  }
}
