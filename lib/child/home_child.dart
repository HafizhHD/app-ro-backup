import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

import 'package:http/http.dart';

import 'package:intl/intl.dart';

import 'package:app_usage/app_usage.dart';
import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ruangkeluarga/child/sos_record_video.dart';
import 'package:ruangkeluarga/main.dart';
import 'package:ruangkeluarga/model/rk_callLog_model.dart';
import 'package:ruangkeluarga/model/rk_child_app_icon_list.dart';
import 'package:ruangkeluarga/model/rk_child_apps.dart';
import 'package:ruangkeluarga/model/rk_child_blacklist_contact.dart';
import 'package:ruangkeluarga/utils/constant.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruangkeluarga/plugin_device_app.dart';

import '../plugin_device_app.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class HomeChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ruang keluarga',
      // theme: ThemeData(primarySwatch: Colors.white54),
      home: HomeChildPage(title: 'ruang keluarga', email: '', name: ''),
    );
  }
}

class HomeChildPage extends StatefulWidget {
  HomeChildPage({Key? key, required this.title, required this.email, required this.name}) : super(key: key);

  final String title;
  final String email;
  final String name;

  @override
  _HomeChildPageState createState() => _HomeChildPageState();
}

class _HomeChildPageState extends State<HomeChildPage> {
  List<Application> itemsApp = [];
  List<Application> listItemApps = [];
  late SharedPreferences prefs;
  List<Contact>? _contacts;
  bool _permissionDenied = false;
  Location location = new Location();
  bool _serviceEnabled = false;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  List<BlackListContact> blackListData = [];

  void getUsageStatistik() async {
    prefs = await SharedPreferences.getInstance();
    try {
      List<Application> appData = await getListApps();
      var outputFormat = DateFormat('HH');
      var outputFormatMinute = DateFormat('mm');
      var outputFormatSecond = DateFormat('ss');
      var outputDate = outputFormat.format(DateTime.now());
      var outputDateMinute = outputFormatMinute.format(DateTime.now());
      var outputDateSecond = outputFormatSecond.format(DateTime.now());
      // DateTime endDate = outputFormat.parse(outputDate);
      DateTime endDate = new DateTime.now();
      // DateTime startDate = endDate.subtract(Duration(hours: int.parse(outputDate)));
      DateTime startDate =
          endDate.subtract(Duration(hours: int.parse(outputDate), minutes: int.parse(outputDateMinute), seconds: int.parse(outputDateSecond)));
      // DateTime startDate = outputFormat.parse(outputDate);
      List<AppUsageInfo> infoList = await AppUsage.getAppUsage(startDate, endDate);

      if (infoList.length > 0) {
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString("usageLists", json.encode(infoList));
        // prefs.commit();
        List<dynamic> dataList = [];
        for (int i = 0; i < infoList.length; i++) {
          Application? iconApp = getIconAppsFromList(infoList[i].packageName);
          var nameApp = getNameAppsFromList(infoList[i].packageName);
          if (nameApp == "") {
            nameApp = infoList[i].appName;
          }

          var cat = "other";
          for (int xz = 0; xz < appData.length; xz++) {
            if (infoList[i].packageName == appData[xz].packageName) {
              if (appData[xz].category.toString().split('.')[1] != 'undefined') {
                cat = appData[xz].category.toString().split('.')[1];
              }
              break;
            }
          }

          if (infoList[i].packageName == 'com.google.android.youtube') {
            var temp = {
              'count': 0,
              'appName': nameApp,
              'packageId': infoList[i].packageName,
              'duration': infoList[i].usage.inSeconds,
              'icon': null,
              'appCategory': cat
            };
            dataList.add(temp);
          } else if (infoList[i].packageName.contains('com.android') ||
              infoList[i].packageName.contains('com.google.android') ||
              infoList[i].packageName.contains('com.miui')) {
          } else {
            var temp = {
              'count': 0,
              'appName': nameApp,
              'packageId': infoList[i].packageName,
              'duration': infoList[i].usage.inSeconds,
              'icon': null,
              'appCategory': cat
            };
            dataList.add(temp);
          }
        }
        onSaveUsage(dataList);
      }

      // return infoList;
    } on AppUsageException catch (exception) {
      print(exception);
      // return [];
    }
  }

  getFileSize(String filepath, int decimals) async {
    var file = File(filepath);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
  }

  Future<List<Application>> getListApps() async {
    List<Application> appData =
        await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: false, onlyAppsWithLaunchIntent: false);

