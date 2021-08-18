import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/main.dart';
import 'package:ruangkeluarga/parent/view/invite_more_child.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentDrawer extends StatelessWidget {
  final userName;
  final userMail;

  ParentDrawer({this.userMail, this.userName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            leading: Icon(Icons.show_chart, color: Colors.black),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              // Update the state of the app
            },
          ),
          ListTile(
            title: Text('Addon'),
            leading: Icon(Icons.cloud_download_outlined, color: Colors.black),
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
                            onPressed: () async {
                              showLoadingOverlay();
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.clear();
                              closeOverlay();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (builder) => MyHomePage()),
                                (route) => false,
                              );
                            },
                            child: const Text('OK', style: TextStyle(color: Color(0xff05745F))),
                          ),
                        ],
                      )))
        ],
      ),
    );
  }
}
