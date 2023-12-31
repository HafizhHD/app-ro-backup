import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/child/akun/child_akun_page.dart';
import 'package:ruangkeluarga/child/child_controller.dart';
import 'package:ruangkeluarga/child/child_drawer.dart';
import 'package:ruangkeluarga/child/home_child.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/main.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_page.dart';
import 'package:ruangkeluarga/parent/view/jadwal/jadwal_page.dart';
import 'package:ruangkeluarga/utils/background_service_new.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class ChildMain extends StatefulWidget {
  final String childName;
  final String childEmail;
  ChildMain({required this.childName, required this.childEmail});

  @override
  _ChildMainState createState() => _ChildMainState();
}

class _ChildMainState extends State<ChildMain> {
  final controller = Get.find<ChildController>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BackgroundServiceNew.initialize();
    controller.setBottomNavIndex(2);
    controller.initData();
    startServicePlatform();
    startAppUsagePeriodic();
    checkServiceStatus();
    // _requestPermissions();
  }

  /*Future<void> _requestPermissions() async {
    await SystemAlertWindow.requestPermissions(prefMode: prefMode);
  }*/

  static Future<void> startAppUsagePeriodic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int alarmId = 12502;
    try {
      await BackgroundServiceNew.oneShot(
          const Duration(minutes: 5), alarmId, callback,
          wakeup: true,
          exact: true,
          alarmClock: true,
          allowWhileIdle: true,
          rescheduleOnReboot: true);
      await prefs.setBool("isStopServiceLocation", false);
    }
    catch (e) {
      print('Error call alarm data location' + e.toString());
      await prefs.setBool("isStopServiceLocation", true);
    }
  }

  static Future<void> callback() async {
    try {
      print("kirim data usage dan lokasi");
      ChildController controller1 = new ChildController();
      controller1.sendData();
    } catch (e) {
      print("Error alarm location :" + e.toString());
    } finally {
      startAppUsagePeriodic();
    }
  }

  static Future<void> checkServiceStatus() async {
    int alarmId = 12506;
    await BackgroundServiceNew.periodic(const Duration(minutes: 3), alarmId,
        callbackCheckServiceStatus,
        wakeup: true,
        exact: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true);
  }

  static Future<void> callbackCheckServiceStatus() async {
    print("check service status : ${DateTime.now()}");
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isStopService = await prefs.getBool('isStopService');
      print("isStopService = " + isStopService.toString());
      if (isStopService == true) {
        startServicePlatform();
      }
      bool? isStopServiceLocation = await prefs.getBool('isStopServiceLocation');
      print("isStopServiceLocation = " + isStopServiceLocation.toString());
      if (isStopServiceLocation == true) {
        startAppUsagePeriodic();
      }
    } catch (e) {
      print("Error Callback Check Service Status :" + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuTitle = ['Discover', 'Add-On', 'Home', 'Jadwal', 'Akun', 'Forum'];
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
                  showFAQ();
                },
                icon: Icon(
                  Icons.help,
                  color: cOrtuWhite,
                ),
              )
            ],
          ),
          // drawer: ChildDrawer(widget.childName, widget.childEmail),
          body: Obx(() => ChosenPage(
              bottomNavIndex: controller.bottomNavIndex,
              emailUser: controller.childEmail)),
          bottomNavigationBar: _bottomAppBar(),
          // floatingActionButton: Visibility(
          //   visible: !showKeyboard(context),
          //   child: SizedBox(
          //     height: 80,
          //     width: 80,
          //     child: FloatingActionButton(
          //       elevation: 0,
          //       backgroundColor:
          //           controller.bottomNavIndex == 2 ? cOrtuOrange : cAsiaBlue,
          //       child: Container(
          //         margin: EdgeInsets.all(8),
          //         decoration: BoxDecoration(
          //           image: DecorationImage(
          //             image: AssetImage(currentAppIconPath),
          //             fit: BoxFit.contain,
          //           ),
          //         ),
          //       ),
          //       onPressed: () => setState(() {
          //         controller.setBottomNavIndex(2);
          //       }),
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
                defaultIcon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book,
                label: 'Discover',
                isSelected: controller.bottomNavIndex == 0,
                onPressed: () => setState(() {
                      controller.setBottomNavIndex(0);
                    })),
            // IconWithLabel(
            //     defaultIcon: Icons.cloud_download_outlined,
            //     activeIcon: Icons.cloud_download,
            //     label: 'Addon',
            //     isSelected: controller.bottomNavIndex == 1,
            //     onPressed: () => controller.setBottomNavIndex(1)),
            IconWithLabel(
                defaultIcon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isSelected: controller.bottomNavIndex == 2,
                onPressed: () => setState(() {
                      controller.setBottomNavIndex(2);
                    })),
            // SizedBox(width: Get.width / 5), // The dummy child
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
        return new FeedPage(emailUser, 'child');
      case 1:
      // return new AddonPage();
      case 2:
        return new HomeChild();
      case 3:
        return new JadwalPage();
      case 4:
        return new ChildAkunPage();
      default:
        return new HomeChild();
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
