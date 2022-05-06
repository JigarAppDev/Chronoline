import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chronoline/Componets/CustomAppbar.dart';
import 'package:chronoline/Componets/CustomWidget.dart';
import 'package:chronoline/Componets/CustomaddImage.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:images_picker/images_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AddTaskScreen extends StatefulWidget {
  // final List<PlatformFile>? files;
  // final ValueChanged<PlatformFile>? onOpenedFile;
  final id;
  const AddTaskScreen({this.id});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  TextEditingController TaskName = TextEditingController();
  VideoPlayerController? _controller;
  int selected = 0;
  var userToken;
  var jsonData;
  var response;
  var name;
  bool isloading = false;
  Dio dio = Dio();

  FlickManager? flickManager;

  List<Color> selectColor = [Color(0xFFFBDED1), Color(0xFFFD4DEFC), Color(0xFFE5D5FE), Color(0xFFFBE7D7), Color(0xFFF3D0CE)];
  @override
  void initState() {
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (mounted) {
        setState(() => _source = source);
      }
    });

    super.initState();
  }

  List pickedMediaList = [];
  List mediaListForAPIRequest = [];

  pickFiles() async {
    final result = await ImagesPicker.pick(
      pickType: PickType.all,
      count: 200,
    );

    setState(() {});
    if (result != null) {
      for (int i = 0; i < result.length; i++) {
        if (result[i].path.split('.').last.toString().toLowerCase() == 'mp4' || result[i].path.split('.').last == 'MOV') {
          pickedMediaList.add({'path': await _generateThumbnail(result[i].path), 'ext': result[i].path.split('.').last});
          mediaListForAPIRequest.add({
            'image': '',
            'video_path': result[i].path,
            'video_thumbnail': await _generateThumbnail(result[i].path),
            'ext': result[i].path.split('.').last,
          });
          setState(() {});
        } else {
          setState(() {
            pickedMediaList.add({'path': result[i].path, 'ext': result[i].path.split('.').last});
            mediaListForAPIRequest.add({
              'image': result[i].path,
              'video_path': '',
              'video_thumbnail': '',
              'ext': result[i].path.split('.').last,
            });
          });
        }
      }
    }

    log(pickedMediaList.toString());
    log(mediaListForAPIRequest.toString());
  }

  String? thumbnailImagePath;

  _generateThumbnail(var video) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    final fileName = await VideoThumbnail.thumbnailFile(video: video, thumbnailPath: tempPath, imageFormat: ImageFormat.PNG, quality: 100);

    setState(() {
      final file = File(fileName!);
      var filePath = file.path;
      thumbnailImagePath = filePath;
    });
    return thumbnailImagePath;
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
      appBar: CustomAppbar(text: "Add Task", visible: true, color: Colors.white, color1: Colors.white),
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
                padding: EdgeInsets.only(top: 15, bottom: 10),
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: Color(0xffF5F7F9),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * .04),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: CustomTextField(controller: TaskName, label: "Name Of Task", labelColor: Colors.black, hintText: "Enter task name")),
                        SizedBox(height: height * .02),
                        AppText("Add Photo And Video", color: Colors.black, fontSize: 14),
                        SizedBox(height: height * .01),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: pickFiles,
                                child: AddImageBox(
                                  height: height * 0.15,
                                  width: width * 0.3,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('+', style: TextStyle(fontFamily: 'Sbold', color: Colors.grey, fontSize: 16)),
                                        Text('Add', style: TextStyle(fontFamily: 'Sbold', color: Colors.grey, fontSize: 16))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: height * .18,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: pickedMediaList.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        child: Stack(
                                          overflow: Overflow.visible,
                                          alignment: Alignment.center,
                                          children: [
                                            Center(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.file(
                                                  File(pickedMediaList[index]['path']),
                                                  fit: BoxFit.cover,
                                                  height: height * .16,
                                                  width: width * .3,
                                                ),
                                                // : Container(
                                                //     height: height * .16,
                                                //     width: width * .3,
                                                //     child: pickedthumbnailList.isEmpty
                                                //         ? Container(
                                                //             color: Colors.black,
                                                //           )
                                                //         : Image.file(
                                                //             File(
                                                //               pickedthumbnailList[index],
                                                //             ),
                                                //             fit: BoxFit.cover,
                                                //           ),
                                                //   ),
                                                // : Container(
                                                //     height: height * .16,
                                                //     width: width * .3,
                                                //     child: FlickVideoPlayer(
                                                //       flickManager: FlickManager(
                                                //         videoPlayerController: VideoPlayerController.network(
                                                //           pickedMediaList[index]['path'],
                                                //         ),
                                                //         autoInitialize: true,
                                                //         autoPlay: false,
                                                //       ),
                                                //       flickVideoWithControls: FlickVideoWithControls(
                                                //         playerLoadingFallback: Positioned.fill(
                                                //           child: Center(
                                                //             child: Container(
                                                //               width: 20,
                                                //               height: 20,
                                                //               child: CircularProgressIndicator(
                                                //                 backgroundColor: Colors.white,
                                                //                 strokeWidth: 4,
                                                //               ),
                                                //             ),
                                                //           ),
                                                //         ),
                                                //       ),
                                                //       flickVideoWithControlsFullscreen: FlickVideoWithControls(
                                                //         controls: FlickLandscapeControls(),
                                                //         iconThemeData: IconThemeData(
                                                //           size: 40,
                                                //           color: Colors.white,
                                                //         ),
                                                //         textStyle: TextStyle(fontSize: 16, color: Colors.white),
                                                //       ),
                                                //     ),
                                                //   ),
                                              ),
                                            ),
                                            pickedMediaList[index]['ext'] == 'jpg' || pickedMediaList[index]['ext'] == 'jpeg' || pickedMediaList[index]['ext'] == 'png'
                                                ? Container()
                                                : Container(
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(shape: BoxShape.circle, color: kPrimaryColor.withOpacity(0.7)),
                                                    child: Icon(
                                                      Icons.play_arrow_rounded,
                                                      size: 30,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                            Positioned(
                                              right: -5,
                                              top: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    pickedMediaList.remove(pickedMediaList[index]);
                                                  });
                                                },
                                                child: Image.asset("assets/icons/remove.png", scale: 7),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * .02),
                        AppText("Select Color", color: Colors.black, fontSize: 14),
                        SizedBox(height: height * .01),
                        Container(
                          height: height * .09,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: ListView.builder(
                              itemCount: selectColor.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(
                                      () {
                                        selected = index;
                                      },
                                    );
                                  },
                                  child: selected == index
                                      ? DottedBorder(
                                          dashPattern: [4],
                                          borderType: BorderType.RRect,
                                          radius: Radius.circular(10),
                                          strokeWidth: 1,
                                          child: Container(
                                            height: height * .09,
                                            width: width * .15,
                                            decoration: BoxDecoration(color: selectColor[index], borderRadius: BorderRadius.circular(10)),
                                            child: Center(
                                              child: Image.asset("assets/icons/ic_cheak.png", scale: 6),
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          child: Container(
                                            width: width * .145,
                                            decoration: BoxDecoration(
                                              color: selectColor[index],
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: height * .25),
                        Center(
                          child: CustomButton(
                            title: "Save",
                            onPressed: () {
                              if (validate(TaskName: TaskName.text)) {
                                addTask();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  addTask() async {
    setState(() {
      isloading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('user_token');
    var formdata = FormData.fromMap({
      'chronoline_id': widget.id,
      'task_name': TaskName.text,
      'tag_color': selected == 0
          ? '0xFFFBDED1'
          : selected == 1
              ? '0xFFFD4DEFC'
              : selected == 2
                  ? '0xFFE5D5FE'
                  : selected == 3
                      ? '0xFFFBE7D7'
                      : '0xFFF3D0CE',
    });

    for (var file in mediaListForAPIRequest) {
      if (file['ext'].toString().toLowerCase() == 'mp4' || file['ext'].toString().toLowerCase() == 'mov') {
        formdata.files.addAll([
          MapEntry("urls[]", await MultipartFile.fromFile(file["video_path"], filename: file["video_path"].split('/').last)),
        ]);
        formdata.files.addAll([
          MapEntry("url_thumbnail[]", await MultipartFile.fromFile(file["video_thumbnail"], filename: file["video_thumbnail"].split('/').last)),
        ]);
      } else {
        formdata.files.addAll([
          MapEntry("image[]", await MultipartFile.fromFile(file["image"], filename: file["image"].split('/').last)),
        ]);
      }
    }
    try {
      response = await dio.post(
        ADD_CHRONOLINE_TASK,
        data: formdata,
        options: Options(headers: {'Authorization': 'Bearer $userToken'}),
      );
      jsonData = jsonDecode(response.toString());
      if (jsonData['status'] == 1) {
        setState(() {
          isloading = false;
        });
        Toasty.showtoast(jsonData['message']);
        Navigator.pop(context);
      }
      if (jsonData['status'] == 0) {
        Toasty.showtoast(jsonData['message']);
      }
    } on DioError catch (e) {}
  }

  bool validate({required String TaskName}) {
    if (string == 3) {
      Toasty.showtoast('Please Check Your Internet');
      return false;
    } else if (TaskName.isEmpty && pickedMediaList.isEmpty) {
      Toasty.showtoast('Please Enter Task Details');
      return false;
    } else if (TaskName.isEmpty) {
      Toasty.showtoast('Please Enter Task Name');
      return false;
    } else if (pickedMediaList.isEmpty) {
      Toasty.showtoast('Please select Photo and video');
      return false;
    } else {
      return true;
    }
  }
}
