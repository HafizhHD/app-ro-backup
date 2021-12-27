import 'dart:convert';

import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:ruangkeluarga/child/child_main.dart';
// import 'package:ruangkeluarga/child/home_child.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_controller.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/main/parent_main.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:ruangkeluarga/login/login.dart';


class SetupPermissionPage extends StatefulWidget {
  SetupPermissionPage({Key? key, this.email = '', this.name = '', this.userType = 'child'}) : super(key: key);

  final String email;
  final String name;
  final String userType;
  @override
  _SetupPermissionPageState createState() => _SetupPermissionPageState();
}

class _SetupPermissionPageState extends State<SetupPermissionPage> {
  bool _serviceAppUsage = false;
  bool _kunciLayar = false;
  bool _locationPermission = false;
  bool _cameraPermission = false;
  bool _audioPermission = false;
  bool _storage = false;
  // bool _smsPermission = false;
  bool _contactPermission = false;
  bool _systemAlertWindow = false;
  bool readMore = false;
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
                Text('Aplikasi $appName membutuhkan ijin akses anda untuk dapat berjalan dengan baik.'),
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
    _locationPermission = (await Permission.locationAlways.status).isGranted;
    _contactPermission = (await Permission.contacts.status).isGranted;
    _cameraPermission = (await Permission.camera.status).isGranted;
    _audioPermission = (await Permission.microphone.status).isGranted;
    _storage = (await Permission.storage.status).isGranted;
    _systemAlertWindow = (await Permission.systemAlertWindow.status).isGranted;

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
                padding: EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0, bottom: 10),
                // margin: EdgeInsets.only(bottom: 10),
                // height: 80,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${widget.name}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cOrtuWhite),
                    ),
                    Text(
                      'Aplikasi $appName memerlukan beberapa ijin untuk mengakses data yang dibutuhkan:',
                      style: TextStyle(fontSize: 16, color: cOrtuWhite),
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
                    if (_locationPermission && _contactPermission && _serviceAppUsage && _cameraPermission && _audioPermission && _kunciLayar) {
                      if (widget.userType == 'child') {
                        Get.put(FeedController());
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => ChildMain(
                                    childEmail: widget.email,
                                    childName: widget.name,
                                  )),
                          (Route<dynamic> route) => false,
                        );
                      }
                      else Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => ParentMain()),
                            (Route<dynamic> route) => false,
                      );
                      // else Navigator.of(context).push(leftTransitionRoute(ParentMain()));
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
              title: Text('Kontak'),
              subtitle: Text('Kami membutuhkan akses kontak pada perangkat anak untuk memonitoring kontak anak'),
              value: _contactPermission,
              onChanged: (val) async {
                print(val);
                var _permissionStatus = await Permission.contacts.status;
                print('_permissionStatus $_permissionStatus');
                if (_permissionStatus.isDenied) {
                  final s = Stopwatch()..start();
                  _permissionStatus = await Permission.contacts.request();
                  s.stop();
                  if (s.elapsedMilliseconds < _waitDelay && _permissionStatus.isPermanentlyDenied) {
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
              title: Text('Kamera'),
              subtitle: Text('Kami membutuhkan akses kamera pada perangkat anak untuk mengirimkan rekaman video sos.'),
              value: _cameraPermission,
              onChanged: (val) async {
                var _permissionStatus = await Permission.camera.status;
                if (_permissionStatus.isDenied) {
                  final s = Stopwatch()..start();
                  _permissionStatus = await Permission.camera.request();
                  s.stop();
                  if (s.elapsedMilliseconds < _waitDelay && _permissionStatus.isPermanentlyDenied) {
                    await Get.dialog(AlertDialog(
                      title: Text('Akses ditolak'),
                      content: Text('Akses untuk kamera telah di tolak sebelumnya. Buka setting untuk merubah akses.'),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              final res = await openAppSettings();
                              if (res) Get.back();
                            },
                            child: Text('Buka Setting'))
                      ],
                    ));
                  }
                }
                _cameraPermission = _permissionStatus.isGranted;
                setState(() {});
              },
              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            ),
            SizedBox(height: 10),
            SwitchListTile.adaptive(
              tileColor: cOrtuGrey,
              title: Text('Audio'),
              subtitle: Text('Kami membutuhkan akses microphone pada perangkat anak untuk mengirimkan rekaman suara ketika sos.'),
              value: _audioPermission,
              onChanged: (val) async {
                var _permissionStatus = await Permission.microphone.status;
                if (_permissionStatus.isDenied) {
                  final s = Stopwatch()..start();
                  _permissionStatus = await Permission.microphone.request();
                  s.stop();
                  if (s.elapsedMilliseconds < _waitDelay && _permissionStatus.isPermanentlyDenied) {
                    await Get.dialog(AlertDialog(
                      title: Text('Akses ditolak'),
                      content: Text('Akses untuk microphone telah di tolak sebelumnya. Buka setting untuk merubah akses.'),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              final res = await openAppSettings();
                              if (res) Get.back();
                            },
                            child: Text('Buka Setting'))
                      ],
                    ));
                  }
                }
                _audioPermission = _permissionStatus.isGranted;
                setState(() {});
              },
              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            ),
            SizedBox(height: 10),
            SwitchListTile.adaptive(
              tileColor: cOrtuGrey,
              title: Text('Media Penyimpanan'),
              subtitle: Text('Kami membutuhkan akses media penyimpanan untuk menyimpan foto profile anda'),
              value: _storage,
              onChanged: (val) async {
                var _permissionStatus = await Permission.storage.status;
                if (_permissionStatus.isDenied) {
                  final s = Stopwatch()..start();
                  _permissionStatus = await Permission.storage.request();
                  s.stop();
                  if (s.elapsedMilliseconds < _waitDelay && _permissionStatus.isPermanentlyDenied) {
                    await Get.dialog(AlertDialog(
                      title: Text('Akses ditolak'),
                      content: Text('Akses untuk akses media penyimpanan telah di tolak sebelumnya. Buka setting untuk merubah akses.'),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              final res = await openAppSettings();
                              if (res) Get.back();
                            },
                            child: Text('Buka Setting'))
                      ],
                    ));
                  }
                }
                _storage = _permissionStatus.isGranted;
                setState(() {});
              },
              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            ),
            SizedBox(height: 10),
            SwitchListTile.adaptive(
              tileColor: cOrtuGrey,
              title: Text('Window Alert'),
              subtitle: Text('Kami membutuhkan akses window alert untuk memberikan informasi apliaski yang dibatasi orang tua'),
              value: _systemAlertWindow,
              onChanged: (val) async {
                var _permissionStatus = await Permission.systemAlertWindow.status;
                if (_permissionStatus.isDenied) {
                  final s = Stopwatch()..start();
                  _permissionStatus = await Permission.systemAlertWindow.request();
                  s.stop();
                  if (s.elapsedMilliseconds < _waitDelay && _permissionStatus.isPermanentlyDenied) {
                    await Get.dialog(AlertDialog(
                      title: Text('Akses ditolak'),
                      content: Text('Akses untuk akses window alert telah di tolak sebelumnya. Buka setting untuk merubah akses.'),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              final res = await openAppSettings();
                              if (res) Get.back();
                            },
                            child: Text('Buka Setting'))
                      ],
                    ));
                  }
                }_systemAlertWindow = _permissionStatus.isGranted;

                setState(() {});
              },
              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            ),
            SizedBox(height: 10),
            // SwitchListTile.adaptive(
            //   tileColor: cOrtuGrey,
            //   title: Text('SMS'),
            //   subtitle: Text('Kami membutuhkan akses sms pada perangkat anak untuk mengirimkan sms dari SOS.'),
            //   value: _smsPermission,
            //   onChanged: (val) async {
            //     var _permissionStatus = await Permission.sms.status;
            //     if (_permissionStatus.isDenied) {
            //       final s = Stopwatch()..start();
            //       _permissionStatus = await Permission.sms.request();
            //       s.stop();
            //       if (s.elapsedMilliseconds < _waitDelay && _permissionStatus.isPermanentlyDenied) {
            //         await Get.dialog(AlertDialog(
            //           title: Text('Akses ditolak'),
            //           content: Text('Akses untuk sms telah di tolak sebelumnya. Buka setting untuk merubah akses.'),
            //           actions: [
            //             TextButton(
            //                 onPressed: () async {
            //                   final res = await openAppSettings();
            //                   if (res) Get.back();
            //                 },
            //                 child: Text('Buka Setting'))
            //           ],
            //         ));
            //         _permissionStatus = await Permission.sms.status;
            //       }
            //     }
            //     _smsPermission = _permissionStatus.isGranted;
            //     setState(() {});
            //   },
            //   contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 0),
            //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            // ),
            // SizedBox(height: 10),
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
            SizedBox(height: 10),
            SwitchListTile.adaptive(
              tileColor: cOrtuGrey,
              title: Text('Kunci Layar'),
              subtitle: Text('Kami membutuhkan akses kunci layar pada perangkat anak untuk memonitoring penggunaan aplikasi/game anak.'),
              value: _kunciLayar,
              onChanged: (val) async {
                MethodChannel channel= new MethodChannel('com.ruangkeluargamobile/android_service_background', JSONMethodCodec());
                bool? response = await channel.invokeMethod<bool>('permissionLockApp', {'data':'data'});
                print('response : '+response.toString());
                if(response!){
                  setState(() {
                    _kunciLayar = true;
                  });
                }
              },
              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            ),
            SizedBox(height: 10),
            SwitchListTile.adaptive(
              tileColor: cOrtuGrey,
              title: Text('Lokasi'),
              subtitle: Column(children: [
                Text(readMore == true
                    ? ('Aplikasi Ruang ORTU mengumpulkan data lokasi untuk mengaktifkan "Pantau Lokasi Anak", "Riwayat Lokasi Anak", "ETA" dan "Pesan Darurat" bahkan jika aplikasi ditutup atau tidak digunakan.\n' +
                    '\nLokasi adalah  informasi tempat/posisi berdasarkan lokasi ponsel. Lokasi yang diperlukan dan dikumpulkan berupa Geolokasi dan nama tempat.\n'
                        '\nAplikasi Ruang ORTU memungkinkan orang tua dalam memantau dan mengelola aktivitas penggunaan perangkat anak mereka termasuk melihat lokasi anak.\n'
                        '\nAplikasi Ruang ORTU mengumpulkan data dan informasi lokasi perangkat anak sehingga dapat ditampilkan pada dasbor Aplikasi orang tua.\n'
                        '\nFitur Lokasi yang digunakan dalam aplikasi Ruang ORTU menggunakan Software Development Kit dari google. Pengguna dapat melihat permission yang digunakan dan memerlukan persetujuan dari pengguna untuk mengaktifkan fitur lokasi.\n'
                        '\nAplikasi Ruang ORTU selalu meminta akses lokasi bahkan saat aplikasi tidak digunakan untuk memberikan informasi lokasi yang tepat kepada orangtua dan memastikan mereka berada di lokasi yang aman, meskipun anak tidak mengaktifkan aplikasi Ruang ORTU di perangkat mereka.\n'
                        '\nDengan mengaktifkan fitur akses lokasi orang tua dapat melihat lokasi anak, prediksi perjalanan dan riwayat perjalanan anak.\n'
                        '\nCara Kerja Lokasi pada Perangkat :\n'
                        'Pengguna harus mengunduh aplikasi Ruang ORTU dan mendaftarkan akun gmail sebagai orangtua dan anak\n'
                        'Sistem akan meminta persetujuan pengguna untuk mengaktifkan data lokasi untuk memberikan informasi terkait tempat dan informasi jarak lokasi\n'
                        'Untuk melihat lokasi pada perangkat anak. Pengguna(Orang tua) dapat mendaftarkan perangkat anak yang ingin di monitor dengan memasukkan nama, email dan tanggal lahir anak.\n'
                        'Pengguna(Anak) melakukan aktivasi pada perangkat anak dan login menggunakan akun yang sudah didaftarkan sebagai anak.\n'
                        'Pada Aplikasi akan diminta persetujuan untuk mengaktifkan akses data lokasi untuk memberikan informasi lokasi di perangkat berada.\n'
                        'Dengan kondisi lokasi sudah aktif, maka secara berkala aplikasi akan melakukan pengumpulan lokasi pada perangkat anak sehingga orang tua dapat mengetahui informasi lokasi anak mereka melalui aplikasi Ruang ORTU di perangkat orangtua.')
                    : ('Aplikasi Ruang ORTU mengumpulkan data lokasi untuk mengaktifkan "Pantau Lokasi Anak", "Riwayat Lokasi Anak"...')),
                InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        readMore == true ? "Show less..." : "Show more...",
                        style: TextStyle(color: cOrtuBlue),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      readMore = !readMore;
                    });
                  },
                ),
              ]),
              value: _locationPermission,
              onChanged: (val) async {
                var _permissionStatus = await Permission.locationAlways.status;
                if (_permissionStatus.isDenied) {
                  final s = Stopwatch()..start();
                  _permissionStatus = await Permission.locationAlways.request();
                  s.stop();
                  if (s.elapsedMilliseconds < _waitDelay && _permissionStatus.isPermanentlyDenied) {
                    await Get.dialog(AlertDialog(
                      title: Text('Akses ditolak'),
                      content: Text('Akses untuk lokasi telah ditolak sebelumnya. Buka setting untuk mengubah akses.'),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              final res = await openAppSettings();
                              if (res) Get.back();
                            },
                            child: Text('Buka Setting'))
                      ],
                    ));
                    _permissionStatus = await Permission.locationAlways.status;
                  }
                }
                _locationPermission = _permissionStatus.isGranted;
                setState(() {});
              },
              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            ),
          ],
        ),
      ),
    );
  }
}
