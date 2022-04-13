import 'dart:convert';

import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:ruangkeluarga/child/child_main.dart';
// import 'package:ruangkeluarga/child/home_child.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_controller.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/main/parent_main.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:app_settings/app_settings.dart';

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
  int adVersion = 26;

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
                    'Aplikasi $appName membutuhkan izin akses anda untuk dapat berjalan dengan baik.'),
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

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Future<void> _showLocationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lokasi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Aplikasi Keluarga HKBP mengumpulkan data lokasi untuk mengaktifkan "Pantau Lokasi Anak", "Riwayat Lokasi Anak", "ETA" dan "Pesan Darurat" bahkan jika aplikasi ditutup atau tidak digunakan.\n' +
                    '\nLokasi adalah  informasi tempat/posisi berdasarkan lokasi ponsel. Lokasi yang diperlukan dan dikumpulkan berupa Geolokasi dan nama tempat.\n'
                        '\nAplikasi Keluarga HKBP memungkinkan orang tua dalam memantau dan mengelola aktivitas penggunaan perangkat anak mereka termasuk melihat lokasi anak.\n'
                        '\nAplikasi keluarga HKBP mengumpulkan data dan informasi lokasi perangkat anak sehingga dapat ditampilkan pada dasbor Aplikasi orang tua.\n'
                        '\nFitur Lokasi yang digunakan dalam aplikasi Keluarga HKBP menggunakan Software Development Kit dari google. Pengguna dapat melihat permission yang digunakan dan memerlukan persetujuan dari pengguna untuk mengaktifkan fitur lokasi.\n'
                        '\nAplikasi Keluarga HKBP selalu meminta akses lokasi bahkan saat aplikasi tidak digunakan untuk memberikan informasi lokasi yang tepat kepada orangtua dan memastikan mereka berada di lokasi yang aman, meskipun anak tidak mengaktifkan aplikasi Keluarga HKBP di perangkat mereka.\n'
                        '\nDengan mengaktifkan fitur akses lokasi orang tua dapat melihat lokasi anak, prediksi perjalanan dan riwayat perjalanan anak.\n'
                        '\nCara Kerja Lokasi pada Perangkat :\n'
                        'Pengguna harus mengunduh aplikasi keluarga HKBP dan mendaftarkan akun gmail sebagai orangtua dan anak\n'
                        'Sistem akan meminta persetujuan pengguna untuk mengaktifkan data lokasi untuk memberikan informasi terkait tempat dan informasi jarak lokasi\n'
                        'Untuk melihat lokasi pada perangkat anak. Pengguna(Orang tua) dapat mendaftarkan perangkat anak yang ingin di monitor dengan memasukkan nama, email dan tanggal lahir anak.\n'
                        'Pengguna(Anak) melakukan aktivasi pada perangkat anak dan login menggunakan akun yang sudah didaftarkan sebagai anak.\n'
                        'Pada Aplikasi akan diminta persetujuan untuk mengaktifkan akses data lokasi untuk memberikan informasi lokasi di perangkat berada.\n'
                        'Dengan kondisi lokasi sudah aktif, maka secara berkala aplikasi akan melakukan pengumpulan lokasi pada perangkat anak sehingga orang tua dapat mengetahui informasi lokasi anak mereka melalui aplikasi keluarga HKBP di perangkat orangtua.'),
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

  Future<void> _showLocationGuide() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Panduan Mengaktifkan Lokasi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('1. Tekan tombol di bawah ini.'),
                SizedBox(height: 10),
                FlatButton(
                  height: 30,
                  minWidth: 200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  onPressed: () async {
                    await openAppSettings();
                  },
                  color: cAsiaBlue,
                  child: Text(
                    "Buka Info Aplikasi",
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text('2. Pilih menu "Izin/Permissions".'),
                Text('3. Pilih menu "Lokasi/Location".'),
                Text(
                    '4. Tekan pilihan "Izinkan sepanjang waktu/Allow all the time".'),
                Text(
                    '5. Kembali ke aplikasi dengan menekan tombol "Back" beberapa kali.'), //
                Text('6. Tutup dialog/pop-up ini dan nyalakan tombol lokasi.')
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

    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> _deviceData = <String, dynamic>{};
    var deviceData = <String, dynamic>{};
    if (Platform.isAndroid) {
      deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      adVersion = deviceData['version.sdkInt'];
    } else if (Platform.isIOS) {
      deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      adVersion = deviceData['version.sdkInt'];
    }

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
                          color: cOrtuText),
                    ),
                    Text(
                      'Aplikasi $appName memerlukan beberapa izin untuk mengakses data yang dibutuhkan:',
                      style: TextStyle(fontSize: 16, color: cOrtuText),
                    )
                  ],
                ),
              ),
              Expanded(child: checkAllPermission()),
              // Flexible(
              //   child: SingleChildScrollView(
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       crossAxisAlignment: CrossAxisAlignment.stretch,
              //       children: [
              //         checkAllPermission(),
              //       ],
              //     ),
              //   ),
              // ),
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
                    if (_locationPermission &&
                        _contactPermission &&
                        _serviceAppUsage &&
                        _cameraPermission &&
                        _audioPermission &&
                        _kunciLayar) {
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
                      } else {
                        Get.put(FeedController());
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => ParentMain()),
                          (Route<dynamic> route) => false,
                        );
                      }
                      // else Navigator.of(context).push(leftTransitionRoute(ParentMain()));
                    } else {
                      _showMyDialog();
                    }
                  },
                  color: _locationPermission &&
                          _contactPermission &&
                          _serviceAppUsage &&
                          _cameraPermission &&
                          _audioPermission &&
                          _kunciLayar
                      ? cAsiaBlue
                      : Color.fromARGB(255, 80, 80, 80),
                  child: Text(
                    "LANJUT KE HOME",
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold,
                      color: cOrtuWhite,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ],
          ))),
    );
  }

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  void nextPage(int index) {
    pageController.animateToPage(index,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  Widget checkAllPermission() {
    final screenHeight = MediaQuery.of(context).size.height;
    return PageView(
      controller: pageController,
      children: <Widget>[
        Container(
            margin: EdgeInsets.all(10),
            child: Column(children: [
              Text('Kontak',
                  style: TextStyle(
                      color: cOrtuText,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              // Padding(
              //     padding: EdgeInsets.all(100),
              //     child: Text('Gambar',
              //         style: TextStyle(
              //             backgroundColor: cOrtuText, fontSize: 20))),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Image.asset('assets/images/icon/phonebook.png',
                      height: screenHeight / 4, fit: BoxFit.fill)),
              Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                      'Kami membutuhkan akses kontak pada perangkat anak untuk memonitoring kontak anak.',
                      style: TextStyle(color: cOrtuText))),
              SwitchListTile.adaptive(
                tileColor: cOrtuGrey,
                title: Text('Kontak'),
                value: _contactPermission,
                onChanged: (val) async {
                  print(val);
                  var _permissionStatus = await Permission.contacts.status;
                  print('_permissionStatus $_permissionStatus');
                  if (_permissionStatus.isDenied) {
                    final s = Stopwatch()..start();
                    _permissionStatus = await Permission.contacts.request();
                    s.stop();
                    if (s.elapsedMilliseconds < _waitDelay &&
                        _permissionStatus.isPermanentlyDenied) {
                      await Get.dialog(AlertDialog(
                        title: Text('Akses ditolak'),
                        content: Text(
                            'Akses untuk kontak telah di tolak sebelum nya. Buka setting untuk merubah akses'),
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
                  nextPage(1);
                  setState(() {});
                },
                contentPadding:
                    EdgeInsets.only(top: 3, bottom: 3, left: 20, right: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              )
            ])),
        Container(
            margin: EdgeInsets.all(10),
            child: Column(children: [
              Text('Kamera',
                  style: TextStyle(
                      color: cOrtuText,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Image.asset('assets/images/icon/camera.png',
                      height: screenHeight / 4, fit: BoxFit.fill)),
              Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                      'Kami membutuhkan akses kamera pada perangkat anak untuk mengirimkan rekaman video SOS.',
                      style: TextStyle(color: cOrtuText))),
              SwitchListTile.adaptive(
                tileColor: cOrtuGrey,
                title: Text('Kamera'),
                value: _cameraPermission,
                onChanged: (val) async {
                  var _permissionStatus = await Permission.camera.status;
                  if (_permissionStatus.isDenied) {
                    final s = Stopwatch()..start();
                    _permissionStatus = await Permission.camera.request();
                    s.stop();
                    if (s.elapsedMilliseconds < _waitDelay &&
                        _permissionStatus.isPermanentlyDenied) {
                      await Get.dialog(AlertDialog(
                        title: Text('Akses ditolak'),
                        content: Text(
                            'Akses untuk kamera telah di tolak sebelumnya. Buka setting untuk merubah akses.'),
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
                  nextPage(2);
                  setState(() {});
                },
                contentPadding:
                    EdgeInsets.only(top: 3, bottom: 3, left: 20, right: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              )
            ])),
        Container(
            margin: EdgeInsets.all(10),
            child: Column(children: [
              Text('Audio',
                  style: TextStyle(
                      color: cOrtuText,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Image.asset('assets/images/icon/mic.png',
                      height: screenHeight / 4, fit: BoxFit.fill)),
              Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                      'Kami membutuhkan akses microphone pada perangkat anak untuk mengirimkan rekaman suara ketika SOS.',
                      style: TextStyle(color: cOrtuText))),
              SwitchListTile.adaptive(
                tileColor: cOrtuGrey,
                title: Text('Audio'),
                value: _audioPermission,
                onChanged: (val) async {
                  var _permissionStatus = await Permission.microphone.status;
                  if (_permissionStatus.isDenied) {
                    final s = Stopwatch()..start();
                    _permissionStatus = await Permission.microphone.request();
                    s.stop();
                    if (s.elapsedMilliseconds < _waitDelay &&
                        _permissionStatus.isPermanentlyDenied) {
                      await Get.dialog(AlertDialog(
                        title: Text('Akses ditolak'),
                        content: Text(
                            'Akses untuk microphone telah di tolak sebelumnya. Buka setting untuk merubah akses.'),
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
                  nextPage(3);
                  setState(() {});
                },
                contentPadding:
                    EdgeInsets.only(top: 3, bottom: 3, left: 20, right: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              )
            ])),
        Container(
            margin: EdgeInsets.all(10),
            child: Column(children: [
              Text('Media Penyimpanan',
                  style: TextStyle(
                      color: cOrtuText,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Image.asset('assets/images/icon/folderdocs.png',
                      height: screenHeight / 4, fit: BoxFit.fill)),
              Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                      'Kami membutuhkan akses media penyimpanan untuk menyimpan foto profile Anda.',
                      style: TextStyle(color: cOrtuText))),
              SwitchListTile.adaptive(
                tileColor: cOrtuGrey,
                title: Text('Media Penyimpanan'),
                value: _storage,
                onChanged: (val) async {
                  var _permissionStatus = await Permission.storage.status;
                  if (_permissionStatus.isDenied) {
                    final s = Stopwatch()..start();
                    _permissionStatus = await Permission.storage.request();
                    s.stop();
                    if (s.elapsedMilliseconds < _waitDelay &&
                        _permissionStatus.isPermanentlyDenied) {
                      await Get.dialog(AlertDialog(
                        title: Text('Akses ditolak'),
                        content: Text(
                            'Akses untuk akses media penyimpanan telah di tolak sebelumnya. Buka setting untuk merubah akses.'),
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
                  nextPage(4);
                  setState(() {});
                },
                contentPadding:
                    EdgeInsets.only(top: 3, bottom: 3, left: 20, right: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              )
            ])),
        Container(
            margin: EdgeInsets.all(10),
            child: Column(children: [
              Text('Window Alert',
                  style: TextStyle(
                      color: cOrtuText,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Image.asset('assets/images/icon/layershapes.png',
                      height: screenHeight / 4, fit: BoxFit.fill)),
              Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                      'Kami membutuhkan akses window alert untuk memberikan informasi aplikasi yang dibatasi orang tua.',
                      style: TextStyle(color: cOrtuText))),
              SwitchListTile.adaptive(
                tileColor: cOrtuGrey,
                title: Text('Window Alert'),
                value: _systemAlertWindow,
                onChanged: (val) async {
                  var _permissionStatus =
                      await Permission.systemAlertWindow.status;
                  if (_permissionStatus.isDenied) {
                    final s = Stopwatch()..start();
                    _permissionStatus =
                        await Permission.systemAlertWindow.request();
                    s.stop();
                    if (s.elapsedMilliseconds < _waitDelay &&
                        _permissionStatus.isPermanentlyDenied) {
                      await Get.dialog(AlertDialog(
                        title: Text('Akses ditolak'),
                        content: Text(
                            'Akses untuk akses window alert telah di tolak sebelumnya. Buka setting untuk merubah akses.'),
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
                  _systemAlertWindow = _permissionStatus.isGranted;
                  nextPage(5);
                  setState(() {});
                },
                contentPadding:
                    EdgeInsets.only(top: 3, bottom: 3, left: 20, right: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              )
            ])),
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
        Container(
            margin: EdgeInsets.all(10),
            child: Column(children: [
              Text('Penggunaan Aplikasi',
                  style: TextStyle(
                      color: cOrtuText,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Image.asset('assets/images/icon/phoneapps.png',
                      height: screenHeight / 4, fit: BoxFit.fill)),
              Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                      'Kami membutuhkan akses data aplikasi pada perangkat anak untuk memonitoring penggunaan aplikasi/game anak.',
                      style: TextStyle(color: cOrtuText))),
              SwitchListTile.adaptive(
                tileColor: cOrtuGrey,
                title: Text('Penggunaan Aplikasi'),
                value: _serviceAppUsage,
                onChanged: (val) async {
                  if (val) {
                    try {
                      DateTime endDate = new DateTime.now();
                      DateTime startDate =
                          endDate.subtract(Duration(hours: 10));
                      List<AppUsageInfo> infoList =
                          await AppUsage.getAppUsage(startDate, endDate);
                      print('AppUsageInfo ${infoList.length}');
                      if (infoList.length > 0) {
                        _serviceAppUsage = true;
                        nextPage(6);
                        setState(() {});
                      }
                    } on AppUsageException catch (exception) {
                      print(exception);
                    }
                  }
                },
                contentPadding:
                    EdgeInsets.only(top: 3, bottom: 3, left: 20, right: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              )
            ])),
        Container(
            margin: EdgeInsets.all(10),
            child: Column(children: [
              Text('Kunci Layar',
                  style: TextStyle(
                      color: cOrtuText,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Image.asset('assets/images/icon/locklayer.png',
                      height: screenHeight / 4, fit: BoxFit.fill)),
              Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                      'Kami membutuhkan akses kunci layar pada perangkat anak untuk memonitoring penggunaan aplikasi/game anak.',
                      style: TextStyle(color: cOrtuText))),
              SwitchListTile.adaptive(
                tileColor: cOrtuGrey,
                title: Text('Kunci Layar'),
                value: _kunciLayar,
                onChanged: (val) async {
                  MethodChannel channel = new MethodChannel(
                      'com.ruangkeluargamobile/android_service_background',
                      JSONMethodCodec());
                  bool? response = await channel.invokeMethod<bool>(
                      'permissionLockApp', {'data': 'data'});
                  print('response : ' + response.toString());
                  if (response!) {
                    setState(() {
                      _kunciLayar = true;
                      nextPage(7);
                    });
                  }
                },
                contentPadding:
                    EdgeInsets.only(top: 3, bottom: 3, left: 20, right: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              )
            ])),
        Container(
            margin: EdgeInsets.all(10),
            child: Column(children: [
              Text('Lokasi',
                  style: TextStyle(
                      color: cOrtuText,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Image.asset('assets/images/icon/pinround.png',
                      height: screenHeight / 4, fit: BoxFit.fill)),
              Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(children: [
                    Text(
                        'Aplikasi $appName mengumpulkan data lokasi untuk mengaktifkan "Pantau Lokasi Anak", "Riwayat Lokasi Anak", "ETA" dan "Pesan Darurat".',
                        style: TextStyle(color: cOrtuText)),
                    InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Lihat Selengkapnya",
                            style: TextStyle(color: cOrtuInkWell),
                          ),
                        ],
                      ),
                      onTap: () {
                        _showLocationDialog();
                      },
                    )
                  ])),
              SwitchListTile.adaptive(
                tileColor: cOrtuGrey,
                title: Text('Lokasi'),
                // subtitle: Column(children: [
                //   Text(readMore == true
                //       ? ('Aplikasi Keluarga HKBP mengumpulkan data lokasi untuk mengaktifkan "Pantau Lokasi Anak", "Riwayat Lokasi Anak", "ETA" dan "Pesan Darurat" bahkan jika aplikasi ditutup atau tidak digunakan.\n' +
                //           '\nLokasi adalah  informasi tempat/posisi berdasarkan lokasi ponsel. Lokasi yang diperlukan dan dikumpulkan berupa Geolokasi dan nama tempat.\n'
                //               '\nAplikasi Keluarga HKBP memungkinkan orang tua dalam memantau dan mengelola aktivitas penggunaan perangkat anak mereka termasuk melihat lokasi anak.\n'
                //               '\nAplikasi keluarga HKBP mengumpulkan data dan informasi lokasi perangkat anak sehingga dapat ditampilkan pada dasbor Aplikasi orang tua.\n'
                //               '\nFitur Lokasi yang digunakan dalam aplikasi Keluarga HKBP menggunakan Software Development Kit dari google. Pengguna dapat melihat permission yang digunakan dan memerlukan persetujuan dari pengguna untuk mengaktifkan fitur lokasi.\n'
                //               '\nAplikasi Keluarga HKBP selalu meminta akses lokasi bahkan saat aplikasi tidak digunakan untuk memberikan informasi lokasi yang tepat kepada orangtua dan memastikan mereka berada di lokasi yang aman, meskipun anak tidak mengaktifkan aplikasi Keluarga HKBP di perangkat mereka.\n'
                //               '\nDengan mengaktifkan fitur akses lokasi orang tua dapat melihat lokasi anak, prediksi perjalanan dan riwayat perjalanan anak.\n'
                //               '\nCara Kerja Lokasi pada Perangkat :\n'
                //               'Pengguna harus mengunduh aplikasi keluarga HKBP dan mendaftarkan akun gmail sebagai orangtua dan anak\n'
                //               'Sistem akan meminta persetujuan pengguna untuk mengaktifkan data lokasi untuk memberikan informasi terkait tempat dan informasi jarak lokasi\n'
                //               'Untuk melihat lokasi pada perangkat anak. Pengguna(Orang tua) dapat mendaftarkan perangkat anak yang ingin di monitor dengan memasukkan nama, email dan tanggal lahir anak.\n'
                //               'Pengguna(Anak) melakukan aktivasi pada perangkat anak dan login menggunakan akun yang sudah didaftarkan sebagai anak.\n'
                //               'Pada Aplikasi akan diminta persetujuan untuk mengaktifkan akses data lokasi untuk memberikan informasi lokasi di perangkat berada.\n'
                //               'Dengan kondisi lokasi sudah aktif, maka secara berkala aplikasi akan melakukan pengumpulan lokasi pada perangkat anak sehingga orang tua dapat mengetahui informasi lokasi anak mereka melalui aplikasi keluarga HKBP di perangkat orangtua.')
                //       : ('Aplikasi Keluarga HKBP mengumpulkan data lokasi untuk mengaktifkan "Pantau Lokasi Anak", "Riwayat Lokasi Anak"...')),
                //   InkWell(
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         Text(
                //           readMore == true ? "Show less..." : "Show more...",
                //           style: TextStyle(color: cOrtuInkWell),
                //         ),
                //       ],
                //     ),
                //     onTap: () {
                //       setState(() {
                //         readMore = !readMore;
                //       });
                //     },
                //   ),
                // ]),
                value: _locationPermission,
                onChanged: (val) async {
                  var _permissionStatus =
                      await Permission.locationAlways.status;
                  if (_permissionStatus.isDenied) {
                    final s = Stopwatch()..start();
                    _permissionStatus =
                        await Permission.locationAlways.request();
                    s.stop();
                    if (s.elapsedMilliseconds < _waitDelay &&
                        _permissionStatus.isPermanentlyDenied) {
                      await Get.dialog(AlertDialog(
                        title: Text('Akses ditolak'),
                        content: Text(
                            'Akses untuk lokasi telah ditolak sebelumnya. Buka setting untuk mengubah akses.'),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                final res = await openAppSettings();
                                if (res) Get.back();
                              },
                              child: Text('Buka Setting'))
                        ],
                      ));
                      _permissionStatus =
                          await Permission.locationAlways.status;
                    }
                  }
                  _locationPermission = _permissionStatus.isGranted;
                  setState(() {});
                },
                contentPadding:
                    EdgeInsets.only(top: 3, bottom: 3, left: 20, right: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
              SizedBox(height: 10),
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Tidak bisa dinyalakan? Lihat caranya di sini.',
                        style: TextStyle(color: cOrtuInkWell)),
                  ],
                ),
                onTap: () async {
                  await _showLocationGuide();
                },
              ),
            ])),
      ],
    );
  }
}
