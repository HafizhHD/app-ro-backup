import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' hide Response;
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:ruangkeluarga/main.dart';
import 'package:ruangkeluarga/model/rk_child_model.dart';
import 'package:ruangkeluarga/model/rk_user_model.dart';
import 'package:ruangkeluarga/parent/view/addon/addon_page.dart';
import 'package:ruangkeluarga/parent/view/detail_child_view.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/parent/view/main/parent_drawer.dart';
import 'package:ruangkeluarga/parent/view/setup_invite_child.dart';
import 'package:ruangkeluarga/plugin_device_app.dart';
import 'package:ruangkeluarga/utils/app_usage.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class HomeParentPage extends StatefulWidget {
  @override
  _HomeParentPageState createState() => _HomeParentPageState();
}

class _HomeParentPageState extends State<HomeParentPage> {
  late SharedPreferences prefs;
  late YoutubePlayerController _controller;
  bool flag = false;
  double _opacity = 0.0;
  List<AppUsageInfo> _infos = [];
  late Future<List<Application>> apps;
  List<Application> itemsApp = [];
  List<Child> childsList = [];
  late Future<List<Child>> fChildList;
  String childName = '';
  String userName = '';
  String emailUser = '';

  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;

  final List<String> _ids = [
    'unsplash-digital-habit.jpg',
    'unsplash-reward.jpg',
    'unsplash-parenting.jpg',
  ];

  void _changed(double opacity) {
    setState(() {
      // flag = visibility;
      _opacity = opacity;
    });
  }

  void _isVisibleChange(bool visibility) {
    setState(() {
      flag = visibility;
    });
  }

