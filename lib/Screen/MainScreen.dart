import 'package:chronoline/Componets/CustomWidget.dart';
import 'package:chronoline/Utils/Constant.dart';
import 'package:chronoline/Utils/ad.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'HomeScreen.dart';
import 'NewChronolineScreen.dart';
import 'ProfileScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var GoMember;
  var GoMemberAndroid;
  late BannerAd _ad;
  bool _isAdLoaded = false;

  GoPrime() async {
    var Go = await getPrefData(key: "GoPrimeMember");
    setState(() {
      GoMember = Go;

    });
  }

  var string;
  Map _source = {ConnectivityResult.none: false};
  final MyConnectivity _connectivity = MyConnectivity.instance;

  int currentTab = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = HomeScreen();

  @override
  void initState() {
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (mounted) {
        setState(() => _source = source);
      }
    });
    setState(() {
      GoPrime();
      AddLoad();
    });

    super.initState();
  }

  AddLoad() async {
    _ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {

          ad.dispose();

        },
      ),
    );
    await _ad.load();
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
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
        child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewChronolineScreen(
                    isEdit: false,
                    id: '',
                    image: '',
                    title: '',
                    chronoLineId: '',
                  ),
                ),
              );
            },
            child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: kPrimaryColor),
                child: Icon(Icons.add, size: 35, color: Colors.white))),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(top: 13),
        decoration: BoxDecoration(
            color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1, spreadRadius: 0.3)], borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
        height: GoMember != 1.toString() ? 100 : 70,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(

                  onTap: () {
                    setState(() {
                      currentScreen = HomeScreen(); // if user taps on this dashboard tab will be active
                      currentTab = 0;
                    });
                  },
                  child: Column(
                    children: [
                      Image.asset("assets/icons/Home-1.png", color: currentTab == 0 ? Color(0xff303473) : Colors.grey, scale: 7),
                      AppText(
                        "Home",
                        color: currentTab == 0 ? Color(0xff303473) : Colors.grey,
                        fontSize: 12,
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentScreen = ProfileScreen();
                      currentTab = 1;
                    });
                  },
                  child: Column(
                    children: [
                      Image.asset("assets/icons/Profile-1.png", color: currentTab == 1 ? Color(0xff303473) : Colors.grey, scale: 7),
                      AppText(
                        "Profile",
                        color: currentTab == 1 ? Color(0xff303473) : Colors.grey,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GoMember == '1'
                ? Container()
                : string == 3
                    ? Align(
                        heightFactor: 2,
                        child: Row(
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
                        ),
                      )
                    : _ad.load() == null
                        ? Container()
                        : Container(
                            height: _ad.size.height.toDouble(),
                            width: _ad.size.width.toDouble(),
                            child: AdWidget(ad: _ad),
                          ),
          ],
        ),
      ),
    );
  }
}
