import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chronoline/Componets/CustomWidget.dart';
import 'package:chronoline/Screen/AddTaskScreen.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:video_player/video_player.dart';

class LogoDesignScreen extends StatefulWidget {
  final id;
  final title;

  const LogoDesignScreen({Key? key, this.id, this.title}) : super(key: key);

  @override
  State<LogoDesignScreen> createState() => _LogoDesignScreenState();
}

class _LogoDesignScreenState extends State<LogoDesignScreen> {
  TextEditingController editTask = TextEditingController();

  FlickManager? flickManager;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? Video;
  bool error = false;
  var date;
  var play;
  var pause;
  var userToken;
  var response;
  var jsonData;
  int selected = 0;
  int? selectedColor;
  var color;
  var loading = false;
  bool isplay = false;
  bool calender = false;
  bool isrow = true;
  Dio dio = Dio();
  List logoDetails = [];
  var photoList = [];
  var url;
  List createDataSet = [];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        if (DateFormat('yyyy-MM-dd').format(selectedDay) == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
          setState(() {
            isrow = true;
          });
        } else {
          setState(() {
            isrow = false;
          });
        }

        date = DateFormat('yyyy-MM-dd').format(selectedDay);

        LogoDesignDetails();
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  toggle() {
    setState(() {
      calender = !calender;
    });
  }

  CalendarFormat format = CalendarFormat.week;

  NextWorkVideo(index, index1) {
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(
        "$imageUrl/${logoDetails[index]["images"][index1]['urls']}",
        videoPlayerOptions: VideoPlayerOptions(),
      ),
      autoInitialize: true,
      autoPlay: true,
    );
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

