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
    // _requestPermissions();
  }

  /*Future<void> _requestPermissions() async {
    await SystemAlertWindow.requestPermissions(prefMode: prefMode);
  }*/

  static Future<void> startAppUsagePeriodic() async {
    await BackgroundServiceNew.oneShot(
      const Duration(minutes: 3),
      12302,
      callback,
      wakeup: true,
      exact: true,
      rescheduleOnReboot: true
    );
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => onWillCloseApp(),
        child: Scaffold(
          backgroundColor: cPrimaryBg,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: cPrimaryBg,
            iconTheme: IconThemeData(color: cOrtuWhite),
            actions: <Widget>[
              // IconButton(
              //   onPressed: () {},
              //   icon: Icon(
              //     Icons.notifications,
              //     color: cOrtuWhite,
              //   ),
              // ),
              // IconButton(
              //   onPressed: () {},
              //   icon: Icon(
              //     Icons.mail_outline,
              //     color: cOrtuWhite,
              //   ),
              // ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.help,
                  color: cOrtuWhite,
                ),
              )
            ],
          ),
          drawer: ChildDrawer(widget.childName, widget.childEmail),
          body:
              Obx(() => ChosenPage(bottomNavIndex: controller.bottomNavIndex)),
          bottomNavigationBar: _bottomAppBar(),
          floatingActionButton: Visibility(
            visible: !showKeyboard(context),
            child: SizedBox(
              height: 80,
              width: 80,
              child: FloatingActionButton(
                elevation: 0,
                backgroundColor: controller.bottomNavIndex == 2
                    ? Colors.blueGrey
                    : Colors.black54,
                child: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(currentAppIconPath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                onPressed: () => controller.setBottomNavIndex(2),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
  }

  Widget _bottomAppBar() {
    return Obx(
      () => BottomAppBar(
        elevation: 0,
        color: Colors.black54,
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconWithLabel(
                defaultIcon: Icons.home_outlined,
                activeIcon: Icons.home_filled,
                label: 'Discover',
                isSelected: controller.bottomNavIndex == 0,
                onPressed: () => controller.setBottomNavIndex(0)),
            // IconWithLabel(
            //     defaultIcon: Icons.cloud_download_outlined,
            //     activeIcon: Icons.cloud_download,
            //     label: 'Addon',
            //     isSelected: controller.bottomNavIndex == 1,
            //     onPressed: () => controller.setBottomNavIndex(1)),
            // IconWithLabel(
            //     defaultIcon: Icons.mail_outline,
            //     activeIcon: Icons.mail,
            //     label: 'Addon',
            //     isSelected: controller.bottomNavIndex == 1,
            //     onPressed: () => controller.setBottomNavIndex(1)),
            SizedBox(width: Get.width / 5), // The dummy child
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
                onPressed: () => controller.setBottomNavIndex(4)),
          ],
        ),
      ),
    );
  }
}

class ChosenPage extends StatelessWidget {
  final bottomNavIndex;
  ChosenPage({this.bottomNavIndex});

  @override
  Widget build(BuildContext context) {
    switch (bottomNavIndex) {
      case 0:
        return new FeedPage();
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
    this.activeColor: cOrtuBlue,
    this.isSelected: false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        child: Container(
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
                  style:
                      TextStyle(color: isSelected ? activeColor : defaultColor))
            ],
          ),
        ),
      ),
    );
  }
}
