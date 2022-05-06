import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chronoline/Componets/CustomWidget.dart';
import 'package:chronoline/Componets/PrifileWidget.dart';
import 'package:chronoline/Screen/ChangePasswordScreen.dart';
import 'package:chronoline/Screen/GoPremiumScreen.dart';
import 'package:chronoline/Screen/GopremiumAndroid.dart';
import 'package:chronoline/Screen/LoginScreen.dart';
import 'package:chronoline/Screen/MyInformationScreen.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:chronoline/Utils/GoogleSignIn.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _url = 'https://app.termly.io/document/privacy-policy/d7a69357-3795-4ad4-a64d-cb9ca0d3e35c';
  String url = 'https://app.termly.io/document/terms-of-use-for-ios-app/faa43f21-b456-4033-8c43-48d377d50357';

  bool _loading = false;
  late Response response;
  Dio dio = Dio();
  var jsonData;
  var profileData, deviceId;
  var userToken;
  var GoPrimeFlag;
  bool isLoad = false;
  var user_name;
  var email;
  var profile_pic;

  void logoutApi() async {
    await getUserData();
    await getDeviceTypeId();
    try {
      response = await dio.post(
        LOGOUT,
        data: {'device_id': deviceID},
        options: Options(
          headers: {'Authorization': 'Bearer $userToken'},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
        });
        jsonData = jsonDecode(response.toString());
        if (jsonData['status'] == 1) {

          signOutGoogle();
          signOut();
          await clearPrefData();
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LogInScreen()), (route) => false);
          Toasty.showtoast(
            jsonData['message'],
          );
        }
      } else {
        Toasty.showtoast('Something Went Wrong');
      }
    } catch (e) {

    }
  }

  signOut() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      await FirebaseAuth.instance.signOut();
      await _auth.signOut();
    } catch (e) {
      Toasty.showtoast("Error signing out. Try again.");
    }
  }

  Future getUserData() async {
    var user_token = await getPrefData(key: 'user_token');
    var device_id = await getPrefData(key: 'device_id');
    setState(() {
      userToken = user_token;
      var deviceID = device_id;

    });
  }

  editProFile() async {

    Dio dio = Dio();
    try {
      final response = await dio.post(
        EDIT_PROFILE,
        options: Options(
          headers: {'Authorization': 'Bearer $userToken'},
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.toString());
        });
        if (jsonData['status'] == 1) {
          setState(() {
            isLoad = true;
            profileData = jsonData['data'];
            user_name = profileData['user_name'];
            email = profileData['email'];
            profile_pic = profileData['profile_pic'];
            GoPrimeFlag = profileData['is_business_profile'];
          });


          await SetData();
          await getData();
        }
        if (jsonData['status'] == 0) {
          Toasty.showtoast(jsonData['message']);
        }
      } else {
        return null;
      }
    } on DioError catch (e) {

    }
  }

  get() async {
    await getData();
    await editProFile();
  }

  var username;
  var emaill;

  Future getUesrName() async {
    var user_name = await getPrefData(key: 'user_name');
    var email = await getPrefData(key: 'email');
    setState(() {
      username = user_name;
      emaill = email;
    });
  }

  SetData() async {

    await setPrefData(key: "GoPrimeMember", value: "${profileData['is_business_profile']}");
  }

  var Go;
  Future getData() async {
    var device_id = await getPrefData(key: 'device_id');
    var user_token = await getPrefData(key: 'user_token');
    var go = await getPrefData(key: 'GoPrimeMember');

    setState(() {
      Go = go;
      deviceId = device_id;
      userToken = user_token;

    });
  }

  FutureOr onGoBack(dynamic value) {
    editProFile();
    setState(() {});
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
    getUesrName();
    get();
    super.initState();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText1("Profile", fontSize: 22, color: Colors.white),
        centerTitle: true,
        elevation: 0,
        actions: [
          GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ClipRRect(
                          child: Image.asset(
                            'assets/icons/logout1.png',
                            height: height * 0.07,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        AppText(
                          'Are You Sure You Want to Logout?',
                          letterSpacing: 1,
                          fontSize: 16,
                        ),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: height * 0.04,
                                width: width * 0.3,
                                decoration: BoxDecoration(border: Border.all(color: kPrimaryColor), borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                  child: AppText(
                                    "No",
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width * 0.02,
                            ),
                            GestureDetector(
                              onTap: () {
                                logoutApi();
                              },
                              child: Container(
                                height: height * 0.04,
                                width: width * 0.3,
                                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: kPrimaryColor), borderRadius: BorderRadius.circular(8)),
                                child: _loading == false
                                    ? Center(
                                        child: AppText(
                                          "Yes",
                                          color: kPrimaryColor,
                                        ),
                                      )
                                    : Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor)),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
              child: Image.asset("assets/icons/Logout.png", scale: 7))
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: Color(0xffF5F7F9), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Padding(
          padding: EdgeInsets.fromLTRB(18, 25, 18, 0),
          child: Column(
            children: [
              Container(
                height: height * 0.1,
                width: width,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2)]),
                child: Row(
                  children: [
                    Container(
                      height: height * 0.1,
                      width: width * 0.25,
                      child: profile_pic == null || profile_pic == 'null' || profile_pic == ' '
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: string == 3
                                  ? Icon(Icons.wifi)
                                  : Center(
                                      child: CircularProgressIndicator(
                                      color: kPrimaryColor,
                                    )),
                            )
                          : string == 3
                              ? Icon(Icons.wifi)
                              : CachedNetworkImage(
                                  imageUrl: '$imageUrl${profileData['profile_pic']}',
                                  imageBuilder: (context, imageProvider) => Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                    ),
                                  ),
                                  placeholder: (context, url) => Container(alignment: Alignment.center, child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => Image.asset(
                                    "assets/images/profile-1.jpg",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                    ),
                    SizedBox(width: width * 0.03),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GoPrimeFlag == 0 || jsonData == null
                            ? Container()
                            : Row(
                                children: [
                                  Image.asset('assets/icons/Path 348.png', height: height * 0.01),
                                  SizedBox(width: width * 0.01),
                                  AppText1('Premium User', fontSize: 10, color: Color(0XFF9EA8DA)),
                                ],
                              ),
                        AppText1("${user_name ?? " "}", fontSize: 16, color: Colors.black),
                        AppText("${email ?? " "}", fontSize: 15, color: Colors.black)
                      ],
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: AppText1('My Information', color: Colors.black),
              ),
              SizedBox(height: height * 0.004),
              DetailsWidget(
                text: 'My Information',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyInformationScreen(
                        profilepic: profile_pic,
                        // phone: profileData['phone_number'],
                        email1: email,
                        userName: user_name,
                      ),
                    ),
                  ).then(
                    (value) => setState(
                      () {
                        editProFile();
                      },
                    ),
                  );
                },
              ),
              GoPrimeFlag == 0
                  ? DetailsWidget(
                      text: 'Go Premium',
                      onTap: () {
                        Platform.isIOS
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => GoPremium()),
                              ).then(
                                (value) => setState(
                                  () {
                                    editProFile();
                                  },
                                ),
                              )
                            : Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => GoPremiumAndroid()),
                              ).then(
                                (value) => setState(
                                  () {
                                    editProFile();
                                  },
                                ),
                              );
                      })
                  : Container(),
              DetailsWidget(
                text: 'Change Password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: height * 0.004),
              Align(alignment: Alignment.centerLeft, child: AppText1('My Information', color: Colors.black)),
              SizedBox(height: height * 0.004),
              DetailsWidget(
                text: 'Terms And Conditions',
                onTap: launchURL,
              ),
              DetailsWidget(
                text: 'Privacy Policy',
                onTap: _launchURL,
              ),
              SizedBox(height: height * 0.02),
              AppText('V.1.0.0', color: Colors.grey, fontFamily: 'Regular'),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL() async {
    if (await launch(_url)) throw 'Could not launch $_url';
  }

  void launchURL() async {
    if (await launch(url)) throw 'Could not launch $url';
  }
}
