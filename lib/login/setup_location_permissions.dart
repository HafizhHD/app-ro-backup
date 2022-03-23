import 'dart:convert';

import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:ruangkeluarga/child/child_main.dart';
// import 'package:ruangkeluarga/child/home_child.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/main/parent_main.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:ruangkeluarga/login/login.dart';

class SetupPermissionPage extends StatefulWidget {
  SetupPermissionPage(
      {Key? key, this.email = '', this.name = '', this.userType = 'child'})
      : super(key: key);

  final String email;
  final String name;
  final String userType;
  @override
  _SetupPermissionPageState createState() => _SetupPermissionPageState();
}

class _SetupPermissionPageState extends State<SetupPermissionPage> {
  bool _locationPermission = false;

  final _waitDelay = 400;

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
                Text(
                    'Aplikasi $appName membutuhkan ijin akses anda untuk dapat berjalan dengan baik.'),
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
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: cPrimaryBg,
                padding: EdgeInsets.only(
                    top: 30.0, left: 20.0, right: 20.0, bottom: 10),
                // margin: EdgeInsets.only(bottom: 10),
                // height: 80,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${widget.name}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: cOrtuBlack),
                    ),
                    Text(
                      'Aplikasi $appName memerlukan beberapa ijin untuk mengakses data yang dibutuhkan:',
                      style: TextStyle(fontSize: 16, color: cOrtuBlack),
                    )
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      checkAllPermission(),
                    ],
                  ),
                ),
              ),
              Container(
                color: cPrimaryBg,
                padding: EdgeInsets.all(10).copyWith(top: 0),
                child: FlatButton(
                  height: 50,
                  minWidth: 300,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                  ),
                  onPressed: () async {
                    if (_locationPermission) {
                      if (widget.userType == 'child') {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => ChildMain(
                                    childEmail: widget.email,
                                    childName: widget.name,
                                  )),
                          (Route<dynamic> route) => false,
                        );
                      } else
                        Navigator.of(context)
                            .push(leftTransitionRoute(ParentMain()));
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
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile.adaptive(
              tileColor: cOrtuGrey,
              title: Text('Lokasi'),
              subtitle: Text('Aplikasi Ruang ORTU by ASIA mengumpulkan data lokasi untuk mengaktifkan "Pantau Lokasi Anak", "Riwayat Lokasi Anak", "ETA" dan "Pesan Darurat" bahkan jika aplikasi ditutup atau tidak digunakan.\n' +
                  '\nLokasi adalah  informasi tempat/posisi berdasarkan lokasi ponsel. Lokasi yang diperlukan dan dikumpulkan berupa Geolokasi dan nama tempat.\n'
                      '\nAplikasi Ruang ORTU by ASIA memungkinkan orang tua dalam memantau lokasi anak.\n'
                      '\nAplikasi Ruang ORTU by ASIA mengumpulkan data dan informasi lokasi perangkat anak sehingga dapat ditampilkan pada dasbor Aplikasi orang tua. ETA Orang tua dapat diketahui oleh Aplikasi anak.\n'
                      '\nFitur Lokasi yang digunakan dalam aplikasi Ruang ORTU by ASIA menggunakan Software Development Kit dari google. Pengguna dapat melihat permission yang digunakan dan memerlukan persetujuan dari pengguna untuk mengaktifkan fitur lokasi.\n'
                      '\nAplikasi Ruang ORTU by ASIA selalu meminta akses lokasi bahkan saat aplikasi tidak digunakan untuk memberikan informasi lokasi yang tepat kepada orangtua dan memastikan mereka berada di lokasi yang aman, meskipun anak tidak mengaktifkan aplikasi Ruang ORTU by ASIA di perangkat mereka.\n'
                      '\nCara Kerja Lokasi pada Perangkat :\n'
                      'Apliaski anak akan mengirimkan lokasi kepada orang Aplikasi orang tua dan Aplikasi orang tua akan mengirimkan lokasi pada anak.\n'
                      'Orang tua dan anak akan saling berbagi informasi lokasi\n'
                      'Orang tua dapat melihat keberadaan anak dan riwayat perjalanannya pada menu pantau lokasi.\n'
                      'Pada saat darurat anak dapat mengirimkan lokasi dan video pada orang tua.'),
              value: _locationPermission,
              onChanged: (val) async {
                var _permissionStatus = await Permission.location.status;
                if (_permissionStatus.isDenied) {
                  final s = Stopwatch()..start();
                  _permissionStatus = await Permission.location.request();
                  s.stop();
                  if (s.elapsedMilliseconds < _waitDelay &&
                      _permissionStatus.isPermanentlyDenied) {
                    await Get.dialog(AlertDialog(
                      title: Text('Akses ditolak'),
                      content: Text(
                          'Akses untuk lokasi telah di tolak sebelumnya. Buka setting untuk merubah akses.'),
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
              contentPadding:
                  EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
