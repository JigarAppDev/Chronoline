import 'dart:convert';
import 'dart:io';

import 'package:chronoline/Componets/SociealWidget.dart';
import 'package:chronoline/Screen/MainScreen.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:chronoline/Utils/GoogleSignIn.dart';
import 'package:chronoline/Utils/appleSignIn.dart';
import 'package:chronoline/componets/CustomWidget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'LoginScreen.dart';
import 'RegisterScreen.dart';

class LogInWithSocialScreen extends StatefulWidget {
  const LogInWithSocialScreen({Key? key}) : super(key: key);

  @override
  _LogInWithSocialScreenState createState() => _LogInWithSocialScreenState();
}

class _LogInWithSocialScreenState extends State<LogInWithSocialScreen> {
  var jsonData, deviceId, deviceToken, longitude, lattitude, userData;
  int? deviceType;
  bool _loading = false;
  Dio dio = Dio();
  void loginByThirdParty({
    String? userName,
    String? Email,
    String? thirdPartyID,
    String? profilePic,
    String? loginType,
  }) async {
    Login login = Login();
    await login.getDeviceId();
    await login.getDeviceToken();
    setState(() {
      deviceToken = login.device_token;
      deviceId = login.device_id;
      deviceType = login.device_type;
    });
    setState(() {
      _loading = true;
    });
    Dio dio = Dio();
    try {
      var response = await dio.post(
        LOGIN_BY_THIRDPARTY,
        data: {
          'email': Email,
          'user_name': userName,
          'thirdparty_id': thirdPartyID,
          'login_type': loginType,
          'device_type': Platform.isIOS ? 2 : 1,
          'device_token': deviceToken,
          'device_id': deviceId,
          'lattitude': 0.00,
          'longitude': 0.00,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
          jsonData = jsonDecode(response.toString());
        });
        if (jsonData['status'] == 1) {
          setUserData();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return MainScreen();
              },
            ),
          );
          Toasty.showtoast(jsonData['message']);
        } else {
          Toasty.showtoast(jsonData['message']);
        }
      } else {
        Toasty.showtoast('Something Went Wrong');
      }
    } on DioError catch (e) {}
  }

  setUserData() async {
    await setPrefData(key: 'email', value: jsonData['data']['email']);
    await setPrefData(key: "GoPrimeMember", value: '${jsonData['data']["is_business_profile"]}');
    await setPrefData(key: 'user_token', value: jsonData['data']['user_token']);
    await setPrefData(key: 'id', value: jsonData['data']['user_id'].toString());
    await setPrefData(key: 'device_id', value: jsonData['data']['device_id']);
  }

  @override
  void initState() {
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (mounted) {
        setState(() => _source = source);
      }
    });
  }

  var string;
  Map _source = {ConnectivityResult.none: false};
  final MyConnectivity _connectivity = MyConnectivity.instance;

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
        child: Column(
          children: [
            SizedBox(
              height: height * 0.06,
            ),
            Center(
              child: Image.asset(
                'assets/icons/logo.png',
                height: height * 0.2,
                width: width * 0.5,
              ),
            ),
            SizedBox(height: height * 0.04),
            AppText1('Login With\nSocial Media', color: Colors.white, textAlign: TextAlign.center, fontSize: 32),
            SizedBox(height: height * 0.08),
            SocialButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterScreen(),
                    ),
                  );
                },
                imagePath: 'assets/icons/businessman.png',
                socialText: 'Sign up using Email'),
            SocialButton(
              imagePath: 'assets/icons/facebook.png',
              socialText: 'Connect with Facebook',
              onTap: () {
                socialFBLogin();
              },
            ),
            SocialButton(
              imagePath: 'assets/icons/google.png',
              socialText: 'Connect with Google',
              onTap: () async {
                string == 3
                    ? Toasty.showtoast('Please Check Your Internet')
                    : await signInWithGoogle().then(
                        (result) {
                          if (result != null) {
                            loginByThirdParty(
                              userName: gName,
                              Email: gEmail,
                              thirdPartyID: googleAuth,
                              loginType: '2',
                            );
                          }
                        },
                      );
              },
            ),
            Platform.isAndroid
                ? Container()
                : SocialButton(
                    imagePath: 'assets/icons/apple-logo.png',
                    socialText: 'Connect with Apple',
                    onTap: () {
                      appleSignIn().then((credential) => {
                            loginByThirdParty(
                                loginType: '3',
                                thirdPartyID: credential.userIdentifier,
                                profilePic: 'profilePic',
                                Email: credential.email == null ? credential.userIdentifier.substring(0, 8) + '@gmail.com' : credential.email,
                                userName: credential.givenName == null ? 'user@' + credential.userIdentifier.substring(0, 4) : credential.givenName),
                          });
                    },
                  ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText("Already have an account? ", color: Colors.white),
                InkWell(
                  onTap: () {
                    Navigator.push(
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
            SizedBox(height: height * 0.03),
          ],
        ),
      ),
    );
  }

  var userToken;
  var response;

  Future<void> socialFBLogin() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      userData = await FacebookAuth.instance.getUserData();

      var fgName = userData['name'];
      var fgEmail = userData['email'];
      var thirdPartyID = userData['id'];
      var profilePhotoUrl = userData['picture']['data']['url'];

      if (thirdPartyID != null || thirdPartyID != '') {
        loginByThirdParty(userName: fgName, Email: fgEmail, thirdPartyID: thirdPartyID, loginType: '1', profilePic: profilePhotoUrl);
      }
    } else {}
  }
}
