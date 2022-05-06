import 'dart:convert';

import 'package:chronoline/Screen/ForgotScreen.dart';
import 'package:chronoline/Screen/MainScreen.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:chronoline/Utils/IntialData.dart';
import 'package:chronoline/componets/CustomWidget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'LoginWithSocial.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  late String deviceToken;
  late int deviceType;
  var deviceID;
  var jsonData;
  var jsonnData;
  Dio dio = Dio();
  bool _loading = false;

  void login() async {
    InitialData initialData = InitialData();
    await initialData.getDeviceToken();
    await initialData.getDeviceTypeId();
    setState(() {
      _loading = true;
      deviceToken = initialData.deviceToken;
      deviceID = initialData.deviceID;
      deviceType = initialData.deviceType;
    });

    try {
      var response = await dio.post(
        loginapi,
        data: {
          'email': email.text,
          'password': password.text,
          'longitude': '0.00',
          'lattitude': '0.00',
          'device_token': deviceToken,
          'device_id': deviceID ?? '',
          'device_type': deviceType,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
          jsonData = jsonDecode(response.data);
        });
        if (jsonData['status'] == 1) {
          await setUserData();
          var go = jsonData['data']["is_business_profile"];
          Toasty.showtoast(jsonData['message']);
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));
        } else if (jsonData['status'] == 0) {
          Toasty.showtoast(jsonData['message']);
        }
      } else {
        return null;
      }
    } on DioError catch (e) {}
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
    await setPrefData(key: "GoPrimeMember", value: '${jsonData['data']["is_business_profile"]}');
    await setPrefData(key: 'user_token', value: jsonData['data']['user_token']);
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
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: height * 0.04,
                  ),
                  Center(
                      child: Image.asset(
                    'assets/icons/logo.png',
                    height: height * 0.2,
                    width: width * 0.5,
                  )),
                  AppText1(
                    'Welcome\nBack!',
                    color: Colors.white,
                    textAlign: TextAlign.center,
                    fontSize: 35,
                  ),
                  AppText(
                    'Log In To Continue',
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  SizedBox(
                    height: height * 0.045,
                  ),
                  CustomTextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp("[A-Z]")),
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    controller: email,
                    labelColor: Colors.white,
                    label: 'Username, Email or Phone',
                    hintText: "Enter Username, Email or Phone",
                    input: TextInputType.emailAddress,
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  CustomTextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    controller: password,
                    label: 'Password',
                    hintText: "Enter Password",
                    labelColor: Colors.white,
                    obscureText: true,
                    suffixVisibility: true,
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotScreen()));
                    },
                    child: Align(alignment: Alignment.centerRight, child: AppText('Forgot Password?', color: Colors.white, fontSize: 13)),
                  ),
                  SizedBox(height: height * 0.05),
                  CustomButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (validate(email: email.text, password: password.text)) {
                          login();
                        }
                      },
                      title: 'Sign In'),
                  SizedBox(height: height * 0.065),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        "Don't have an account? ",
                        color: Colors.white,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LogInWithSocialScreen(),
                            ),
                          );
                        },
                        child: AppText1(
                          'Register',
                          textDecoration: TextDecoration.underline,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool validate({required String email, required String password}) {
    if (string == 3) {
      Toasty.showtoast('Please Check Your Internet');
      return false;
    } else if (email.isEmpty && password.isEmpty) {
      Toasty.showtoast('Please Enter Your Credentials');
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
