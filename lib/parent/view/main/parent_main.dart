import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/main.dart';
import 'package:ruangkeluarga/parent/view/addon/addon_page.dart';
import 'package:ruangkeluarga/parent/view/akun/akun_page.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_page.dart';
import 'package:ruangkeluarga/parent/view/home_parent.dart';
import 'package:ruangkeluarga/parent/view/inbox/inbox_page.dart';
import 'package:ruangkeluarga/parent/view/jadwal/jadwal_page.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/parent/view/main/parent_drawer.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruangkeluarga/forum/forum_main.dart';

import '../../../global/help_page.dart';

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

class ParentMain extends StatefulWidget {
  @override
  _ParentMainState createState() => _ParentMainState();
}

class _ParentMainState extends State<ParentMain> {
  final controller = Get.find<ParentController>();
  late SharedPreferences prefs;

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
      //           // TODO add a proper drawable resource to android, for now using one that already exists in example app.
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
              android: AndroidNotificationDetails(channel.id, channel.name,
                  channelDescription: channel.description,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  icon: 'launch_background',
                  styleInformation:
                      BigTextStyleInformation(notification.body.toString())),
            ));
      }
    });
  }

  void getUsageStatistik() async {
    prefs = await SharedPreferences.getInstance();
    var outputFormat = DateFormat('yyyy-MM-dd');
    var outputDate = outputFormat.format(DateTime.now());
    Response response = await MediaRepository().fetchAppUsageFilter(
        prefs.getString("rkChildEmail").toString(), outputDate);
    if (response.statusCode == 200) {
      // print('isi response filter app usage : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonDataResult = json['appUsages'] as List;
        await prefs.setString("childAppUsage", jsonEncode(jsonDataResult));
        if (jsonDataResult.length == 0) {
        } else {
          var data = jsonDataResult[0]['appUsages'] as List;
          int seconds = 0;
          for (int i = 0; i < data.length; i++) {
            var jsonDt = data[i];
            int sec = jsonDt['duration'];
            seconds = seconds + sec;
          }
        }
      }
    } else {
      // print('isi response filter app usage : ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    controller.loginData();
    controller.getAppIconList();
    controller.setBottomNavIndex(0);
    controller.getBinding();
    onMessageListen();
    getUsageStatistik();
  }

  @override
  Widget build(BuildContext context) {
    final menuTitle = [ 'Home', 'Discover', 'Inbox', 'Jadwal', 'Akun'];
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => onWillCloseApp(),
        child: Scaffold(
          backgroundColor: cPrimaryBg,
          appBar: AppBar(
            title: Text(menuTitle[controller.bottomNavIndex]),
            elevation: 0,
            backgroundColor: cTopBg,
            iconTheme: IconThemeData(color: cOrtuWhite),
            actions: <Widget>[
              // IconButton(
              //   onPressed: () {},
              //   icon: Icon(
              //     Icons.notifications,
              //     color: cOrtuText,
              //   ),
              // ),
              // IconButton(
              //   onPressed: () {},
              //   icon: Icon(
              //     Icons.mail_outline,
              //     color: cOrtuText,
              //   ),
              // ),
              IconButton(
                onPressed: () {
                  // showFAQ();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpPage()),
                  );
                },
                icon: Icon(
                  Icons.help,
                  color: cOrtuWhite,
                ),
              )
            ],
          ),
          // drawer: ParentDrawer(
          //     userMail: controller.emailUser, userName: controller.userName),
          body: Obx(() => ChosenPage(
              bottomNavIndex: controller.bottomNavIndex,
              emailUser: controller.emailUser)),
          bottomNavigationBar: _bottomAppBar(),
          // floatingActionButton: Visibility(
          //   visible: !showKeyboard(context),
          //   child: SizedBox(
          //     height: 70,
          //     width: 70,
          //     child: Obx(
          //       () => FloatingActionButton(
          //           elevation: 0,
          //           backgroundColor: controller.bottomNavIndex == 2
          //               ? cOrtuOrange
          //               : cAsiaBlue,
          //           child: Container(
          //             margin: EdgeInsets.all(8),
          //             decoration: BoxDecoration(
          //               image: DecorationImage(
          //                 image: AssetImage(currentAppIconPath),
          //                 fit: BoxFit.contain,
          //               ),
          //             ),
          //           ),
          //           onPressed: () => setState(() {
          //                 controller.setBottomNavIndex(2);
          //               })),
          //     ),
          //   ),
          // ),
          // floatingActionButtonLocation:
          //     FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
  }

  Widget _bottomAppBar() {
    return Obx(
      () => BottomAppBar(
        elevation: 0,
        color: cAsiaBlue,
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconWithLabel(
        defaultIcon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            isSelected: controller.bottomNavIndex == 0,
            onPressed: () => setState(() {
              controller.setBottomNavIndex(0);
            })),
            Obx(
              () => Badge(
                position: BadgePosition.topEnd(end: 5),
                showBadge: controller.unreadNotif > 0 ? true : false,
                badgeContent: Text(
                  controller.unreadNotif > 99
                      ? '99+'
                      : controller.unreadNotif.toString(),
                  style: TextStyle(fontSize: 10),
                ),
                child: IconWithLabel(
                    defaultIcon: Icons.mail_outline,
                    activeIcon: Icons.mail,
                    label: 'Inbox',
                    isSelected: controller.bottomNavIndex == 1,
                    onPressed: () => setState(() {
                          controller.setBottomNavIndex(1);
                        })),
              ),
            ),
            IconWithLabel(
                defaultIcon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book,
                label: 'Discover',
                isSelected: controller.bottomNavIndex == 2,
                onPressed: () => setState(() {
                  controller.setBottomNavIndex(2);
                })),
            // IconWithLabel(
            //     defaultIcon: Icons.calendar_today_outlined,
            //     activeIcon: Icons.calendar_today,
            //     label: 'Jadwal',
            //     isSelected: controller.bottomNavIndex == 3,
            //     onPressed: () => controller.setBottomNavIndex(3)),
            IconWithLabel(
                defaultIcon: Icons.person_outlined,
                activeIcon: Icons.person,
                label: 'Akun',
                isSelected: controller.bottomNavIndex == 4,
                onPressed: () => setState(() {
                      controller.setBottomNavIndex(4);
                    })),
            // onPressed: () => showFAQ()),
          ],
        ),
      ),
    );
  }
}

