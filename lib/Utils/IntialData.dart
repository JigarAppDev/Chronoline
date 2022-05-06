import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';

class InitialData {
  late String deviceToken;
  late int deviceType;
  var deviceID;

  Future<void> getDeviceTypeId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      deviceType = 1;
      var androidDeviceInfo = await deviceInfo.androidInfo;
      deviceID = androidDeviceInfo.androidId;

    } else {
      deviceType = 2;
      var iosDeviceInfo = await deviceInfo.iosInfo;
      deviceID = iosDeviceInfo.identifierForVendor;

    }
  }

  getDeviceToken() {
    var random = Random();
    var values = List<int>.generate(200, (i) => random.nextInt(255));
    deviceToken = base64UrlEncode(values);

  }

}

