import 'dart:convert';

import 'package:chronoline/Screen/MainScreen.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:chronoline/Utils/IntialData.dart';
import 'package:chronoline/componets/CustomWidget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController user = TextEditingController();

  bool _loading = false;
  var jsonData;
  var deviceToken;
  var deviceType;
  var deviceID;
  Dio dio = Dio();

  loginUser() async {
    InitialData rahul = InitialData();
    await rahul.getDeviceToken();
    await rahul.getDeviceTypeId();
    setState(() {
      _loading = true;
      deviceToken = rahul.deviceToken;
      deviceID = rahul.deviceID;
      deviceType = rahul.deviceType;

    });
    try {
      var response = await dio.post(
        REGISTER,
        data: {
          'user_name': user.text,
          'email': email.text,
          'password': password.text,
          'device_id': deviceID ?? '',
          'device_token': deviceToken ?? '',
          'device_type': deviceType ?? '',
          'login_type': 2,
          'lattitude': '0.00',
          'longitude': '0.00',
          'thirdparty_id': '',
        },
      );

      if (response.statusCode == 200) {

        setState(() {
          jsonData = jsonDecode(response.toString());
        });
        if (jsonData['status'] == 1) {
          await setUserData();
          setState(() {
            _loading = false;
          });
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));
          Toasty.showtoast(jsonData['message']);
        }
        if (jsonData['status'] == 0) {
          setState(() {
            _loading = false;
          });
          Toasty.showtoast(jsonData['message']);
        }
      } else {
        return null;
      }
    } catch (e) {

    }
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

  setUserData() async {
    await setPrefData(key: 'user_name', value: jsonData['data']['user_name']);
    await setPrefData(key: 'email', value: jsonData['data']['email']);
    await setPrefData(key: 'user_token', value: jsonData['data']['user_token']);
    await setPrefData(key: "GoPrimeMember", value: '${jsonData['data']["is_business_profile"]}');
    await setPrefData(key: 'id', value: jsonData['data']['user_id'].toString());
    await setPrefData(key: 'device_id', value: jsonData['data']['device_id']);
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height * 0.06),
              Center(
                  child: Image.asset(
                'assets/icons/logo.png',
                height: height * 0.2,
                width: width * 0.5,
              )),
              SizedBox(height: height * 0.03),
              AppText1("Let's Get\nStarted", color: Colors.white, textAlign: TextAlign.center, fontSize: 35),
              AppText('Create A New Account', color: Colors.white, letterSpacing: 1),
              CustomTextField(
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  FilteringTextInputFormatter.deny(RegExp("[A-Z]")),
                ],
                controller: user,
                labelColor: Colors.white,
                label: 'Username',
                hintText: "Enter Username",
              ),
              SizedBox(height: height * 0.01),

              CustomTextField(
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                controller: email,
                labelColor: Colors.white,
                label: 'Email',
                hintText: "Enter Email",
                input: TextInputType.emailAddress,
              ),
              SizedBox(height: height * 0.01),
              CustomTextField(inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ], controller: password, labelColor: Colors.white, label: 'Password', hintText: "Enter Password", suffixVisibility: true),
              SizedBox(height: height * 0.07),

              CustomButton(
                  onPressed: () async {

                    if (validate(
                      userName: user.text,
                      email: email.text,
                      password: password.text,
                    )) await loginUser();
                  },
                  title: 'Register'),
              SizedBox(height: height * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText("Already have an account? ", color: Colors.white),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogInScreen(),
                        ),
                      );
                    },
                    child: AppText1('Sign In', textDecoration: TextDecoration.underline, color: Colors.white),
                  )
                ],
              ),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  bool validate({
    required String userName,
    required String email,
    required String password,
  }) {
    if (string == 3) {
      Toasty.showtoast('Please Check Your Internet');
      return false;
    } else if (userName.isEmpty && email.isEmpty && password.isEmpty) {
      Toasty.showtoast('Please Enter Your Credentials');
      return false;
    } else if (userName.isEmpty) {
      Toasty.showtoast('Please Enter Your Username');
      return false;
    } else if (email.isEmpty) {
      Toasty.showtoast('Please Enter Your Email Address');
      return false;
    } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      Toasty.showtoast('Please Enter Valid Email Address');
      return false;
    } else if (password.isEmpty) {
      Toasty.showtoast('Please Enter Your Password');
      return false;
    } else if (password.length < 8) {
      Toasty.showtoast('Password Must Contains 8 Characters');
      return false;
    } else {
      return true;
    }
  }
}