  void getUsageStats() async {
    try {
      DateTime endDate = new DateTime.now();
      DateTime startDate = endDate.subtract(Duration(hours: 1));
      List<AppUsageInfo> infoList = await AppUsage.getAppUsage(startDate, endDate);
      setState(() {
        _infos = infoList;
        log('list info $infoList');
      });

      for (var info in infoList) {
        print(info.toString());
      }
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  void getUsageStatistik() async {
    prefs = await SharedPreferences.getInstance();
    var outputFormat = DateFormat('yyyy-MM-dd');
    var outputDate = outputFormat.format(DateTime.now());
    Response response = await MediaRepository().fetchAppUsageFilter(prefs.getString("rkChildEmail").toString(), outputDate);
    if (response.statusCode == 200) {
      print('isi response filter app usage : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonDataResult = json['appUsages'] as List;
        await prefs.setString("childAppUsage", jsonEncode(jsonDataResult));
        if (jsonDataResult.length == 0) {
          await prefs.setInt("dataMinggu${prefs.getString("rkChildEmail")}", 0);
        } else {
          var data = jsonDataResult[1]['appUsages'] as List;
          int seconds = 0;
          for (int i = 0; i < data.length; i++) {
            var jsonDt = data[i];
            int sec = jsonDt['duration'];
            seconds = seconds + sec;
          }
          await prefs.setInt("dataMinggu${prefs.getString("rkChildEmail")}", seconds);
        }
      }
    } else {
      print('isi response filter app usage : ${response.statusCode}');
      await prefs.setInt("dataMinggu${prefs.getString("rkChildEmail")}", 0);
    }
  }

  void getListApps() async {
    try {
      List<Application> appData =
          await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: true, onlyAppsWithLaunchIntent: true);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      itemsApp = appData;
      prefs.setString("appsLists", json.encode(itemsApp));
      prefs.commit();

      // return appData;
    } catch (exception) {
      print(exception);
      // return [];
    }
  }

  Future<List<Child>> onLogin() async {
    String token = '';
    await _firebaseMessaging.getToken().then((fcmToken) {
      token = fcmToken!;
    });
    Response response = await MediaRepository().loginParent(prefs.getString(rkEmailUser)!, prefs.getString(accessGToken)!, token, '1.0');
    if (response.statusCode == 200) {
      print("user exist ${response.body}");
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonDataResult = json['resultData'];
        var tokenApps = jsonDataResult['token'];
        await prefs.setString(rkTokenApps, tokenApps);
        var jsonUser = jsonDataResult['user'];
        if (jsonUser != null) {
          List<dynamic> childsData = jsonUser['childs'];
          await prefs.setString(rkUserType, jsonUser['userType']);
          await prefs.setString("rkChildName", childsData[0]['name']);
          await prefs.setString("rkChildEmail", childsData[0]['email']);
          // Iterable l = json.decode(jsonUser['childs']) as List;
          List<Child> data = List<Child>.from(jsonUser['childs'].map((model) => Child.fromJson(model)));
          return data;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } else if (response.statusCode == 404) {
      return [];
    } else {
      return [];
    }
  }

  void onMessageListen() {
    FirebaseMessaging.instance.getInitialMessage().then((value) => {
          if (value != null) {print('remote message ${value.data}')}
        });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      // if(message.data.length > 0) {
      //   flutterLocalNotificationsPlugin.show(
      //       message.data.hashCode,
      //       message.data['title'],
      //       message.data['content'],
      //       NotificationDetails(
      //         android: AndroidNotificationDetails(
      //           channel.id,
      //           channel.name,
      //           channel.description,
      //           // TODO add a proper drawable resource to android, for now using
      //           //      one that already exists in example app.
      //           icon: android?.smallIcon,
      //         ),
      //       ));
      // } else
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name, channel.description,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  icon: 'launch_background',
                  styleInformation: BigTextStyleInformation(notification.body.toString())),
            ));
      }
    });
  }

  void setBindingData() async {
    String token = '';
    await _firebaseMessaging.getToken().then((fcmToken) {
      token = fcmToken!;
    });
    print('fcm $token');
    prefs = await SharedPreferences.getInstance();
    userName = prefs.getString(rkUserName)!;
    emailUser = prefs.getString(rkEmailUser)!;
    if (prefs.getString("rkChildName") != null) {
      childName = prefs.getString("rkChildName")!;
    } else {
      List<User> data = json.decode(prefs.getString(rkChilds)!);
      childName = data[0].name.toString();
      // for(int i = 0; i < jsonChild.length; i++) {
      //   childName = jsonChild[i]['name'];
      // }
    }

    setupYTPlayer(0);
    setState(() {});
  }

  YoutubePlayerController setupYTPlayer(int indeks) {
    _controller = YoutubePlayerController(
      initialVideoId: _ids[indeks],
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;

    return _controller;
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  void onLoadAppIcon() async {
    prefs = await SharedPreferences.getInstance();
    Response response = await MediaRepository().fetchAppIconList();
    if (response.statusCode == 200) {
      print('response load icon ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        var appIcons = json['appIcons'];
        await prefs.setString('rkBaseUrlAppIcon', json['baseUrl']);
        if (appIcons != null) {
          // List<AppIconList> data = List<AppIconList>.from(
          //     appIcons.map((model) => AppIconList.fromJson(model)));
          // String datx = jsonEncode(appIcons);
          await prefs.setString('rkListAppIcons', response.body);
        }
      }
    } else {
      print('response ${response.statusCode}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onLoadAppIcon();
    setBindingData();
    onMessageListen();
    // getUsageStatistik();
    fChildList = onLogin();
  }

  @override
  Widget build(BuildContext context) {
    // ApiResponse apiResponse = Provider.of<MediaViewModel>(context).response;
    // log('response data : $apiResponse');
    final screenSize = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(10.0), //Same as `blurRadius` i guess
            child: ListView.builder(
              padding: EdgeInsets.all(5.0),
              shrinkWrap: false,
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: GestureDetector(
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
                        // child: Center(child: Text('Dummy Card Text', style: TextStyle(color: Colors.black)))
                        child: Image.asset('assets/images/hkbpgo.png'),
                      ),
                    ],
                  ),
                  onTap: () => Get.find<ParentController>().setBottomNavIndex(1),
                ),
              ),
            ),
          ),
        ),
        // Flexible(child: _childDataLayout()),
        Flexible(flex: 2, child: _childDataLayout()),
        Flexible(
          flex: 2,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: _ids.length,
            itemBuilder: (BuildContext context, int position) {
              return Container(
                width: screenSize.width / 2,
                height: screenSize.height / 4,
                color: Colors.transparent,
                margin: const EdgeInsets.all(10),
                child: _coBrandContent(
                  _ids[position],
                  'Title Here',
                  'Content: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                  () {},
                  screenSize.height / 4 / 2,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _coBrandContent(String imagePath, String title, String content, Function onTap, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        image: DecorationImage(
          image: AssetImage('assets/images/$imagePath'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: screenHeight + 50),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(10).copyWith(bottom: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.black54,
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$title',
                    style: TextStyle(fontWeight: FontWeight.bold, color: cOrtuWhite),
                  ),
                  Text(
                    '$content',
                    softWrap: true,
                    style: TextStyle(color: cOrtuWhite),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _childDataLayout() {
    return FutureBuilder<List<Child>>(
        future: fChildList,
        builder: (BuildContext context, AsyncSnapshot<List<Child>> data) {
          if (!data.hasData) return wProgressIndicator();
          if (data.data == null) {
            return Container(
              margin: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0), //Same as `blurRadius` i guess
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: cOrtuGrey,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Buat Akun untuk Anak Anda',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'dekatkan ponsel anak Anda. \nBersama anak Anda,siapkan pengawasan di perangkat mereka',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all((RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) return cDisabled;
                            return cOrtuBlue;
                          },
                        ),
                        elevation: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.disabled) || states.contains(MaterialState.pressed)) return 0;
                          if (states.contains(MaterialState.hovered)) return 6;
                          return 4;
                        }),
                      ),
                      child: Text('DAFTAR',
                          style: TextStyle(
                            color: cPrimaryBg,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          )),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<Object>(builder: (BuildContext context) => SetupInviteChildPage()),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'waktu yang di perlukan sekitar 10 menit',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  //
                ],
              ),
            );
          } else {
            childsList = data.data!;
            if (childsList.length > 0) {
              return ListView.builder(
                shrinkWrap: false,
                scrollDirection: Axis.horizontal,
                itemCount: childsList.length,
                itemBuilder: (BuildContext context, int index) => ChildCardWithBottomSheet(childData: childsList[index], prefs: prefs),
              );
            } else {
              return Center(
                child: Text('No data.'),
              );
            }
          }
        });
  }
}