    itemsApp = appData;
    return appData;
  }

  void getDataListApps() async {
    prefs = await SharedPreferences.getInstance();
    Response response = await MediaRepository().fetchAppList(widget.email);
    if (response.statusCode == 200) {
      print('isi response fetch appList : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        if (json['appdevices'].length > 0) {
          var appDevices = json['appdevices'][0];
          List<ApplicationInstalled> data =
              List<ApplicationInstalled>.from(appDevices['appName'].map((model) => ApplicationInstalled.fromJson(model)));

          List<Application> appData =
              await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: false, onlyAppsWithLaunchIntent: false);
          List<dynamic> appName = [];
          bool _isAppNew = false;
          for (int i = 0; i < appData.length; i++) {
            bool flag = false;
            int indeks = 0;
            for (int j = 0; j < data.length; j++) {
              if (appData[1].packageName == data[j].packageId) {
                flag = true;
                indeks = j;
                break;
              }
            }
            var cat = "";
            if (appData[i].category.toString().split('.')[1] == 'undefined') {
              cat = "other";
            } else {
              cat = appData[i].category.toString().split('.')[1];
            }
            if (flag) {
              appName.add({
                "appName": appData[i].appName,
                "packageId": appData[i].packageName,
                "blacklist": data[indeks].blacklist,
                "appCategory": cat,
              });
            } else {
              _isAppNew = true;
              appName.add({
                "appName": appData[i].appName,
                "packageId": appData[i].packageName,
                "blacklist": false,
                "appCategory": cat,
              });
            }
          }
          if (_isAppNew) {
            Response response = await MediaRepository().saveAppList(prefs.getString(rkEmailUser)!, appName);
            if (response.statusCode == 200) {
              print('save appList ${response.body}');
              var json = jsonDecode(response.body);
              if (json['statusCode'] == 'OK') {
                await prefs.setBool('rkGetListAppInstall', true);
              }
            } else {
              print('gagal get appLits ${response.statusCode}');
            }
          }
          /*if(prefs.getBool('rkGetListAppInstall') != null) {
            if(prefs.getBool('rkGetListAppInstall') == false) {

            }
          }
          else {
            List<Application> appData = await DeviceApps.getInstalledApplications(
                includeAppIcons: true,
                includeSystemApps: false,
                onlyAppsWithLaunchIntent: false
            );
            List<dynamic> appName = [];
            for (int i = 0; i < appData.length; i++) {
              bool flag = false;
              int indeks = 0;
              for(int j = 0; j < data.length; j++) {
                if(appData[1].packageName == data[j].packageId) {
                  flag = true;
                  indeks = j;
                  break;
                }
              }
              if(flag) {
                appName.add({
                  "appName": appData[i].appName,
                  "packageId": appData[i].packageName,
                  "blacklist": data[indeks].packageId,
                });
              } else {
                appName.add({
                  "appName": appData[i].appName,
                  "packageId": appData[i].packageName,
                  "blacklist": false,
                });
              }
            }
            Response response = await MediaRepository().saveAppList(
                prefs.getString(rkEmailUser)!, appName);
            if (response.statusCode == 200) {
              print('save appList ${response.body}');
              var json = jsonDecode(response.body);
              if(json['statusCode'] == "OK") {
                await prefs.setBool('rkGetListAppInstall', true);
              }
            } else {
              print('gagal get appLits ${response.statusCode}');
            }
          }*/
        } else {
          if (prefs.getBool('rkGetListAppInstall') != null) {
            if (prefs.getBool('rkGetListAppInstall') == false) {
              List<Application> appData =
                  await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: false, onlyAppsWithLaunchIntent: false);
              List<dynamic> appName = [];
              for (int i = 0; i < appData.length; i++) {
                var cat = "";
                if (appData[i].category.toString().split('.')[1] == 'undefined') {
                  cat = "other";
                } else {
                  cat = appData[i].category.toString().split('.')[1];
                }
                appName.add({
                  "appName": appData[i].appName,
                  "packageId": appData[i].packageName,
                  "blacklist": false,
                  "appCategory": cat,
                });
              }
              Response response = await MediaRepository().saveAppList(prefs.getString(rkEmailUser)!, appName);
              if (response.statusCode == 200) {
                print('save appList ${response.body}');
                var json = jsonDecode(response.body);
                if (json['statusCode'] == 'OK') {
                  await prefs.setBool('rkGetListAppInstall', true);
                }
              } else {
                print('gagal get appLits ${response.statusCode}');
              }
            }
          } else {
            List<Application> appData =
                await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: false, onlyAppsWithLaunchIntent: false);
            List<dynamic> appName = [];
            for (int i = 0; i < appData.length; i++) {
              var cat = "";
              if (appData[i].category.toString().split('.')[1] == 'undefined') {
                cat = "other";
              } else {
                cat = appData[i].category.toString().split('.')[1];
              }
              appName.add({
                "appName": appData[i].appName,
                "packageId": appData[i].packageName,
                "blacklist": false,
                "appCategory": cat,
              });
            }
            Response response = await MediaRepository().saveAppList(prefs.getString(rkEmailUser)!, appName);
            if (response.statusCode == 200) {
              print('save appList ${response.body}');
              var json = jsonDecode(response.body);
              if (json['statusCode'] == "OK") {
                await prefs.setBool('rkGetListAppInstall', true);
              }
            } else {
              print('gagal get appLits ${response.statusCode}');
            }
          }
        }
      } else {
        if (prefs.getBool('rkGetListAppInstall') != null) {
          if (prefs.getBool('rkGetListAppInstall') == false) {
            List<Application> appData =
                await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: false, onlyAppsWithLaunchIntent: false);
            List<dynamic> appName = [];
            for (int i = 0; i < appData.length; i++) {
              var cat = "";
              if (appData[i].category.toString().split('.')[1] == 'undefined') {
                cat = "other";
              } else {
                cat = appData[i].category.toString().split('.')[1];
              }
              appName.add({
                "appName": appData[i].appName,
                "packageId": appData[i].packageName,
                "blacklist": false,
                "appCategory": cat,
              });
            }
            Response response = await MediaRepository().saveAppList(prefs.getString(rkEmailUser)!, appName);
            if (response.statusCode == 200) {
              print('save appList ${response.body}');
              var json = jsonDecode(response.body);
              if (json['statusCode'] == 'OK') {
                await prefs.setBool('rkGetListAppInstall', true);
              }
            } else {
              print('gagal get appLits ${response.statusCode}');
            }
          }
        } else {
          List<Application> appData =
              await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: false, onlyAppsWithLaunchIntent: false);
          List<dynamic> appName = [];
          for (int i = 0; i < appData.length; i++) {
            var cat = "";
            if (appData[i].category.toString().split('.')[1] == 'undefined') {
              cat = "other";
            } else {
              cat = appData[i].category.toString().split('.')[1];
            }
            appName.add({
              "appName": appData[i].appName,
              "packageId": appData[i].packageName,
              "blacklist": false,
              "appCategory": cat,
            });
          }
          Response response = await MediaRepository().saveAppList(prefs.getString(rkEmailUser)!, appName);
          if (response.statusCode == 200) {
            print('save appList ${response.body}');
            var json = jsonDecode(response.body);
            if (json['statusCode'] == "OK") {
              await prefs.setBool('rkGetListAppInstall', true);
            }
          } else {
            print('gagal get appLits ${response.statusCode}');
          }
        }
      }
    } else {
      print('isi response fetch appList : ${response.statusCode}');
      if (prefs.getBool('rkGetListAppInstall') != null) {
        if (prefs.getBool('rkGetListAppInstall') == false) {
          List<Application> appData =
              await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: false, onlyAppsWithLaunchIntent: false);
          List<dynamic> appName = [];
          for (int i = 0; i < appData.length; i++) {
            var cat = "";
            if (appData[i].category.toString().split('.')[1] == 'undefined') {
              cat = "other";
            } else {
              cat = appData[i].category.toString().split('.')[1];
            }
            appName.add({
              "appName": appData[i].appName,
              "packageId": appData[i].packageName,
              "blacklist": false,
              "appCategory": cat,
            });
          }
          Response response = await MediaRepository().saveAppList(prefs.getString(rkEmailUser)!, appName);
          if (response.statusCode == 200) {
            print('save appList ${response.body}');
            var json = jsonDecode(response.body);
            if (json['statusCode'] == 'OK') {
              await prefs.setBool('rkGetListAppInstall', true);
            }
          } else {
            print('gagal get appLits ${response.statusCode}');
          }
        }
      } else {
        List<Application> appData =
            await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: false, onlyAppsWithLaunchIntent: false);
        List<dynamic> appName = [];
        for (int i = 0; i < appData.length; i++) {
          var cat = "";
          if (appData[i].category.toString().split('.')[1] == 'undefined') {
            cat = "other";
          } else {
            cat = appData[i].category.toString().split('.')[1];
          }
          appName.add({
            "appName": appData[i].appName,
            "packageId": appData[i].packageName,
            "blacklist": false,
            "appCategory": cat,
          });
        }
        Response response = await MediaRepository().saveAppList(prefs.getString(rkEmailUser)!, appName);
        if (response.statusCode == 200) {
          print('save appList ${response.body}');
          var json = jsonDecode(response.body);
          if (json['statusCode'] == "OK") {
            await prefs.setBool('rkGetListAppInstall', true);
          }
        } else {
          print('gagal get appLits ${response.statusCode}');
        }
      }
    }
  }

  String getNameAppsFromList(String package) {
    String name = "";
    for (int i = 0; i < itemsApp.length; i++) {
      if (itemsApp[i].packageName == package) {
        name = itemsApp[i].appName;
      }
    }
    return name;
  }

  Application? getIconAppsFromList(String package) {
    for (int i = 0; i < itemsApp.length; i++) {
      if (itemsApp[i].packageName == package) {
        return itemsApp[i];
      }
    }
    return null;
  }

  Future<File> getImageFileFromAssets(String path, Uint8List? data) async {
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    // await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    await file.writeAsBytes(data!);

    return file;
  }

  void onSaveUsage(List<dynamic> data) async {
    prefs = await SharedPreferences.getInstance();
    var outputFormat = DateFormat('yyyy-MM-dd');
    var outputDate = outputFormat.format(DateTime.now());
    Response response = await MediaRepository().saveChildUsage(prefs.getString(rkEmailUser).toString(), outputDate, data);
    if (response.statusCode == 200) {
      print('isi response save app usage : ${response.body}');
    } else {
      print('isi response save app usage : ${response.statusCode}');
    }
  }

  Future _fetchContacts() async {
    prefs = await SharedPreferences.getInstance();
    if (!await FlutterContacts.requestPermission()) {
      setState(() => _permissionDenied = true);
    } else {
      if (prefs.getBool('rkGetContactList') != null) {
        if (prefs.getBool('rkGetContactList') == false) {
          final contacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: true);
          await prefs.setBool('rkGetContactList', true);
          onSaveContact(contacts);
        }
      } else {
        final contacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: true);
        await prefs.setBool('rkGetContactList', true);
        onSaveContact(contacts);
      }
    }
  }

  void onSaveContact(List<Contact> kontak) async {
    var contacts = [];
    var photo;
    for (int i = 0; i < kontak.length; i++) {
      var phonenum = [];
      for (int j = 0; j < kontak[i].phones.length; j++) {
        phonenum.add(kontak[i].phones[j].normalizedNumber);
      }
      contacts.add({"name": kontak[i].displayName, "nomor": phonenum, "blacklist": false});
    }

    Response response = await MediaRepository().saveContacts(prefs.getString(rkEmailUser).toString(), contacts);
    if (response.statusCode == 200) {
      print('isi response save contact : ${response.body}');
    } else {
      print('isi response save contact : ${response.statusCode}');
    }
  }

  void downloadTimeline() async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';
    try {
      myUrl = 'https://www.google.com/maps/timeline/kml?authuser=0&pb=!1m8!1m3!1i2021!2i4!3i1!2m3!1i2021!2i4!3i4';
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '/storage/emulated/0/Download/kml-timeline-01';
        file = File(filePath);
        await file.writeAsBytes(bytes);

        String kmlBase64 = base64Encode(File(file.path).readAsBytesSync());
        print('kml base 64 $kmlBase64');
      } else {
        filePath = 'Error code: ' + response.statusCode.toString();
      }
    } catch (ex) {
      filePath = 'Can not fetch url';
    }
  }

  void fetchUserLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied || _permissionGranted == PermissionStatus.deniedForever) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == PermissionStatus.denied || _permissionGranted == PermissionStatus.deniedForever) {
        return;
      }
    }

    _locationData = await location.getLocation();
    if (_locationData != null) {
      print('long : ${_locationData.longitude} & lat : ${_locationData.latitude}');
      onSaveLocation(_locationData);
    }
    location.onLocationChanged.listen((dataLocation) {
      if (dataLocation != null) {
        print('long : ${dataLocation.longitude} & lat : ${dataLocation.latitude}');
      }
    });
  }

  void onSaveLocation(LocationData locations) async {
    var outputFormat = DateFormat('yyyy-MM-dd');
    var outputDate = outputFormat.format(DateTime.now());
    Response response = await MediaRepository().saveUserLocation(prefs.getString(rkEmailUser).toString(), locations, outputDate);
    if (response.statusCode == 200) {
      print('isi response save location : ${response.body}');
    } else {
      print('isi response save location : ${response.statusCode}');
    }
  }

  void onGetIconApps() async {
    prefs = await SharedPreferences.getInstance();
    Response response = await MediaRepository().fetchAppIconList();
    if (response.statusCode == 200) {
      print('response load icon ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        var appIcons = json['appIcons'];
        await prefs.setString('rkBaseUrlAppIcon', json['baseUrl']);
        if (appIcons != null) {
          List<AppIconList> data = List<AppIconList>.from(appIcons.map((model) => AppIconList.fromJson(model)));

          List<Application> appData =
              await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: false, onlyAppsWithLaunchIntent: false);

          for (int i = 0; i < appData.length; i++) {
            bool flag = false;
            for (int j = 0; j < data.length; j++) {
              if (appData[i].packageName == data[j].appId) {
                flag = true;
                break;
              }
            }
            if (!flag) {
              listItemApps.add(appData[i]);
            }
          }

          onSaveIconApps(0);
        } else {
          List<Application> appData =
              await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: false, onlyAppsWithLaunchIntent: false);
          listItemApps = appData;
          onSaveIconApps(0);
        }
      }
    } else {
      print('response ${response.statusCode}');
    }
    /*if(prefs.getBool('rkGetListIcon') != null) {
      if(prefs.getBool('rkGetListIcon') == false) {
        List<Application> appData = await DeviceApps.getInstalledApplications(
            includeAppIcons: true,
            includeSystemApps: false,
            onlyAppsWithLaunchIntent: false
        );
        listItemApps = appData;
        await prefs.setBool('rkGetListIcon', true);
        onSaveIconApps(0);
      }
    }
    else {
      List<Application> appData = await DeviceApps.getInstalledApplications(
          includeAppIcons: true,
          includeSystemApps: false,
          onlyAppsWithLaunchIntent: false
      );
      listItemApps = appData;
      await prefs.setBool('rkGetListIcon', true);
      onSaveIconApps(0);
    }*/
  }

  void onSaveIconApps(int indeks) async {
    if (indeks < listItemApps.length) {
      Application? iconApp = listItemApps[indeks];
      var photo;
      if (iconApp is ApplicationWithIcon) {
        photo = "data:image/png;base64,${base64Encode(iconApp.icon)}";
      } else {
        photo = null;
      }
      var category = 'other';
      if (iconApp.category.toString().split('.')[1] != 'undefined') {
        category = iconApp.category.toString().split('.')[1];
      }
      Response response = await MediaRepository().saveIconApp(prefs.getString(rkEmailUser)!, iconApp.appName, iconApp.packageName, photo, category);
      if (response.statusCode == 200) {
        print('save iconApp ${response.body}');
        indeks++;
        if (indeks < listItemApps.length) {
          onSaveIconApps(indeks);
        }
      } else {
        print('gagal save icon app ${response.statusCode}');
        indeks++;
        if (indeks < listItemApps.length) {
          onSaveIconApps(indeks);
        }
      }
    }
  }

  void onGetCallLog(int indeks) async {
    prefs = await SharedPreferences.getInstance();
    if (indeks < blackListData.length) {
      var now = DateTime.now();
      int timestamps = prefs.getInt("timestamp") ?? 0;
      int from = 0;
      if (timestamps > 0) {
        from = timestamps;
      } else {
        from = now.subtract(Duration(days: 1)).millisecondsSinceEpoch;
      }
      // from = now.subtract(Duration(days: 1)).millisecondsSinceEpoch;
      int to = now.subtract(Duration(days: 0)).millisecondsSinceEpoch;
      if (blackListData[indeks].contact['name'] == null) {
        Iterable<CallLogEntry> entries = await CallLog.query(dateFrom: from, dateTo: to, number: '${blackListData[indeks].contact['phones'][0]}');
        print('data $entries');
        if (entries.length > 0) {
          await prefs.setInt("timestamp", entries.elementAt(0).timestamp ?? 0);
          var date = DateTime.fromMillisecondsSinceEpoch(entries.elementAt(0).timestamp! * 1000);
          Response response = await MediaRepository().blContactNotification(widget.email, entries.elementAt(0).name.toString(),
              entries.elementAt(0).number.toString(), date.toString(), entries.elementAt(0).callType.toString().split('.')[1]);

          if (response.statusCode == 200) {
            print('response notif blacklist ${response.body}');
            onGetCallLog(indeks++);
          } else {
            print('error blacklist notif ${response.statusCode}');
            onGetCallLog(indeks++);
          }
        }
      } else {
        Iterable<CallLogEntry> entries = await CallLog.query(dateFrom: from, dateTo: to, name: '${blackListData[indeks].contact['name']}');
        print('data $entries');
        if (entries.length > 0) {
          await prefs.setInt("timestamp", entries.elementAt(0).timestamp ?? 0);
          var date = DateTime.fromMillisecondsSinceEpoch(entries.elementAt(0).timestamp! * 1000);
          Response response = await MediaRepository().blContactNotification(widget.email, entries.elementAt(0).name.toString(),
              entries.elementAt(0).number.toString(), date.toString(), entries.elementAt(0).callType.toString().split('.')[1]);

          if (response.statusCode == 200) {
            print('response notif blacklist ${response.body}');
            onGetCallLog(indeks++);
          } else {
            print('error blacklist notif ${response.statusCode}');
            onGetCallLog(indeks++);
          }
        }
      }
    }
  }

  void onLogin() async {
    String token = '';
    await _firebaseMessaging.getToken().then((fcmToken) {
      token = fcmToken!;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await MediaRepository().loginParent(widget.email, prefs.getString(accessGToken)!, token, '1.0');
    print('response login ${response.body}');
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonDataResult = json['resultData'];
        var tokenApps = jsonDataResult['token'];
        await prefs.setString(rkTokenApps, tokenApps);
        var jsonUser = jsonDataResult['user'];
        var blackList = jsonUser['blacklistNumbers'];
        List<BlackListContact> data = List<BlackListContact>.from(blackList.map((model) => BlackListContact.fromJson(model)));
        if (data != null && data.length > 0) {
          blackListData = data;
          onGetCallLog(0);
        }
      }
    } else {
      print('no user found');
    }
  }

  void onGetSMS() async {
    SmsQuery query = new SmsQuery();
  }

  void onMessageListen() {
    FirebaseMessaging.instance.getInitialMessage().then((value) => {
          if (value != null) {print('remote message ${value.data}')}
        });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      // if(message.data.length > 0) {
      //   flutterLocalNotificationsPlugin.show(
      //       message.data.hashCode,
      //       message.data['title'],
      //       message.data['content'],
      //       NotificationDetails(
      //         android: AndroidNotificationDetails(
      //           channel.id,
      //           channel.name,
      //           channel.description,
      //           // TODO add a proper drawable resource to android, for now using
      //           //      one that already exists in example app.
      //           icon: android?.smallIcon,
      //         ),
      //       ));
      // } else
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name, channel.description,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  icon: 'launch_background',
                  styleInformation: BigTextStyleInformation(notification.body.toString())),
            ));
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onMessageListen();
    onLogin();
    onGetIconApps();
    getUsageStatistik();
    _fetchContacts();
    getDataListApps();
    fetchUserLocation();
    // onUsageNew();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "ruang",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 18),
                ),
                Text(
                  " keluarga",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffFF018786), fontSize: 18),
                )
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white70,
        iconTheme: IconThemeData(color: Colors.grey.shade700),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications,
              color: Colors.grey.shade700,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.mail_outline,
              color: Colors.grey.shade700,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.help,
              color: Colors.grey.shade700,
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
// Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff3BDFD2),
                    Color(0xff05745F),
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
                            '${widget.name}',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      Container(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '${widget.email}',
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
              title: Text('SOS'),
              leading: Icon(Icons.add_ic_call, color: Colors.black),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
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
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK', style: TextStyle(color: Color(0xff05745F))),
                            ),
                          ],
                        )))
          ],
        ),
      ),
      body: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(30), bottomLeft: Radius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Align(
                child: Text(
                  'Jangan Panik! Tekan tombol SOS\njika kamu dalam kondisi darurat',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            Container(
              height: 40,
              width: 100,
              margin: EdgeInsets.only(right: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Align(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.add_ic_call,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(left: 10.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'SOS',
                            style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SOSRecordVideoPage()));
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