    LogoDesignDetails();
    super.initState();
  }

  FutureOr onGoBack(dynamic value) {
    LogoDesignDetails();
  }

  VideoDispose() {
    Navigator.pop(context, {flickManager!.dispose()});
  }

  @override
  void dispose() {
    flickManager!.dispose();
    super.dispose();
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
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Image.asset("assets/icons/Fill 4.png", scale: 7),
        ),
        elevation: 0,
        centerTitle: true,
        title: AppText1(widget.title, color: Colors.white, fontSize: 22),
        backgroundColor: Colors.transparent,
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                toggle();
              });
            },
            child: Image.asset("assets/icons/Group 63086.png", height: height * .1, width: width * .1),
          ),
          SizedBox(width: 20)
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        progressIndicator: CircularProgressIndicator(
          color: kPrimaryColor,
        ),
        child: Column(
          children: [
            Visibility(
              visible: calender,
              child: TableCalendar(

                focusedDay: _focusedDay,
                onDaySelected: (selectedDay, focusedDay) {
                  _onDaySelected(selectedDay, focusedDay);

                },
                headerVisible: true,
                calendarFormat: format,
                onFormatChanged: (CalendarFormat _format) {
                  setState(() {
                    format = _format;
                  });
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },

                headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: Colors.white),
                    leftChevronIcon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                    rightChevronIcon: Icon(Icons.arrow_forward_ios_outlined, color: Colors.white, size: 18)),
                calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(color: Colors.white),
                    todayTextStyle: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    selectedTextStyle: TextStyle(color: Colors.white, fontSize: 15)),
                daysOfWeekVisible: true,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white),
                  weekendStyle: TextStyle(color: Colors.white),
                  dowTextFormatter: (date, locale) {
                    return DateFormat.E(locale).format(date).substring(0, 1);
                  },
                ),
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                // focusedDay: DateTime.now(
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: Color(0xffF5F7F9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: string == 3 && loading == false
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            color: Colors.grey,
                          ),
                          AppText(
                            'Please Check Your Internet',
                            color: Colors.grey,
                          ),
                        ],
                      )
                    : logoDetails.isEmpty && loading == false && isrow == false
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule,
                                color: kPrimaryColor,
                              ),
                              Text(
                                'No data found ',
                                style: TextStyle(color: kPrimaryColor),
                              ),
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Column(
                              children: [
                                Visibility(
                                  visible: isrow,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppText1(getCurrentDate(), color: Colors.black, fontSize: 16),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddTaskScreen(
                                                id: widget.id,
                                              ),
                                            ),
                                          ).then(
                                            (value) => setState(
                                              () {
                                                LogoDesignDetails();
                                              },
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: height * .05,
                                          width: width * .2,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Color(0xffA2ABDB)),
                                          child: Center(
                                            child: AppText1("+ Add", color: Colors.white),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: height * .01),
                                Expanded(
                                  child: Container(
                                    height: height,
                                    width: width,
                                    child: ListView.builder(
                                      itemCount: logoDetails.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        var dateTime = DateFormat("h:mm a");
                                        String createdDate = dateTime.parse(logoDetails[index]['format_time'], true).toLocal().toString();
                                        String inputFormat = dateTime.format(DateTime.parse(createdDate));
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  AppText('$inputFormat'),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                                      child: Column(
                                                        children: [
                                                          Divider(color: Colors.black12, thickness: 1),
                                                          Container(
                                                            height: height * .33,
                                                            width: width,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(15),
                                                              border: Border.all(
                                                                  color: Color(int.parse(logoDetails[index]['tag_color'])), width: 1.5),
                                                            ),
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  height: height * .07,
                                                                  width: width,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    color: Color(int.parse(logoDetails[index]['tag_color'])),
                                                                  ),
                                                                  child: Padding(
                                                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        AppText1(logoDetails[index]['task_name'], color: Colors.black),
                                                                        Container(
                                                                          width: 30,
                                                                          height: 30,
                                                                          child: PopupMenuButton(
                                                                            onSelected: (result) {
                                                                              if (result == 1) {
                                                                                showDeleteDialog1(context, logoDetails[index]['task_id'])
                                                                                    .then((onGoBack));
                                                                              } else {
                                                                                editTask = TextEditingController(
                                                                                    text: logoDetails[index]['task_name']);
                                                                                color = logoDetails[index]['tag_color'];
                                                                                showeditDialog(context, logoDetails[index]['task_id'])
                                                                                    .then((onGoBack));
                                                                              }
                                                                            },
                                                                            itemBuilder: (context) => [
                                                                              PopupMenuItem(
                                                                                child: Text('Edit'),
                                                                                value: 0,
                                                                              ),
                                                                              PopupMenuItem(
                                                                                child: Text('Delete'),
                                                                                value: 1,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: ListView.builder(
                                                                    scrollDirection: Axis.horizontal,
                                                                    itemCount: logoDetails[index]["images"].length,
                                                                    itemBuilder: (context, index1) {
                                                                      return Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                                                        child: GestureDetector(
                                                                          onTap: () async {
                                                                            showGeneralDialog(
                                                                              context: context,
                                                                              barrierColor:
                                                                                  Colors.black12.withOpacity(0.8), // Background color
                                                                              pageBuilder: (_, __, ___) {
                                                                                NextWorkVideo(index, index1);
                                                                                return WillPopScope(
                                                                                  onWillPop: () {
                                                                                    return VideoDispose();
                                                                                  },
                                                                                  child: Stack(
                                                                                    children: [
                                                                                      Center(
                                                                                        child: logoDetails[index]['images'][index1]['urls']
                                                                                                        .split(".")
                                                                                                        .last ==
                                                                                                    'mp4' ||
                                                                                                logoDetails[index]['images'][index1]['urls']
                                                                                                        .split(".")
                                                                                                        .last ==
                                                                                                    'MP4' ||
                                                                                                logoDetails[index]['images'][index1]['urls']
                                                                                                        .split(".")
                                                                                                        .last
                                                                                                        .toString()
                                                                                                        .toLowerCase() ==
                                                                                                    'mov'
                                                                                            ? Container(
                                                                                                height: 300,
                                                                                                child: FlickVideoPlayer(
                                                                                                  flickManager: flickManager!,

                                                                                                  flickVideoWithControls:
                                                                                                      FlickVideoWithControls(
                                                                                                    videoFit: BoxFit.contain,
                                                                                                    controls: FlickPortraitControls(
                                                                                                      progressBarSettings:
                                                                                                          FlickProgressBarSettings(),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              )
                                                                                            : CachedNetworkImage(
                                                                                                imageUrl:
                                                                                                    '$imageUrl/${logoDetails[index]["images"][index1]['urls']}',
                                                                                                imageBuilder: (context, imageProvider) =>
                                                                                                    Container(
                                                                                                  height: 300,
                                                                                                  decoration: BoxDecoration(
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
                                                                                              ),
                                                                                      ),
                                                                                      Positioned(
                                                                                        top: 20,
                                                                                        right: 10,
                                                                                        child: GestureDetector(
                                                                                          child: Icon(
                                                                                            Icons.close_rounded,
                                                                                            color: Colors.white,
                                                                                            size: 40,
                                                                                          ),
                                                                                          onTap: () {
                                                                                            Navigator.pop(
                                                                                                context, {flickManager!.dispose()});
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                          child: Container(
                                                                            width: width * .45,
                                                                            height: height * .16,
                                                                            child: ClipRRect(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              child: logoDetails[index]['images'][index1]['urls']
                                                                                              .split(".")
                                                                                              .last ==
                                                                                          'mp4' ||
                                                                                      logoDetails[index]['images'][index1]['urls']
                                                                                              .split(".")
                                                                                              .last ==
                                                                                          'MP4' ||
                                                                                      logoDetails[index]['images'][index1]['urls']
                                                                                              .split(".")
                                                                                              .last
                                                                                              .toString()
                                                                                              .toLowerCase() ==
                                                                                          'mov'
                                                                                  ? Stack(
                                                                                      children: [
                                                                                        CachedNetworkImage(
                                                                                          imageUrl:
                                                                                              '$imageUrl/${logoDetails[index]["images"][index1]['url_thumbnail']}',
                                                                                          imageBuilder: (context, imageProvider) =>
                                                                                              Container(
                                                                                            width: width * .45,
                                                                                            height: height * .25,
                                                                                            decoration: BoxDecoration(
                                                                                              borderRadius: BorderRadius.circular(15),
                                                                                              image: DecorationImage(
                                                                                                image: imageProvider,
                                                                                                fit: BoxFit.cover,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          placeholder: (context, url) => Container(
                                                                                            alignment: Alignment.center,
                                                                                            child: CircularProgressIndicator(
                                                                                              color: kPrimaryColor,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Center(
                                                                                          child: Container(
                                                                                            height: 40,
                                                                                            width: 40,
                                                                                            decoration: BoxDecoration(
                                                                                                shape: BoxShape.circle,
                                                                                                color: kPrimaryColor.withOpacity(0.7)),
                                                                                            child: Icon(
                                                                                              Icons.play_arrow_rounded,
                                                                                              size: 30,
                                                                                              color: Colors.white,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : CachedNetworkImage(
                                                                                      imageUrl:
                                                                                          '$imageUrl/${logoDetails[index]["images"][index1]['urls']}',
                                                                                      imageBuilder: (context, imageProvider) => Container(
                                                                                        width: 100,
                                                                                        height: 100,
                                                                                        decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(15),
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
                                                                                    ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
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


  List days = ['Monday', 'Tuesday', 'WednesDay', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  String getCurrentDate() {
    var date = DateTime.now().toString();
    var dateParse = DateTime.parse(date);

    var formattedDate = "${days[dateParse.weekday - 1]} ${dateParse.day}";
    return formattedDate.toString();
  }

  LogoDesignDetails() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('user_token');

    try {
      setState(() {
      });
      response = await dio.post(GET_CHRONOLINE_DETAILS,
          data: {'chronoline_id': widget.id, 'created_at': date},
          options: Options(headers: {
            'Authorization': 'Bearer $userToken',
          }));

      jsonData = jsonDecode(response.toString());


      if (jsonData['status'] == 1) {
        setState(
          () {
            loading = false;
            logoDetails = jsonData['data']['ch_chronoline_tasks'];
            for (var i in logoDetails) {
              for (var j in i['images']) {
                photoList.add(j);

              }
            }
          },
        );
      }
      if (jsonData['status'] == 0) {
        Toasty.showtoast(jsonData['message']);
      }
    } on DioError catch (e) {

    }
  }

  Future<void> showDeleteDialog1(BuildContext context, int taskId) async {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          deleteLogo() async {
            setState(() {
              loading = true;
            });

            var jsonData;
            Dio dio = Dio();
            try {
              final response = await dio.post(
                DELETE_CHRONOLINE_TASK,
                data: {
                  'task_id': taskId,
                },
                options: Options(
                  headers: {'Authorization': 'Bearer $userToken'},
                ),
              );
              if (response.statusCode == 200) {
                setState(() {
                  loading = false;
                  jsonData = jsonDecode(response.toString());

                });
                if (jsonData['status'] == 1) {

                  Toasty.showtoast(jsonData['message']);
                  Navigator.pop(context);
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

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
            elevation: 0,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * .01,
                ),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/icons/delete.png',
                      height: height * 0.06,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .01,
                ),
                Center(
                  child: AppText('Are you sure you want to Delete ?', color: kPrimaryColor, fontFamily: 'regular', fontSize: 16),
                ),
                SizedBox(height: height * 0.01),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                            "Cancel",
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await deleteLogo();
                      },
                      child: Container(
                        height: height * 0.04,
                        width: width * 0.3,
                        decoration: BoxDecoration(border: Border.all(color: kPrimaryColor), borderRadius: BorderRadius.circular(8)),
                        child: loading == false
                            ? Center(
                                child: AppText(
                                  "Delete",
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
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> showeditDialog(BuildContext context, int taskId) async {
    color == '0xFFFBDED1'
        ? selected = 0
        : color == '0xFFFD4DEFC'
            ? selected = 1
            : color == '0xFFE5D5FE'
                ? selected = 2
                : color == '0xFFFBE7D7'
                    ? selected = 3
                    : selected = 4;



    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          edittask() async {
            setState(() {
              loading = true;
            });

            var jsonData;
            Dio dio = Dio();
            try {
              final response = await dio.post(
                EDIT_CHRONOLINE_TASK,
                data: {
                  'task_id': taskId,
                  'task_name': editTask.text,
                  "tag_color": selected == 0
                      ? '0xFFFBDED1'
                      : selected == 1
                          ? '0xFFFD4DEFC'
                          : selected == 2
                              ? '0xFFE5D5FE'
                              : selected == 3
                                  ? '0xFFFBE7D7'
                                  : '0xFFF3D0CE',
                },
                options: Options(
                  headers: {'Authorization': 'Bearer $userToken'},
                ),
              );
              if (response.statusCode == 200) {
                setState(() {
                  loading = false;
                  jsonData = jsonDecode(response.toString());

                });
                if (jsonData['status'] == 1) {

                  Toasty.showtoast(jsonData['message']);
                  Navigator.pop(context);
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


          List<Color> selectColor = [Color(0xFFFBDED1), Color(0xFFFD4DEFC), Color(0xFFE5D5FE), Color(0xFFFBE7D7), Color(0xFFF3D0CE)];

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
            elevation: 0,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Edit Task',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: kPrimaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: AppText("Name of Task", fontSize: 14, fontWeight: FontWeight.w300, color: Colors.black),
                ),
                Container(
                  height: 50,
                  child: TextField(
                    controller: editTask,
                    cursorColor: Colors.black,
                    style: TextStyle(color: Colors.black, fontFamily: 'RobotoCR', fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Logo Inspiration',
                      hintStyle: TextStyle(color: Colors.black, fontFamily: 'RobotoCR', fontSize: 13),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: kPrimaryColor, width: 1.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                AppText("Select Color", color: Colors.black, fontSize: 14),
                SizedBox(height: height * .01),
                Container(
                  height: height * .09,
                  width: width * .65,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ListView.builder(
                      itemCount: selectColor.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selected = index;

                            });
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
                SizedBox(height: height * .03),
                CustomButton(
                    title: 'Save',
                    onPressed: () async {
                      edittask();
                    }),
              ],
            ),
          );
        });
      },
    );
  }
}