class ChildCardWithBottomSheet extends StatelessWidget {
  final Child childData;
  final SharedPreferences prefs;
  ChildCardWithBottomSheet({required this.childData, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double paddingValue = 8;

    return Container(
      margin: EdgeInsets.all(paddingValue),
      width: screenSize.width - paddingValue * 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        image: DecorationImage(image: AssetImage('assets/images/foto_anak.png'), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: EdgeInsets.only(right: 4, top: 4),
              // decoration: BoxDecoration(
              //   shape: BoxShape.circle,
              //   color: cPrimaryBg,
              // ),
              child: IconButton(
                color: Colors.black,
                iconSize: 40,
                padding: EdgeInsets.all(0),
                icon: Icon(Icons.add_circle_outline_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<Object>(builder: (BuildContext context) => SetupInviteChildPage()),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.18,
              minChildSize: 0.18,
              maxChildSize: 0.5,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: screenSize.width,
                  child: NotificationListener(
                    onNotification: (OverscrollIndicatorNotification overscroll) {
                      overscroll.disallowGlow();
                      return true;
                    },
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(top: 5),
                              width: screenSize.width / 6,
                              height: 5,
                              decoration: BoxDecoration(color: cOrtuGrey, borderRadius: BorderRadius.all(Radius.circular(15))),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10.0, right: 10),
                            child: Text(
                              '${childData.name}',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                contentTime('Screen Time', '${prefs.getString("averageTime${childData.email}") ?? '00:00'}'),
                                contentTime('Gaming', '00:00'),
                                contentTime('Social Media', '00:00'),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  iconSize: 35,
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.crop_square_outlined,
                                    color: cOrtuBlue,
                                  ),
                                ),
                                IconButton(
                                  iconSize: 35,
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.location_on_outlined,
                                    color: cOrtuBlue,
                                  ),
                                ),
                                IconButton(
                                  iconSize: 35,
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.notifications,
                                    color: cOrtuBlue,
                                  ),
                                ),
                                IconButton(
                                  iconSize: 35,
                                  onPressed: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => DetailChildPage(
                                            title: 'Kontrol dan Konfigurasi', name: '${childData.name}', email: '${childData.email}')));
                                  },
                                  icon: Icon(
                                    Icons.settings,
                                    color: cOrtuBlue,
                                  ),
                                ),
                              ],
                            ),
                          )
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
    );
  }

  Widget contentTime(
    String title,
    String timeValue,
  ) {
    return Container(
      padding: EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            '$timeValue',
            style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
