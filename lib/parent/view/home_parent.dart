import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:http/http.dart';
import 'package:ruangkeluarga/main.dart';
import 'package:ruangkeluarga/model/rk_child_app_icon_list.dart';
import 'package:ruangkeluarga/model/rk_child_model.dart';
import 'package:ruangkeluarga/model/rk_user_model.dart';
import 'package:ruangkeluarga/parent/view/detail_child_view.dart';
import 'package:ruangkeluarga/parent/view/detail_content_rk_view.dart';
import 'package:ruangkeluarga/parent/view/invite_more_child.dart';
import 'package:ruangkeluarga/plugin_device_app.dart';
import 'package:ruangkeluarga/utils/app_usage.dart';
import 'package:ruangkeluarga/utils/constant.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class HomeParent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ruang keluarga',
      theme: ThemeData(primaryColor: Colors.white70),
      home: HomeParentPage(title: 'ruang keluarga'),
    );
  }
}

class HomeParentPage extends StatefulWidget {
  HomeParentPage({Key? key, required this.title}) : super(key: key);

  final String title;

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
  String childName = '';
  String userName = '';
  String emailUser = '';

  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;

  final List<String> _ids = [
    'b0BpTqKBG_8',
    'n7jmC4RRD2A',
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
  }

  @override
  Widget build(BuildContext context) {
    // ApiResponse apiResponse = Provider.of<MediaViewModel>(context).response;
    // log('response data : $apiResponse');
    FlutterStatusbarcolor.setStatusBarColor(Color(0xff05745F));
    return Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "ruang",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 18),
                  ),
                  Text(
                    " keluarga",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffFF018786), fontSize: 18),
                  )
                ],
              ),
            ],
          ),
          backgroundColor: Colors.white70,
          iconTheme: IconThemeData(color: Colors.grey.shade700),
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications,
                color: Colors.grey.shade700,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.mail_outline,
                color: Colors.grey.shade700,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.help,
                color: Colors.grey.shade700,
              ),
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
// Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff3BDFD2),
                      Color(0xff05745F),
                    ],
                  )),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              '$userName',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                        Container(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              '$emailUser',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
              ListTile(
                title: Text('Home'),
                leading: Icon(Icons.home_filled, color: Colors.black),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Profil'),
                leading: Icon(Icons.person, color: Colors.black),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Statistik Penggunaan'),
                leading: Icon(Icons.supervised_user_circle, color: Colors.black),
                onTap: () {
                  // Then close the drawer
                  Navigator.pop(context);
                  // Update the state of the app
                },
              ),
              ListTile(
                title: Text('Addon'),
                leading: Icon(Icons.supervised_user_circle, color: Colors.black),
                onTap: () {
                  // Then close the drawer
                  Navigator.pop(context);
                  // Update the state of the app
                },
              ),
              ListTile(
                title: Text('Child'),
                leading: Icon(Icons.supervised_user_circle, color: Colors.black),
                onTap: () {
                  // Then close the drawer
                  Navigator.pop(context);
                  // Update the state of the app
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => InviteMoreChildPage(title: 'ruang keluarga')));
                },
              ),
              ListTile(
                title: Text('FAQ'),
                leading: Icon(Icons.help, color: Colors.black),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Kebijakan Privasi'),
                leading: Icon(Icons.privacy_tip, color: Colors.black),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Tentang'),
                leading: Icon(Icons.info, color: Colors.black),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                  title: Text('Keluar'),
                  leading: Icon(Icons.exit_to_app_outlined, color: Colors.black),
                  onTap: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: const Text('Konfirmasi'),
                            content: const Text('Apakah anda yakin ingin keluar aplikasi ?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel', style: TextStyle(color: Color(0xff05745F))),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'OK'),
                                child: const Text('OK', style: TextStyle(color: Color(0xff05745F))),
                              ),
                            ],
                          )))
            ],
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
                child: Column(children: <Widget>[
              Container(
                height: 170.0,
                margin: const EdgeInsets.all(10.0), //Same as `blurRadius` i guess
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 3.0,
                    ),
                  ],
                ),
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
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
                            // child: Center(child: Text('Dummy Card Text', style: TextStyle(color: Colors.black)))
                            child: Image.asset('assets/images/ic_digital_parenting_one.png'),
                          ),
                        ],
                      ),
                      onTap: () => {Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailContentRKPage(title: 'Detil Konten')))},
                    ),
                  ),
                ),
              ),
              Container(
                height: 250.0,
                margin: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0), //Same as `blurRadius` i guess
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 3.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              child: Row(
                            children: [
                              Container(
                                child: Icon(
                                  Icons.supervised_user_circle,
                                  size: 24.0,
                                  semanticLabel: 'Text to announce in accessibility modes',
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10.0),
                                child: Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Aktifitas',
                                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        ' Anak',
                                        style: TextStyle(color: Color(0xffFF018786), fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )),
                          GestureDetector(
                            child: Container(
                                child: Container(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Tambah Anak',
                                  style: TextStyle(color: Color(0xffFF018786), fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => InviteMoreChildPage(title: 'ruang keluarga')));
                            },
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                      height: 195,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.white),
                      child: _childDataLayout(),
                    )
                  ],
                ),
              ),
              Container(
                height: 400,
                margin: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0), //Same as `blurRadius` i guess
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 3.0,
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int position) {
                    return Container(
                      height: 200,
                      margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                      child: YoutubePlayerBuilder(
                        player: YoutubePlayer(
                          controller: setupYTPlayer(position),
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.blueAccent,
                          topActions: <Widget>[
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                _controller.metadata.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 25.0,
                              ),
                              onPressed: () {
                                log('Settings Tapped!');
                              },
                            ),
                          ],
                          onReady: () {
                            _isPlayerReady = true;
                          },
                          onEnded: (data) {
                            _controller.load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
                            // _showSnackBar('Next Video Started!');
                          },
                        ),
                        builder: (context, player) => Scaffold(
                          body: ListView(
                            children: [
                              player,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: _ids.length,
                ),
              ),
              /*Container(
                  margin: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0), //Same as `blurRadius` i guess
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 3.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        margin: const EdgeInsets.all(10.0), //Same as `blurRadius` i guess
                        child: YoutubePlayerBuilder(
                          player: YoutubePlayer(
                            controller: _controller,
                            showVideoProgressIndicator: true,
                            progressIndicatorColor: Colors.blueAccent,
                            topActions: <Widget>[
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  _controller.metadata.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                                onPressed: () {
                                  log('Settings Tapped!');
                                },
                              ),
                            ],
                            onReady: () {
                              _isPlayerReady = true;
                            },
                            onEnded: (data) {
                              _controller
                                  .load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
                              // _showSnackBar('Next Video Started!');
                            },
                          ),
                          builder: (context, player) => Scaffold(
                            body: ListView(
                              children: [
                                player,
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),*/
            ])),
            // SlidingUpPanel(
            //   renderPanelSheet: false,
            //   backdropEnabled: true,
            //   minHeight: 130,
            //   parallaxEnabled: true,
            //   parallaxOffset: .5,
            //   maxHeight: MediaQuery.of(context).size.height,
            //   borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
            //   // panel: _floatingPanel(),
            //   panelBuilder: (ScrollController sc) => _scrollingList(sc),
            //   collapsed: _floatingCollapsed(),
            //   onPanelSlide: (position) => {
            //     _changed(position)
            //   },
            // ),
          ],
        ));
  }

  Widget get _space => const SizedBox(height: 10);

  Color _getStateColor(PlayerState state) {
    switch (state) {
      case PlayerState.unknown:
        return Colors.grey[700]!;
      case PlayerState.unStarted:
        return Colors.pink;
      case PlayerState.ended:
        return Colors.red;
      case PlayerState.playing:
        return Colors.blueAccent;
      case PlayerState.paused:
        return Colors.orange;
      case PlayerState.buffering:
        return Colors.yellow;
      case PlayerState.cued:
        return Colors.blue[900]!;
      default:
        return Colors.blue;
    }
  }

  Widget _text(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '$title : ',
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _childDataLayout() {
    return FutureBuilder<List<Child>>(
        future: onLogin(),
        builder: (BuildContext context, AsyncSnapshot<List<Child>> data) {
          if (data.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            childsList = data.data!;
            if (childsList.length > 0) {
              return ListView.builder(
                shrinkWrap: false,
                scrollDirection: Axis.horizontal,
                itemCount: childsList.length,
                itemBuilder: (BuildContext context, int index) => Card(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.88,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.all(10.0),
                              child: Align(
                                child: Text(
                                  '${childsList[index].name}',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(10.0),
                              child: Align(
                                child: Text(
                                  'Screen Time : ${prefs.getString("averageTime${childsList[index].email}") ?? '-'}',
                                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            /*Container(
                            margin: EdgeInsets.only(left: 20.0, right: 10.0),
                            child: Text(
                              'Skor Sekarang',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20.0, right: 10.0, top: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Screen Time',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Games',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20.0, right: 10.0, top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Media Sosial',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Lokasi',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),*/
                            GestureDetector(
                              child: Container(
                                margin: EdgeInsets.only(left: 20.0, right: 10.0, top: 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: Text(
                                        'Lihat selengkapnya',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 20.0),
                                      child: Icon(
                                        Icons.keyboard_arrow_right_rounded,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () => {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => DetailChildPage(
                                        title: 'Kontrol dan Konfigurasi', name: '${childsList[index].name}', email: '${childsList[index].email}')))
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: Text('No data.'),
              );
            }
          }
        });
  }

  Widget _floatingCollapsed() {
    return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 3.0,
            ),
          ],
        ),
        margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 30.0),
        child: Container(
          child: Stack(
            children: <Widget>[
              SizedBox(
                height: 12.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 5,
                    margin: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(color: Colors.grey[500], borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  ),
                ],
              ),
              Container(
                height: 70,
                margin: EdgeInsets.only(top: 25.0, left: 25.0, right: 10.0, bottom: 10.0),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12.0))),
                child: ListView.builder(
                  shrinkWrap: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) => Container(
                      margin: EdgeInsets.only(left: 5.0, right: 5.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                              width: 70,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50.0), border: Border.all(width: 0.2, color: Colors.grey), color: Colors.white),
                              child: Center(child: Image.asset('assets/images/person.png', width: 40, height: 40))),
                        ],
                      )),
                ),
              )
            ],
          ),
        ));
  }

  Widget _floatingPanel() {
    return AnimatedOpacity(
      opacity: _opacity,
      onEnd: () {
        if (_opacity > 0.02) {
          WidgetsBinding.instance!.addPostFrameCallback((_) => _isVisibleChange(true));
        } else {
          WidgetsBinding.instance!.addPostFrameCallback((_) => _isVisibleChange(false));
        }
      },
      duration: const Duration(seconds: 0),
      child: Visibility(
          visible: flag,
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.0))),
            child: Container(
              child: Stack(
                children: <Widget>[
                  SizedBox(
                    height: 12.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 5,
                        margin: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(color: Colors.grey[500], borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: 120,
                        margin: EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0, bottom: 10.0),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12.0))),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 10.0, left: 15.0, right: 10.0, bottom: 10.0),
                              child: Text(
                                'My AddOn',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 35.0, left: 10.0, right: 10.0, bottom: 5.0),
                              child: ListView.builder(
                                shrinkWrap: false,
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                itemBuilder: (BuildContext context, int index) => Card(
                                    child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                        width: 80,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.white),
                                        child: Center(child: Image.asset('assets/images/person.png', width: 50, height: 50))),
                                  ],
                                )),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 120,
                        margin: EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0, bottom: 10.0),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12.0))),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 10.0, left: 15.0, right: 10.0, bottom: 10.0),
                              child: Text(
                                'My AddOn',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 35.0, left: 10.0, right: 10.0, bottom: 5.0),
                              child: ListView.builder(
                                shrinkWrap: false,
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                itemBuilder: (BuildContext context, int index) => Card(
                                    child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                        width: 80,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.white),
                                        child: Center(child: Image.asset('assets/images/person.png', width: 50, height: 50))),
                                  ],
                                )),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 120,
                        margin: EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0, bottom: 10.0),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12.0))),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 10.0, left: 15.0, right: 10.0, bottom: 10.0),
                              child: Text(
                                'My AddOn',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 35.0, left: 10.0, right: 10.0, bottom: 5.0),
                              child: ListView.builder(
                                shrinkWrap: false,
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                itemBuilder: (BuildContext context, int index) => Card(
                                    child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                        width: 80,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.white),
                                        child: Center(child: Image.asset('assets/images/person.png', width: 50, height: 50))),
                                  ],
                                )),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 120,
                        margin: EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0, bottom: 10.0),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12.0))),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 10.0, left: 15.0, right: 10.0, bottom: 10.0),
                              child: Text(
                                'My AddOn',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 35.0, left: 10.0, right: 10.0, bottom: 5.0),
                              child: ListView.builder(
                                shrinkWrap: false,
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                itemBuilder: (BuildContext context, int index) => Card(
                                    child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                        width: 80,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.white),
                                        child: Center(child: Image.asset('assets/images/person.png', width: 50, height: 50))),
                                  ],
                                )),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 120,
                        margin: EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0, bottom: 10.0),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12.0))),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 10.0, left: 15.0, right: 10.0, bottom: 10.0),
                              child: Text(
                                'My AddOn',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 35.0, left: 10.0, right: 10.0, bottom: 5.0),
                              child: ListView.builder(
                                shrinkWrap: false,
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                itemBuilder: (BuildContext context, int index) => Card(
                                    child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                        width: 80,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.white),
                                        child: Center(child: Image.asset('assets/images/person.png', width: 50, height: 50))),
                                  ],
                                )),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _scrollingList(ScrollController sc) {
    return AnimatedOpacity(
      opacity: _opacity,
      onEnd: () {
        if (_opacity > 0.02) {
          WidgetsBinding.instance!.addPostFrameCallback((_) => _isVisibleChange(true));
        } else {
          WidgetsBinding.instance!.addPostFrameCallback((_) => _isVisibleChange(false));
        }
      },
      duration: const Duration(seconds: 0),
      child: Visibility(
          visible: flag,
          child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Container(
                margin: EdgeInsets.only(top: 10.0, bottom: 100.0),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.0))),
                child: ListView.builder(
                  controller: sc,
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int i) {
                    return Container(
                      child: Stack(
                        children: <Widget>[
                          Column(
                            children: [
                              Container(
                                height: 125,
                                margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(top: 10.0, left: 15.0, right: 10.0, bottom: 10.0),
                                      child: Text(
                                        'My AddOn',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0, bottom: 5.0),
                                      child: ListView.builder(
                                        shrinkWrap: false,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 1,
                                        itemBuilder: (BuildContext context, int index) => Card(
                                            child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                                width: 80,
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.white),
                                                child: Center(child: Image.asset('assets/images/person.png', width: 50, height: 50))),
                                          ],
                                        )),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ))),
    );
  }

  /*Widget getMediaWidget(BuildContext context, ApiResponse apiResponse) {
    List<Media>? mediaList = apiResponse.data as List<Media>?;
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 8,
              child: PlayerListWidget(mediaList!, (Media media) {
                Provider.of<MediaViewModel>(context, listen: false)
                    .setSelectedMedia(media);
              }),
            )
          ],
        );
      case Status.ERROR:
        return Center(
          child: Text('Please try again latter!!!'),
        );
      case Status.INITIAL:
      default:
        return Center(
          // child: Text('Search the song by Artist'),
        );
    }
  }*/
}
