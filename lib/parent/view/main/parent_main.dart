import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/addon/addon_page.dart';
import 'package:ruangkeluarga/parent/view/akun/akun_page.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_page.dart';
import 'package:ruangkeluarga/parent/view/home_parent.dart';
import 'package:ruangkeluarga/parent/view/jadwal/jadwal_page.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/parent/view/main/parent_drawer.dart';

class ParentMain extends StatelessWidget {
  final controller = Get.find<ParentController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => onWillPopApp(),
        child: Scaffold(
          backgroundColor: cPrimaryBg,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: cPrimaryBg,
            iconTheme: IconThemeData(color: cOrtuWhite),
            actions: <Widget>[
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications,
                  color: cOrtuWhite,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.mail_outline,
                  color: cOrtuWhite,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.help,
                  color: cOrtuWhite,
                ),
              )
            ],
          ),
          drawer: ParentDrawer(userMail: controller.emailUser, userName: controller.userName),
          body: Obx(() => ChosenPage(bottomNavIndex: controller.bottomNavIndex)),
          bottomNavigationBar: _bottomAppBar(),
          floatingActionButton: SizedBox(
            height: 80,
            width: 80,
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: Colors.black54,
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
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                label: 'Home',
                isSelected: controller.bottomNavIndex == 0,
                onPressed: () => controller.setBottomNavIndex(0)),
            IconWithLabel(
                defaultIcon: Icons.cloud_download_outlined,
                activeIcon: Icons.cloud_download,
                label: 'Addon',
                isSelected: controller.bottomNavIndex == 1,
                onPressed: () => controller.setBottomNavIndex(1)),
            SizedBox(width: 40), // The dummy child
            IconWithLabel(
                defaultIcon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Jadwal',
                isSelected: controller.bottomNavIndex == 3,
                onPressed: () => controller.setBottomNavIndex(3)),
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
        return new HomeParentPage();
      case 1:
        return new AddonPage();
      case 2:
        return new FeedPage();
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
              Flexible(child: Icon(isSelected ? activeIcon : defaultIcon, color: isSelected ? activeColor : defaultColor)),
              SizedBox(height: 4),
              Text(label, style: TextStyle(color: isSelected ? activeColor : defaultColor))
            ],
          ),
        ),
      ),
    );
  }
}
