import 'dart:async';
import 'dart:io';

import 'package:chronoline/Componets/CustomAppbar.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:chronoline/componets/CustomWidget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class GoPremiumAndroid1 extends StatefulWidget {
  @override
  _GoPremiumAndroid1State createState() => _GoPremiumAndroid1State();
}

class _GoPremiumAndroid1State extends State<GoPremiumAndroid1> {
  int Selected = 0;
  bool _loading = false;
  var userToken, getData, userId;
  Response? response;
  Dio dio = Dio();
  int? is_business_profile;
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];

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
    _getProduct();
    _initIAPs();
    asyncInitState();
    getToken();
    _getProduct();
    _getPurchaseHistory();
    initPlatformState();

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

    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      if (Platform.isAndroid) {
      } else {
        if (productItem!.transactionId != null) {}
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
      var data = await FlutterInappPurchase.instance.requestSubscription(KeyOfPremium);
      setState(() {
        _loading = false;
      });
    } on Exception catch (e) {}
  }

  Future setUserData() async {
    await setPrefData(key: 'GoPrimeMember', value: "${getData['is_business_profile']}");
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
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Column(
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
                      onPressed: () {
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
      ),
    );
  }
}
