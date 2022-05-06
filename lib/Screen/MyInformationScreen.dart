import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chronoline/Componets/CustomAppbar.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:chronoline/componets/CustomWidget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class MyInformationScreen extends StatefulWidget {
  final userName, email1, /*phone*/ profilepic;

  const MyInformationScreen({
    this.profilepic,
    this.userName,
    this.email1,
    /*this.phone*/
  });

  @override
  _MyInformationScreenState createState() => _MyInformationScreenState();
}

class _MyInformationScreenState extends State<MyInformationScreen> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phoneNo = TextEditingController();
  TextEditingController address = TextEditingController();
  bool _loading = false;
  var jsonData, updateData, image;
  Dio dio = Dio();
  var response;

  late String userToken;

  Future getData() async {
    var user_token = await getPrefData(key: 'user_token');

    setState(
      () {
        userToken = user_token;
        username = TextEditingController(text: widget.userName.toString());
        email = TextEditingController(text: widget.email1.toString());
      },
    );
    await myProfile();
  }

  myProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      response = await dio.post(
        EDIT_PROFILE,
        options: Options(
          headers: {'Authorization': 'Bearer $userToken'},
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
          jsonData = jsonDecode(response.data);

        });
        if (jsonData['status'] == 1) {
          setState(() {
            username = TextEditingController(text: jsonData['data']['user_name']);
            email = TextEditingController(text: jsonData['data']['email']);
            phoneNo = TextEditingController(text: jsonData['data']['phone_number']);

            address = TextEditingController(text: jsonData['data']['address']);
            image = jsonData['data']['profile_pic'];

          });
        } else {
          Toasty.showtoast(jsonData['message']);
        }
      }
    } catch (e) {

    }
  }

  Future<dynamic> editProFile() async {
    setState(() {
      _loading = true;
    });
    Dio dio = Dio();
    var data, data1;
    _image == null
        ? data = FormData.fromMap({
            'user_name': username.text,
            'email': email.text,
            'phone_number': phoneNo.text,
            'address': address.text,
          })
        : data1 = FormData.fromMap({
            'user_name': username.text,
            'email': email.text,
            'phone_number': phoneNo.text,
            'address': address.text,
            'profile_pic': _image == null ? '' : await MultipartFile.fromFile(_image!.path, filename: fileName),
          });

    try {
      final response = await dio.post(
        EDIT_PROFILE,
        data: _image == null ? data : data1,
        options: Options(
          headers: {'Authorization': 'Bearer $userToken'},
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
          jsonData = jsonDecode(response.toString());

        });
        if (jsonData['status'] == 1) {
          Navigator.pop(context);
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
    getData();

    super.initState();
  }

  File? _image;
  String? fileName;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);

      if (_image != null) {
        fileName = _image!.path.split('/').last;
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
      appBar: CustomAppbar(text: 'My Information', visible: true, color: Colors.white, color1: Colors.white),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          height: height,
          width: width,
          decoration: BoxDecoration(color: Color(0xffF5F7F9), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      _image != null
                          ? DottedBorder(
                              borderType: BorderType.RRect,
                              dashPattern: [4, 4],
                              strokeWidth: 1.2,
                              radius: Radius.circular(80),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(80),
                                  child:
                                      Container(height: 100, width: 100, child: ClipRRect(borderRadius: BorderRadius.circular(80), child: Image.file(_image!, fit: BoxFit.cover)))),
                            )
                          : image == null || image == 'null' || image == ''
                              ? Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.asset(
                                      'assets/icons/Group 63044.png',
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: '$imageUrl/$image',
                                  imageBuilder: (context, imageProvider) => Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => Container(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Image.asset("assets/icons/Group 63044.png"),

                                ),
                      Positioned(
                        child: GestureDetector(
                          onTap: () {
                            getImage();
                          },
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: Radius.circular(80),
                            dashPattern: [4, 4],
                            strokeWidth: 1.2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: Container(
                                height: 100,
                                width: 100,
                                child: Image.asset('assets/icons/Group 63044.png', scale: 5, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                  CustomTextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp("[A-Z]")),
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    controller: username,
                    labelColor: Colors.black,
                    label: 'Username',
                    hintText: "Enter Username",
                  ),
                  SizedBox(height: height * 0.01),
                  CustomTextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp("[A-Z]")),
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    controller: email,
                    labelColor: Colors.black,
                    label: 'Email',
                    hintText: "Enter Email",
                  ),
                  SizedBox(height: height * 0.01),
                  CustomTextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    maxnumber: 13,
                    controller: phoneNo,
                    labelColor: Colors.black,
                    label: 'Phone Number',
                    hintText: "Enter Phone Number",
                    input: TextInputType.number,
                  ),
                  SizedBox(height: height * 0.01),
                  CustomTextField(
                    controller: address,
                    labelColor: Colors.black,
                    label: 'Address',
                    hintText: "Enter Address",
                  ),
                  SizedBox(height: height * 0.08),
                  CustomButton(
                      title: 'Save',
                      onPressed: () {
                        if (string == 3) {
                          Toasty.showtoast('Please Check Your Internet');
                        } else {
                          editProFile();
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