class ChosenPage extends StatelessWidget {
  final bottomNavIndex;
  final String emailUser;
  ChosenPage({this.bottomNavIndex, required this.emailUser});

  @override
  Widget build(BuildContext context) {
    switch (bottomNavIndex) {
      case 0:
        return new HomeParentPage();
      case 2:
        return new FeedPage(emailUser, 'parent');
      case 1:
        // Get.find<ParentController>().getInboxNotif();
        return new InboxPage();
      // return new AddonPage();
      case 3:
        return new JadwalPage();
      case 4:
        return new AkunPage();
      default:
        return new HomeParentPage();
    }
  }
}

class IconWithLabel extends StatelessWidget {
  final IconData activeIcon;
  final IconData defaultIcon;
  final Color activeColor;
  final Color defaultColor;
  final String label;
  final bool isSelected;
  final Function()? onPressed;

  IconWithLabel({
    required this.activeIcon,
    required this.defaultIcon,
    required this.label,
    required this.onPressed,
    this.defaultColor: cOrtuWhite,
    this.activeColor: cOrtuOrange,
    this.isSelected: false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: MediaQuery.of(context).size.width / 6,
          margin: EdgeInsets.all(2),
          padding: EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                  child: Icon(isSelected ? activeIcon : defaultIcon,
                      color: isSelected ? activeColor : defaultColor)),
              SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: isSelected ? activeColor : defaultColor,
                      fontSize: 12))
            ],
          ),
        ),
      ),
    );
  }
}
