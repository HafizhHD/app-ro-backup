import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/login/login.dart';
import 'package:ruangkeluarga/main.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/utils/base_service/service_controller.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentDrawer extends StatelessWidget {
  final userName;
  final userMail;
  final controller = Get.find<ParentController>();
  final appInfo = Get.find<RKServiceController>().appInfo;

  ParentDrawer({this.userMail, this.userName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cOrtuGrey,
                        cPrimaryBg,
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
                                '$userMail',
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
                    controller.setBottomNavIndex(2);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Akun'),
                  leading: Icon(Icons.person, color: Colors.black),
                  onTap: () {
                    controller.setBottomNavIndex(4);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Statistik Penggunaan'),
                  leading: Icon(Icons.show_chart, color: Colors.black),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                // ListTile(
                //   title: Text('Addon'),
                //   leading: Icon(Icons.cloud_download_outlined, color: Colors.black),
                //   onTap: () {
                //     // Then close the drawer
                //     controller.setBottomNavIndex(1);
                //     Navigator.pop(context);
                //     // Update the state of the app
                //   },
                // ),
                // ListTile(
                //   title: Text('Child'),
                //   leading: Icon(Icons.supervised_user_circle, color: Colors.black),
                //   onTap: () {
                //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => SetupInviteChildPage()));
                //   },
                // ),
                ListTile(
                  title: Text('FAQ'),
                  leading: Icon(Icons.help, color: Colors.black),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Kebijakan Privasi'),
                  leading: Icon(Icons.privacy_tip, color: Colors.black),
                  onTap: () {
                    showPrivacyPolicy();
                  },
                ),
                ListTile(
                  title: Text('Keluar'),
                  leading: Icon(Icons.exit_to_app_outlined, color: Colors.black),
                  onTap: () => logUserOut(),
                )
              ],
            ),
          ),
          ListTile(
            title: Text('Versi  ${appInfo.version}'),
            leading: Icon(Icons.info, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
