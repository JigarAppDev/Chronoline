import 'dart:async';

import 'package:chronoline/Screen/LoginScreen.dart';
import 'package:chronoline/Screen/MainScreen.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late var userToken;
  @override
  void initState() {
    startTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Center(
          child: Image.asset(
            'assets/icons/ChronoLine App logo – 1.png',
            height: height * 0.3,
            width: width * 0.3,
          ),
        ),
      ),
    );
  }

  Future startTime() async {
    await getData();
    var duration = new Duration(seconds: 3);
    return new Timer(duration, route);
  }

  route() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => userToken == null || userToken == 'null' || userToken == '' ? LogInScreen() : MainScreen(),
      ),
    );
  }

  Future getData() async {
    var user_token = await getPrefData(key: 'user_token');

    setState(() {
      userToken = user_token;

    });
  }
}
