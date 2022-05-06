import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String IMG_URL = 'assets/images';
const String ICON_URL = 'assets/icons';
const Color kPrimaryColor = Color(0xff303473);
const Color kBlackColor = Colors.black;

final kOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide(color: Colors.white60, width: 1.0),
);

class Toasty {
  static showtoast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, textColor: Colors.white, backgroundColor: Colors.black.withOpacity(0.5));
  }
}

var deviceType;
var deviceID;

Future<void> getDeviceTypeId() async {
  var deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    deviceType = 1;
    var androidDeviceInfo = await deviceInfo.androidInfo;
    deviceID = androidDeviceInfo.androidId;
    print('Device Type: ${deviceType.toString()}, ' + 'Device ID: $deviceID');
  } else {
    deviceType = 2;
    var iosDeviceInfo = await deviceInfo.iosInfo;
    deviceID = iosDeviceInfo.identifierForVendor;
    print('Device Type: ${deviceType.toString()}, ' + 'Device ID: $deviceID');
  }
}

Future setPrefData({required String key, required String value}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

Future getPrefData({required String key}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = prefs.getString(key);
  return data;
}

Future setBoolPrefData({required String key, required bool value}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(key, value);
}

Future clearPrefData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

class Login {
  var device_token;
  var device_type;
  var device_id;
  var latitude;
  var logitude;


  getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      device_type = 2;
      var iosDeviceInfo = await deviceInfo.iosInfo;
      device_id = iosDeviceInfo.identifierForVendor;
      print('Device ID: ' + device_id);
    } else {
      device_type = 1;
      var androidDeviceInfo = await deviceInfo.androidInfo;
      device_id = androidDeviceInfo.androidId;
      print('Device ID: ' + device_id);
    }
  }

  getDeviceToken() {
    var random = Random();
    var values = List<int>.generate(200, (i) => random.nextInt(255));
    device_token = base64UrlEncode(values);
    print('Device Token: ' + device_token);
  }
}

const BASE_URL = '';
const imageUrl = '';

const loginapi = '$BASE_URL/login';
const FORGOT = '$BASE_URL/forgot_password';
const RESET = '$BASE_URL/reset_password';
const REGISTER = '$BASE_URL/register';
const CHANGE_PASSWORD = '$BASE_URL/change_password';
const LOGOUT = '$BASE_URL/logout';
const EDIT_PROFILE = '$BASE_URL/edit_profile';
const GET_MY_CHRONOLINE = '$BASE_URL/get_my_chronoline';
const ADD_CHRONOLINE = '$BASE_URL/add_chronoline';
const DELETE_CHRONOLINE = '$BASE_URL/delete_chronoline';
const EDIT_CHRONOLINE = '$BASE_URL/edit_chronoline';
const ADD_CHRONOLINE_TASK = '$BASE_URL/add_chronoline_task';
const GET_CHRONOLINE_DETAILS = '$BASE_URL/get_chronoline_details';
const DELETE_CHRONOLINE_TASK = '$BASE_URL/delete_chronoline_task';
const EDIT_CHRONOLINE_TASK = '$BASE_URL/edit_chronoline_task';
const LOGIN_BY_THIRDPARTY = '$BASE_URL/login_by_thirdparty';
const ADD_RECIEPT = '$BASE_URL/add_reciept';


class MyConnectivity {
  MyConnectivity._();

  static final _instance = MyConnectivity._();
  static MyConnectivity get instance => _instance;
  final _connectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;

  void initialise() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _checkStatus(result);
    _connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();
}
