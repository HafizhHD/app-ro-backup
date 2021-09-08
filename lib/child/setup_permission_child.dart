import 'dart:convert';

import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:ruangkeluarga/child/home_child.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupPermissionChildPage extends StatefulWidget {
  SetupPermissionChildPage({Key? key, required this.email, required this.name}) : super(key: key);

  final String email;
  final String name;
  @override
  _SetupPermissionChildPageState createState() => _SetupPermissionChildPageState();
}

class _SetupPermissionChildPageState extends State<SetupPermissionChildPage> {
  bool _serviceAppUsage = false;
  bool _locationPermission = false;
  bool _contactPermission = false;

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Aplikasi ruang keluar membutuhkan akses anda untuk dapat berjalan dengan baik.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void initAsync() async {
    _locationPermission = (await Permission.location.status).isGranted;
    _contactPermission = (await Permission.contacts.status).isGranted;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: cPrimaryBg,
          body: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10.0, left: 20.0, right: 10.0),
                    height: 80,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${widget.name}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cOrtuWhite),
                          ),
                          Flexible(
                            child: Text(
                              'Aplikasi RuangOrtu memerlukan beberapa ijin untuk mengakses data yang dibutuhkan:',
                              style: TextStyle(fontSize: 16, color: cOrtuWhite),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Flexible(child: checkAllPermission()),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: FlatButton(
                      height: 50,
                      minWidth: 300,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                      ),
                      onPressed: () async {
                        if (_locationPermission && _contactPermission && _serviceAppUsage) {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context) => HomeChildPage(title: 'ruang keluarga', email: widget.email, name: widget.name)));
                        } else {
                          _showMyDialog();
                        }
                      },
                      color: cOrtuBlue,
                      child: Text(
                        "LANJUT KE HOME",
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }

  Widget checkAllPermission() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile.adaptive(
            tileColor: cOrtuGrey,
            title: Text('Kontak'),
            subtitle: Text('Kami membutuhkan akses kontak pada perangkat anak untuk memonitoring kontak anak'),
            value: _contactPermission,
            onChanged: (val) async {
              print(val);
              var _permissionStatus = await Permission.contacts.status;
              print('_permissionStatus $_permissionStatus');
              if (_permissionStatus.isDenied) {
                _permissionStatus = await Permission.contacts.request();
                print('(await Permission.contacts.shouldShowRequestRationale)  ${(await Permission.contacts.shouldShowRequestRationale)}');
                if (_permissionStatus.isPermanentlyDenied) {
                  await Get.dialog(AlertDialog(
                    title: Text('Akses ditolak'),
                    content: Text('Akses untuk kontak telah di tolak sebelum nya. Buka setting untuk merubah akses'),
                    actions: [
                      TextButton(
                          onPressed: () async {
                            final res = await openAppSettings();
                            if (res) Get.back();
                          },
                          child: Text('Buka Setting'))
                    ],
                  ));
                  _permissionStatus = await Permission.contacts.status;
                }
              }
              _contactPermission = _permissionStatus.isGranted;
              setState(() {});
            },
            contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          ),
          SizedBox(height: 10),
          SwitchListTile.adaptive(
            tileColor: cOrtuGrey,
            title: Text('Lokasi'),
            subtitle: Text('Kami membutuhkan akses lokasi pada perangkat anak untuk memonitoring keberadaan lokasi anak berada'),
            value: _locationPermission,
            onChanged: (val) async {
              var _permissionStatus = await Permission.location.status;
              if (_permissionStatus.isDenied) {
                _permissionStatus = await Permission.location.request();
                print('(await Permission.location.shouldShowRequestRationale)  ${(await Permission.location.shouldShowRequestRationale)}');
                if (_permissionStatus.isPermanentlyDenied) {
                  await Get.dialog(AlertDialog(
                    title: Text('Akses ditolak'),
                    content: Text('Akses untuk lokasi telah di tolak sebelumnya. Buka setting untuk merubah akses.'),
                    actions: [
                      TextButton(
                          onPressed: () async {
                            final res = await openAppSettings();
                            if (res) Get.back();
                          },
                          child: Text('Buka Setting'))
                    ],
                  ));
                  _permissionStatus = await Permission.location.status;
                }
              }
              _locationPermission = _permissionStatus.isGranted;
              setState(() {});
            },
            contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          ),
          SizedBox(height: 10),
          SwitchListTile.adaptive(
            tileColor: cOrtuGrey,
            title: Text('Penggunaan Aplikasi'),
            subtitle: Text('Kami membutuhkan akses data aplikasi pada perangkat anak untuk memonitoring penggunaan aplikasi/game anak.'),
            value: _serviceAppUsage,
            onChanged: (val) async {
              if (val) {
                try {
                  DateTime endDate = new DateTime.now();
                  DateTime startDate = endDate.subtract(Duration(hours: 10));
                  List<AppUsageInfo> infoList = await AppUsage.getAppUsage(startDate, endDate);
                  print('AppUsageInfo ${infoList.length}');
                  if (infoList.length > 0) {
                    _serviceAppUsage = true;
                    setState(() {});
                  }
                } on AppUsageException catch (exception) {
                  print(exception);
                }
              }
            },
            contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          ),
        ],
      ),
    );
  }
}
