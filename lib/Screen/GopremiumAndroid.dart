import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chronoline/Componets/CustomAppbar.dart';
import 'package:chronoline/Screen/MainScreen.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:chronoline/componets/CustomWidget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class GoPremiumAndroid extends StatefulWidget {
  @override
  _GoPremiumAndroidState createState() => _GoPremiumAndroidState();
}

class _GoPremiumAndroidState extends State<GoPremiumAndroid> {
  int Selected = 0;
  bool _loading = false;
  var userToken, getData, userId;
  Response? response;
  Dio dio = Dio();
  int? is_business_profile;
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];
  var PurchaseToken;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _platformVersion = 'Unknown';
  StreamSubscription? _purchaseUpdatedSubscription;
  StreamSubscription? _purchaseErrorSubscription;
  StreamSubscription? _conectionSubscription;

  List<String> Month = [
    '1 Month',
    '6 Month',
    '1 Year',
  ];
  List<String> Price = [
    '\$ 1.99',
    '\$ 10.99',
    '\$ 19.99',
  ];
  List<String> Space = [
    '15 GB Storage',
    '20 GB Storage',
    '45 GB Storage',
  ];

  final List<String> _productLists = [
    "1.99_p1m",
    '10.99_p6m',
    '19.99_p1yr',
  ];

  @override
  void dispose() async {
    super.dispose();
    if (_conectionSubscription != null) {
      _conectionSubscription!.cancel();
      _conectionSubscription = null;
      _purchaseUpdatedSubscription!.cancel();
      _purchaseUpdatedSubscription = null;
      _purchaseErrorSubscription!.cancel();
      _purchaseErrorSubscription = null;
    }
    await FlutterInappPurchase.instance.endConnection;
  }

  void asyncInitState() async {
    await FlutterInappPurchase.instance.initialize();
  }

  Future _getPurchaseHistory() async {
    List<PurchasedItem>? items = await FlutterInappPurchase.instance.getPurchaseHistory();
    for (var item in items!) {
      this._purchases.add(item);
    }

    setState(() {
      this._items = [];
      this._purchases = items;
    });
  }

  _getProduct() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getSubscriptions(_productLists);
    for (var item in items) {
      this._items.add(item);
    }
    setState(() {
      this._items = items;
      this._purchases = [];
    });
  }

  _initIAPs() async {
    var result = await FlutterInappPurchase.instance.initialize();

    var _iaps = await FlutterInappPurchase.instance.getSubscriptions(_productLists);
    for (var i = 0; i < _iaps.length; ++i) {}
    await initPlatformState();
  }

  var string;
  Map _source = {ConnectivityResult.none: false};
  final MyConnectivity _connectivity = MyConnectivity.instance;

  @override
  void initState() {
    getToken();
    _getProduct();
    _initIAPs();
    getUserId();

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (mounted) {
        setState(() => _source = source);
      }
    });
    super.initState();
  }

  getToken() async {
    var user_token = await getPrefData(key: 'user_token');
    setState(() {
      userToken = user_token;
    });
  }

  getUserId() async {
    var user_id = await getPrefData(key: 'user_id');
    setState(() {
      userId = user_id;
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = (await FlutterInappPurchase.instance.platformVersion)!;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    var result = await FlutterInappPurchase.instance.initialize();

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    try {
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
    } catch (err) {}

    _conectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {});

    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((productItem) async {
      if (Platform.isAndroid) {
        setState(() {
          PurchaseToken = productItem!.purchaseToken;
        });

        await PurchaseToken == null ? Toasty.showtoast("Failed Get Subscription") : sendReceiptToServer(PurchaseToken);
      } else {
        if (productItem!.purchaseToken != null) {}
      }
    });

    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((purchaseError) {
      setState(() {
        _loading = false;
      });
    });
  }

  _requestPurchase(String KeyOfPremium) async {
    try {
      await FlutterInappPurchase.instance.requestSubscription(KeyOfPremium);

      setState(() {
        _loading = false;
      });
    } on Exception catch (e) {}
  }

  Future sendReceiptToServer(String receipt) async {
    setState(() {
      _loading = true;
    });
    List<PurchasedItem>? items = await FlutterInappPurchase.instance.getAvailablePurchases();

    try {
      response = await dio.post(
        ADD_RECIEPT,
        data: {'receipt_data': receipt, 'user_id': userId},
        options: Options(
          headers: {"Accept": "application/json", 'Authorization': 'Bearer $userToken'},
        ),
      );
      if (response!.statusCode == 200) {
        setState(() {
          _loading = false;
        });

        getData = jsonDecode(response.toString());
        if (getData['status'] == 1) {
          Toasty.showtoast(getData['msg']);
          setState(() {
            _loading = false;
          });
          setUserData();
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen()), (route) => false);
        } else {
          setState(() {
            _loading = false;
          });
          Toasty.showtoast(getData['msg']);
        }
      } else {
        setState(() {
          _loading = false;
        });
        Toasty.showtoast('Something Went Wrong');
      }
    } on DioError catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future setUserData() async {
    await setPrefData(key: 'GoPrimeMember', value: getData['is_business_profile'].toString());
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
        text: 'Go Premium',
        visible: true,
        color1: Colors.white,
        color: Colors.white,
        // action: Icon(
        //   Icons.backspace_outlined,
        //   color: kPrimaryColor,
        // ),
      ),
      body: Column(
        children: [
          SizedBox(height: height * 0.03),
          Center(
              child: Image.asset(
            'assets/icons/logo.png',
            height: height * 0.2,
            width: width * 0.5,
          )),
          SizedBox(height: height * 0.1),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(18, 20, 18, 0),
              width: width,
              decoration: BoxDecoration(color: Color(0xffF5F7F9), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppText1(
                      'Choose a plan',
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.012,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              Selected = index;
                            });
                          },
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                margin: EdgeInsets.only(bottom: 15),
                                height: height * 0.12,
                                width: width,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Selected == index ? kPrimaryColor : Colors.grey, width: 1.5),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Selected == index ? Color(0xffA2ABDB) : Colors.grey[100]),
                                      child: Center(
                                        child: Container(
                                          height: 15,
                                          width: 15,
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: Selected == index ? kPrimaryColor : Colors.grey[300]),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: width * 0.01,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: width * 0.7,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              AppText1(
                                                Month[index],
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                              AppText1(
                                                Price[index],
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.005,
                                        ),
                                        AppText(
                                          Space[index],
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Selected == index
                                  ? Image.asset(
                                      'assets/icons/Group 63087.png',
                                      scale: 5,
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  CustomButton(
                    title: 'continue',
                    onPressed: () async {
                      await _getProduct();
                      if (string == 3) {
                        Toasty.showtoast('Please Check Your Internet');
                      } else {
                        _loading = true;
                        if (Selected == 0) {
                          _requestPurchase(_productLists[0]);
                        } else if (Selected == 1) {
                          _requestPurchase(_productLists[1]);
                        } else {
                          _requestPurchase(_productLists[2]);
                        }
                      }
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
