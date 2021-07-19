import 'dart:convert';

import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:location/location.dart' as Locs;
import 'package:permission_handler/permission_handler.dart' as PermsH;
// ignore: import_of_legacy_library_into_null_safe
import 'package:ruangkeluarga/child/home_child.dart';
import 'package:ruangkeluarga/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupPermissionChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }

}

class SetupPermissionChildPage extends StatefulWidget {
  SetupPermissionChildPage({Key? key, required this.title, required this.name}) : super(key: key);

  final String title;
  final String name;
  @override
  _SetupPermissionChildPageState createState() => _SetupPermissionChildPageState();

}

class _SetupPermissionChildPageState extends State<SetupPermissionChildPage> {
  String permissionName = 'Contact';
  String levelStep = 'Step 1';
  String titleStep = 'Contact';
  String subTitleStep = 'Kami membutuhkan Contact Permission pada perangkat anak untuk memonitoring kontak anak.';
  late bool _serviceEnabled;
  bool _serviceAppUsage = false;
  final Locs.Location location = Locs.Location();
  Locs.PermissionStatus _permissionGranted = Locs.PermissionStatus.DENIED;
  PermsH.PermissionStatus? permissionStatusContact;
  bool? _hasPermission;
  bool? _hasPermissionLocation;
  late SharedPreferences prefs;

  Future<void> _checkPermissionContact() async {
    // ignore: unrelated_type_equality_checks
    while (permissionStatusContact != PermsH.PermissionStatus.denied) {
      try {
        permissionStatusContact = await _getContactPermission();
        // ignore: unrelated_type_equality_checks
        if (permissionStatusContact != PermsH.PermissionStatus.granted) {
          _hasPermission = false;
          permissionStatusContact = PermsH.PermissionStatus.denied;
        } else {
          _hasPermission = true;
          levelStep = 'Step 2';
          titleStep = 'Location';
          subTitleStep = 'Kami membutuhkan Location Permission pada perangkat anak untuk memonitoring keberadaan lokasi anak berada.';
          _serviceAppUsage = false;
        }
      } catch (e) {
        _showContactDialog();
      }
    }
    setState(() {});
  }

  Future<PermsH.PermissionStatus> _getContactPermission() async {
    final status = await PermsH.Permission.contacts.status;
    if (!status.isGranted) {
      final result = await PermsH.Permission.contacts.request();
      return result;
    } else {
      return status;
    }
  }

  Future<void> _checkPermissions() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == Locs.PermissionStatus.DENIED) {
      _hasPermissionLocation = false;
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != Locs.PermissionStatus.GRANTED) {
        _hasPermissionLocation = false;
        _showMyDialog();
      } else {
        _hasPermissionLocation = true;
        levelStep = 'Step 3';
        titleStep = 'App Usage';
        subTitleStep = 'Kami membutuhkan App Usage Permission pada perangkat anak untuk memonitoring penggunaan aplikasi/game anak.';
        _serviceAppUsage = false;
      }
    } else {
      _hasPermissionLocation = true;
      levelStep = 'Step 3';
      titleStep = 'App Usage';
      subTitleStep = 'Kami membutuhkan App Usage Permission pada perangkat anak untuk memonitoring penggunaan aplikasi/game anak.';
      _serviceAppUsage = false;
    }

    setState(() {});
  }

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

  Future<void> _showDialogSuccess() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Informasi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Permission sudah di allow.\nSilahkan klik Lanjut untuk melanjutkan proses'),
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

  Future<void> _showContactDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Aplikasi ruang keluar membutuhkan akses kontak anda untuk dapat berjalan dengan baik.'),
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

  void checkUsageStatistik() async {
    try {
      DateTime endDate = new DateTime.now();
      DateTime startDate = endDate.subtract(Duration(hours: 10));
      List<AppUsageInfo> infoList = await AppUsage.getAppUsage(startDate, endDate);

      if(infoList.length > 0) {
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString("usageLists", json.encode(infoList));
        // prefs.commit();
        _serviceAppUsage = true;
      }

      // return infoList;
    } on AppUsageException catch (exception) {
      print(exception);
      // return [];
    }
  }

  void getUsageStatistik() async {
    prefs = await SharedPreferences.getInstance();
    try {
      DateTime endDate = new DateTime.now();
      DateTime startDate = endDate.subtract(Duration(hours: 10));
      List<AppUsageInfo> infoList = await AppUsage.getAppUsage(startDate, endDate);

      if(infoList.length > 0) {
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString("usageLists", json.encode(infoList));
        // prefs.commit();
        _serviceAppUsage = true;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>
            HomeChildPage(title: 'ruang keluarga', email: prefs.getString(rkEmailUser)!,
              name: prefs.getString(rkUserName)!)));
      }

      // return infoList;
    } on AppUsageException catch (exception) {
      print(exception);
      // return [];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Color(0xff05745F));
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
        child: SingleChildScrollView(
            child: Column(
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Kami memerlukan beberapa permission yang dibutuhkan. Ikuti panduan berikut :',
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '$levelStep',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xff3BDFD2),
                              Color(0xff05745F),
                            ],
                          )
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(20.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '$titleStep',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(20.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '$subTitleStep',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(20.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: FlatButton(
                                height: 50,
                                color: Colors.white,
                                shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(10.0)
                                ),
                                child: Text(
                                  'Masuk ke Pengaturan',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                onPressed: () {
                                  if(_hasPermission == true) {
                                    if(permissionName == 'Contact') {
                                      _showDialogSuccess();
                                    } else {
                                      if (_permissionGranted ==
                                          Locs.PermissionStatus.GRANTED) {
                                        if(permissionName == 'Location') {
                                          _showDialogSuccess();
                                        } else {
                                          checkUsageStatistik();
                                        }
                                      } else {
                                        _checkPermissions();
                                      }
                                    }
                                  } else {
                                    _checkPermissionContact();
                                  }
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        child: Text(
                          'Lanjut',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff05745F)
                          ),
                        ),
                        onTap: () {
                          if(_hasPermission == true) {
                            if(_permissionGranted == Locs.PermissionStatus.GRANTED) {
                              if(permissionName == 'Location') {
                                // permissionName = 'App Usage';
                                // levelStep = 'Step 3';
                                // titleStep = 'App Usage';
                                // subTitleStep = 'Kami membutuhkan App Usage Permission pada perangkat anak untuk memonitoring penggunaan aplikasi/game anak.';
                                // _serviceAppUsage = false;
                                // setState(() {});
                                if (!_serviceAppUsage) {
                                  getUsageStatistik();
                                } else {
                                  getUsageStatistik();
                                }
                              } else {
                                if (!_serviceAppUsage) {
                                  getUsageStatistik();
                                } else {
                                  getUsageStatistik();
                                }
                              }
                            } else {
                              if(permissionName == 'Contact') {
                                permissionName = 'Location';
                                levelStep = 'Step 2';
                                titleStep = 'Location';
                                subTitleStep = 'Kami membutuhkan Location Permission pada perangkat anak untuk memonitoring keberadaan lokasi anak berada.';
                                _serviceAppUsage = false;
                                setState(() {});
                              } else {
                                _showMyDialog();
                              }
                            }
                          }
                          else {
                            _showMyDialog();
                          }
                        },
                      )
                    ),
                  ),
                ]
            ),
          )
      )
    );
  }

}