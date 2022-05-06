import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chronoline/Componets/CustomAppbar.dart';
import 'package:chronoline/Componets/CustomWidget.dart';
import 'package:chronoline/Componets/CustomaddImage.dart';
import 'package:chronoline/Screen/MainScreen.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewChronolineScreen extends StatefulWidget {
  final isEdit;
  final title;
  final image;
  final id;
  final chronoLineId;

  const NewChronolineScreen({this.isEdit = false, this.title, this.image, this.id, this.chronoLineId});

  @override
  State<NewChronolineScreen> createState() => _NewChronolineScreenState();
}

class _NewChronolineScreenState extends State<NewChronolineScreen> {
  TextEditingController title = TextEditingController();

  File? _image;
  String? fileName;
  var userToken;
  var response;
  var jsonData;

  var deviceId;
  var username;
  var emaill;
  bool isloading = false;
  Dio dio = Dio();

  List coverPhotoList = [];

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
    title = TextEditingController(text: widget.title);

    super.initState();
  }

  Future getImage() async {
    final pickedFile = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(
      () {
        _image = File(pickedFile!.path);

        if (_image != null) {
          fileName = _image!.path.split('/').last;
        }
      },
    );
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
      appBar: CustomAppbar(
          color: Colors.white, color1: Colors.white, text: widget.isEdit == true ? "Edit Chronoline" : "New Chronoline", visible: true),
      body: ModalProgressHUD(
        inAsyncCall: isloading,
        progressIndicator: Center(
          child: CircularProgressIndicator(
            color: kPrimaryColor,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: height * .03),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 15, left: 20, right: 20),
                height: height,
                width: width,
                decoration: BoxDecoration(
                    color: Color(0xffF5F7F9),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    )),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height * .01),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: CustomTextField(
                          controller: title,
                          label: "Name Of title",
                          labelColor: Colors.black,
                          hintText: "Enter title",
                        ),
                      ),
                      SizedBox(height: height * .02),
                      AppText("Cover Photo", color: Colors.black, fontSize: 14),
                      SizedBox(height: height * .01),
                      widget.isEdit == true
                          ? GestureDetector(
                              onTap: () {
                                getImage();
                              },
                              child: _image != null
                                  ? AddImageBox(
                                      height: height * 0.2,
                                      width: width,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _image!,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ))
                                  : CachedNetworkImage(
                                      imageUrl: widget.image,
                                      imageBuilder: (context, imageProvider) => Container(
                                        width: width,
                                        height: height * 0.2,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
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
                                    ))
                          : GestureDetector(
                              onTap: () {
                                getImage();
                              },
                              child: _image != null
                                  ? AddImageBox(
                                      height: height * 0.2,
                                      width: width,
                                      child: _image != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.file(
                                                _image!,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Center(
                                              child: Text(
                                                '+ Add Cover Photo',
                                                style: TextStyle(fontFamily: 'Sbold', color: Colors.grey, fontSize: 16),
                                              ),
                                            ),
                                    )
                                  : AddImageBox(
                                      height: height * 0.2,
                                      width: width,
                                      child: Center(
                                        child: Text(
                                          '+ Add Cover Photo',
                                          style: TextStyle(fontFamily: 'Sbold', color: Colors.grey, fontSize: 16),
                                        ),
                                      ),
                                    )),
                      SizedBox(height: height * .28),
                      Center(
                        child: CustomButton(
                          title: "Save",
                          onPressed: () async {
                            if (widget.isEdit != true) {
                              if (validate(title: title.text)) await addChronoline();
                            } else {
                              await editchronoLine();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  var EditData;
  var editResponse;
  editchronoLine() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('user_token');

    setState(() {
      isloading = true;
    });
    Dio dio = Dio();

    try {
      editResponse = await dio.post(
        EDIT_CHRONOLINE,
        data: FormData.fromMap({
          'chronoline_id': widget.id,
          'chronoline_title': title.text,
          'cover_photo': _image == null ? '' : await MultipartFile.fromFile(_image!.path, filename: fileName),
        }),
        options: Options(
          headers: {'Authorization': 'Bearer $userToken'},
        ),
      );

      EditData = jsonDecode(editResponse.toString());

      if (EditData['status'] == 1) {
        setState(() {
          isloading = false;
        });
        Toasty.showtoast(EditData['message']);
        Navigator.pop(context);
      }
      if (EditData['status'] == 0) {
        Toasty.showtoast(EditData['message']);
      } else {
        return null;
      }
    } on DioError catch (e) {

    }
  }

  addChronoline() async {
    setState(() {
      isloading = true;
    });
    var response;
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('user_token');


    Dio dio = Dio();
    try {
      response = await dio.post(
        ADD_CHRONOLINE,
        data: FormData.fromMap(
          {
            'chronoline_title': title.text,
            'cover_photo': _image == null ? '' : await MultipartFile.fromFile(_image!.path, filename: fileName),
          },
        ),
        options: Options(
          headers: {'Authorization': 'Bearer $userToken'},
        ),
      );

      jsonData = jsonDecode(response.toString());

      if (jsonData['status'] == 1) {
        setState(() {
          isloading = false;
        });
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen()), (route) => false);
        Toasty.showtoast(jsonData['messages']);
      }
      if (jsonData['status'] == 0) {
        Toasty.showtoast(jsonData['message']);
      }
    } catch (e) {

    }
  }

  bool validate({required String title}) {
    if (string == 3) {
      Toasty.showtoast('Please Check Your Internet');
      return false;
    } else if (title.isEmpty && _image == null) {
      Toasty.showtoast('Please Enter Chronoline Details');
      return false;
    } else if (title.isEmpty) {
      Toasty.showtoast('Please Enter Title Name');
      return false;
    } else if (_image == null) {
      Toasty.showtoast('Please Select Cover Photo');
      return false;
    } else {
      return true;
    }
  }
}
