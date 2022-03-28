import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/child/child_controller.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/utils/base_service/service_controller.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';

class ChildDrawer extends StatelessWidget {
  final String childName;
  final String childEmail;
  ChildDrawer(this.childName, this.childEmail);

  final childCtrl = Get.find<ChildController>();
  final appInfo = Get.find<RKServiceController>().appInfo;

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
                                '$childName',
                                style:
                                    TextStyle(color: cOrtuText, fontSize: 18),
                              ),
                            ),
                          ),
                          Container(
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                '$childEmail',
                                style: TextStyle(color: cOrtuText),
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
                    childCtrl.setBottomNavIndex(1);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Profil'),
                  leading: Icon(Icons.person, color: Colors.black),
                  onTap: () {
                    childCtrl.setBottomNavIndex(4);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('SOS'),
                  leading: Icon(Icons.add_ic_call, color: Colors.black),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('FAQ'),
                  leading: Icon(Icons.help, color: Colors.black),
                  onTap: () {
                    showFAQ();
                    // Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Kebijakan Privasi'),
                  leading: Icon(Icons.privacy_tip, color: Colors.black),
                  onTap: () {
                    showPrivacyPolicy();
                  },
                ),
                // ListTile(
                //     title: Text('Keluar'),
                //     leading: Icon(Icons.exit_to_app_outlined, color: Colors.black),
                //     onTap: () => showDialog<String>(
                //         context: context,
                //         builder: (BuildContext context) => AlertDialog(
                //               title: const Text('Konfirmasi'),
                //               content: const Text('Apakah anda yakin ingin keluar aplikasi ?'),
                //               actions: <Widget>[
                //                 TextButton(
                //                   onPressed: () => Navigator.pop(context, 'Cancel'),
                //                   child: const Text('Cancel', style: TextStyle(color: cOrtuBlue)),
                //                 ),
                //                 TextButton(
                //                   onPressed: () async {
                //                     showLoadingOverlay();
                //                     SharedPreferences prefs = await SharedPreferences.getInstance();
                //                     await prefs.clear();
                //                     await signOutGoogle();
                //                     closeOverlay();
                //                     Navigator.pushAndRemoveUntil(
                //                       context,
                //                       MaterialPageRoute(builder: (builder) => MyHomePage()),
                //                       (route) => false,
                //                     );
                //                   },
                //                   child: const Text('OK', style: TextStyle(color: cOrtuBlue)),
                //                 ),
                //               ],
                //             ))),
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
