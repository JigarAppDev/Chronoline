import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chronoline/Componets/CustomAppbar.dart';
import 'package:chronoline/Componets/CustomWidget.dart';
import 'package:chronoline/Screen/LogoDesignScreen.dart';
import 'package:chronoline/Screen/NewChronolineScreen.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController edittitle = TextEditingController();
  TextEditingController searchController = TextEditingController();

  bool isloading = false;
  bool isLoad = false;
  var userToken, jsonData;
  List coverPhotoList = [];
  List searchList = [];

  void onSearchTextChanged({required String text}) async {
    if (text.trim().isEmpty) {
      setState(() {
        searchList = coverPhotoList;
      });
    } else {
      List tempList = [];
      for (int i = 0; i < coverPhotoList.length; i++) {
        if (coverPhotoList[i]['chronoline_title'].toLowerCase().contains(text.toLowerCase())) {
          tempList.add(coverPhotoList[i]);
        }
      }
      setState(() {
        searchList = tempList;
      });
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
    homeScreenData();
    super.initState();
    searchController.addListener(() {
      onSearchTextChanged(text: searchController.text);
    });
  }

  FutureOr onGoBack(dynamic value) {
    homeScreenData();
    setState(() {});
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
        text: "ChronoLine",
        visible: false,
        color: Colors.white,
        color1: Colors.white,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isloading,
        opacity: 0,
        progressIndicator: Center(
          child: CircularProgressIndicator(
            color: kPrimaryColor,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                      controller: searchController,
                      style: TextStyle(fontFamily: "Regular", color: Colors.white),
                      decoration: new InputDecoration(
                          fillColor: Color(0xff3D4180),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.0), borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.0), borderRadius: BorderRadius.circular(10)),
                          prefixIcon: Image.asset("assets/icons/Icon feather-search.png", scale: 7),
                          hintText: 'Search',
                          hintStyle: TextStyle(fontFamily: "Regular", color: Colors.white)))),
              SizedBox(height: height * .03),
              Container(
                padding: EdgeInsets.only(top: 15, bottom: MediaQuery.of(context).size.height * .33),
                height: height,
                width: width,
                decoration: BoxDecoration(color: Color(0xffF5F7F9), borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(40))),
                child: string == 3 && isloading == false
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
                    : coverPhotoList.isEmpty && isloading == false
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule,
                                color: kPrimaryColor,
                              ),
                              AppText(
                                'No data found ',
                                color: kPrimaryColor,
                              ),
                            ],
                          )
                        : searchList.isNotEmpty
                            ? ListView.builder(
                                itemCount: searchList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LogoDesignScreen(
                                              id: searchList[index]['chronoline_id'],
                                              title: searchList[index]['chronoline_title'],
                                            ),
                                          ),
                                        );
                                      },
                                      onLongPress: () {
                                        showModalBottomSheet(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(30.0),
                                            ),
                                          ),
                                          context: context,
                                          builder: (context) {
                                            return SizedBox(
                                              child: Container(
                                                padding: EdgeInsets.all(15),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.all(12.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(
                                                            () {
                                                              Navigator.pop(context);
                                                            },
                                                          );
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => NewChronolineScreen(
                                                                isEdit: true,
                                                                title: searchList[index]['chronoline_title'],
                                                                image: '$imageUrl${searchList[index]['cover_photo']}',
                                                                id: searchList[index]['chronoline_id'],
                                                              ),
                                                            ),
                                                          ).then(
                                                            (value) => setState(
                                                              () {
                                                                homeScreenData();
                                                              },
                                                            ),
                                                          );
                                                        },
                                                        child: AppText(
                                                          'Edit',
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                    Divider(
                                                      thickness: 0.5,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(12.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(
                                                            () {
                                                              Navigator.pop(context);
                                                              showDeleteDialog(context, searchList[index]['chronoline_id']).then((onGoBack));
                                                            },
                                                          );
                                                        },
                                                        child: AppText(
                                                          'Delete',
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                    Divider(
                                                      thickness: 0.5,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                        width: width * 0.4,
                                                        child: Center(
                                                          child: AppText(
                                                            'Cancel',
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        height: height * .135,
                                        width: width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.white,
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(color: Colors.grey, blurRadius: 2),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                    height: height,
                                                    width: width * .25,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(15),
                                                      child: CachedNetworkImage(
                                                        imageUrl: '$imageUrl${searchList[index]['cover_photo']}',
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
                                                          child: CircularProgressIndicator(
                                                            color: kPrimaryColor,
                                                          ),
                                                        ),
                                                        errorWidget: (context, url, error) => Image.asset("assets/icons/Group 63044.png"),
                                                      ),
                                                    )),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    AppText1(
                                                      // 'Party Time',
                                                      searchList[index]['chronoline_title'],
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 18,
                                                    ),
                                                    AppText(
                                                        // '11:20',
                                                        searchList[index]['format_time'],
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w500),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Icon(
                                                Icons.arrow_forward_ios_outlined,
                                                color: Colors.black,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : ListView.builder(
                                itemCount: coverPhotoList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LogoDesignScreen(
                                              id: coverPhotoList[index]['chronoline_id'],
                                              title: coverPhotoList[index]['chronoline_title'],
                                            ),
                                          ),
                                        );
                                      },
                                      onLongPress: () {
                                        showModalBottomSheet(
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(30.0),
                                              ),
                                            ),
                                            context: context,
                                            builder: (context) {
                                              return SizedBox(
                                                child: Container(
                                                  padding: EdgeInsets.all(15),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.all(12.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              Navigator.pop(context);
                                                            });
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => NewChronolineScreen(
                                                                  isEdit: true,
                                                                  title: coverPhotoList[index]['chronoline_title'],
                                                                  image: '$imageUrl${coverPhotoList[index]['cover_photo']}',
                                                                  id: coverPhotoList[index]['chronoline_id'],
                                                                ),
                                                              ),
                                                            ).then((value) => setState(() {
                                                                  homeScreenData();
                                                                }));
                                                          },
                                                          child: AppText(
                                                            'Edit',
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                      Divider(
                                                        thickness: 0.5,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(12.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              Navigator.pop(context);
                                                              showDeleteDialog(context, coverPhotoList[index]['chronoline_id']).then((onGoBack));
                                                            });
                                                          },
                                                          child: AppText(
                                                            'Delete',
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                      Divider(
                                                        thickness: 0.5,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                                          width: width * 0.4,
                                                          child: Center(
                                                            child: AppText(
                                                              'Cancel',
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      child: Container(
                                        height: height * .135,
                                        width: width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.white,
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(color: Colors.grey, blurRadius: 2),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                    height: height,
                                                    width: width * .25,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(15),
                                                      child: CachedNetworkImage(
                                                        imageUrl: '$imageUrl${coverPhotoList[index]['cover_photo']}',
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
                                                        errorWidget: (context, url, error) => Image.asset("assets/icons/Group 63044.png"),
                                                      ),
                                                    )),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    AppText1(
                                                      // 'Party Time',
                                                      coverPhotoList[index]['chronoline_title'],
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 18,
                                                    ),
                                                    AppText(
                                                        // '11:20',
                                                        coverPhotoList[index]['format_time'],
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w500),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Icon(
                                                Icons.arrow_forward_ios_outlined,
                                                color: Colors.black,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Dio dio = Dio();
  var response;
  var results;

  homeScreenData() async {
    setState(() {
      isloading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('user_token');

    try {
      response = await dio.post(GET_MY_CHRONOLINE, options: Options(headers: {'Authorization': 'Bearer $userToken'}));
      jsonData = jsonDecode(response.toString());
      if (jsonData['status'] == 1 && mounted) {
        setState(
          () {
            isloading = false;
            coverPhotoList = jsonData['data'];
            log(coverPhotoList.toString());
          },
        );
      }
      if (jsonData['status'] == 0) {
        Toasty.showtoast(jsonData['message']);
      }
    } on DioError catch (e) {}
  }

  Future<void> showDeleteDialog(BuildContext context, int chronoLineId) async {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          deleteSet() async {
            setState(() {
              isloading = true;
            });

            var jsonData;
            Dio dio = Dio();
            try {
              final response = await dio.post(
                DELETE_CHRONOLINE,
                data: {
                  'chronoline_id': chronoLineId,
                },
                options: Options(
                  headers: {'Authorization': 'Bearer $userToken'},
                ),
              );
              if (response.statusCode == 200) {
                setState(() {
                  isloading = false;
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
            } on DioError catch (e) {}
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
                        await deleteSet();
                      },
                      child: Container(
                        height: height * 0.04,
                        width: width * 0.3,
                        decoration: BoxDecoration(border: Border.all(color: kPrimaryColor), borderRadius: BorderRadius.circular(8)),
                        child: isloading == false
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
}
