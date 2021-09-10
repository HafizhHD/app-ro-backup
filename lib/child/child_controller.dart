import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:ruangkeluarga/child/child_model.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/global/global_formatter.dart';
import 'package:ruangkeluarga/main.dart';
import 'package:ruangkeluarga/model/rk_child_apps.dart';
import 'package:ruangkeluarga/plugin_device_app.dart';
import 'package:ruangkeluarga/utils/app_usage.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildController extends GetxController {
  var _bottomNavIndex = 0.obs;
  var childID = '';
  var childEmail = '';
  late ChildProfile childProfile;
  late Timer locationPeriodic;

  Location location = new Location();

  int get bottomNavIndex => _bottomNavIndex.value;
  void setBottomNavIndex(int index) {
    _bottomNavIndex.value = index;
    // update();
  }

  void initData() async {
    await getChildData().then((value) {
      onMessageListen();
      fetchChildLocation();
      saveCurrentAppList();
      fetchContacts();
      // onGetSMS();
      getAppUsageData();
    });
  }

  @override
  void onClose() {
    locationPeriodic.cancel();
    super.onClose();
  }

  void onMessageListen() {
    FirebaseMessaging.instance.getInitialMessage().then((value) => {
          if (value != null) {print('remote message ${value.data}')}
        });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
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

  Future getChildData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await MediaRepository().getParentChildData(prefs.getString(rkUserID) ?? '');
    print('response getChildData: ${response.body}');
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonUser = json['user'];
        childProfile = ChildProfile.fromJson(jsonUser);
        childID = childProfile.id;
        childEmail = childProfile.email;
        // var blackList = jsonUser['blacklistNumbers'];
        // List<BlackListContact> data = List<BlackListContact>.from(blackList.map((model) => BlackListContact.fromJson(model)));
        // if (data != null && data.length > 0) {
        //   blackListData = data;
        //   onGetCallLog(0);
        // }
        update();
      }
    } else {
      print('no user found');
    }
  }

  Future<List<ApplicationInstalled>> getListAppServer() async {
    Response response = await MediaRepository().fetchAppList(childEmail);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['appdevices'].length > 0) {
        List appDevices = json['appdevices'][0]['appName'];
        return appDevices.map((e) => ApplicationInstalled.fromJson(e)).toList();
      }
    }
    return [];
  }

  void saveCurrentAppList() async {
    final listAppServer = await getListAppServer();
    final listAppLocal = await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: false, onlyAppsWithLaunchIntent: false);
    listAppLocal.forEach((localApp) async {
      final cat = localApp.category.toString().split('.')[1];
      await MediaRepository().saveIconApp(
        childEmail,
        localApp.appName,
        localApp.packageName,
        localApp is ApplicationWithIcon ? "data:image/png;base64,${base64Encode(localApp.icon)}" : '',
        cat == 'undefined' ? 'other' : cat,
      );
    });

    final listAppsOK = listAppLocal.map((localApp) {
      final cat = localApp.category.toString().split('.')[1];
      final onServerApp = listAppServer.where((serverApp) => serverApp.packageId == localApp.packageName).toList();
      final isBlacklist = onServerApp.length > 0 ? onServerApp.first.blacklist : false;

      return ApplicationInstalled(
        appName: localApp.appName,
        packageId: localApp.packageName,
        blacklist: isBlacklist,
        appCategory: cat == 'undefined' ? 'other' : cat,
      );
    }).toList();

    Response response = await MediaRepository().saveAppList(childEmail, listAppsOK);
    if (response.statusCode == 200) {
      print('save appList ${response.body}');
    } else {
      print('gagal simpan appList ${response.statusCode}');
    }
  }

  void fetchChildLocation() async {
    var _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    var _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied || _permissionGranted == PermissionStatus.deniedForever) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == PermissionStatus.denied || _permissionGranted == PermissionStatus.deniedForever) {
        return;
      }
    }

    try {
      await location.changeSettings(interval: 1000);
      await location.getLocation().then((locData) async {
        await MediaRepository().saveUserLocation(childEmail, locData, now_ddMMMyyyyHHmmss()).then((response) {
          if (response.statusCode == 200) {
            print('isi response save location Current: ${response.body}');
          } else {
            print('isi response save location Current: ${response.statusCode}');
          }
        });
      });

      locationPeriodic = Timer.periodic(Duration(hours: 1), (timer) async {
        print('timer save location $timer');
        await location.getLocation().then((locData) async {
          await MediaRepository().saveUserLocation(childEmail, locData, now_ddMMMyyyyHHmmss()).then((response) {
            if (response.statusCode == 200) {
              print('isi response save location : ${response.body}');
            } else {
              print('isi response save location : ${response.statusCode}');
            }
          });
        });
      });
    } catch (e, s) {
      print('err: $e');
      print('stk: $s');
    }
  }

  Future fetchContacts() async {
    var permission = await FlutterContacts.requestPermission();
    if (permission) {
      final kontak = await FlutterContacts.getContacts(withProperties: true, withPhoto: true);
      var contacts = [];
      for (int i = 0; i < kontak.length; i++) {
        var phoneNum = [];
        for (int j = 0; j < kontak[i].phones.length; j++) {
          phoneNum.add(kontak[i].phones[j].normalizedNumber);
        }
        var photo = kontak[i].photo;
        contacts.add({"name": kontak[i].displayName, "nomor": phoneNum, "blacklist": false});
      }

      Response response = await MediaRepository().saveContacts(childEmail, contacts);
      if (response.statusCode == 200) {
        print('isi response save contact : ${response.body}');
      } else {
        print('isi response save contact : ${response.statusCode}');
      }
    }
  }

  void onGetSMS() async {
    SmsQuery query = new SmsQuery();
    final listSms = await query.getAllSms;
    listSms.forEach((sms) {
      print(sms.sender);
      print(sms.address);
      print(sms.body);
    });
  }

  void getAppUsageData() async {
    final DateTime endDate = new DateTime.now();
    final DateTime startDate = endDate.subtract(Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute, seconds: DateTime.now().second));
    final List<AppUsageInfo> infoList = await AppUsage.getAppUsage(startDate, endDate);
    final listAppLocal = await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: false, onlyAppsWithLaunchIntent: false);

    List<dynamic> usageDataList = [];
    infoList.forEach((app) {
      final hasData = listAppLocal.where((e) => e.packageName == app.packageName).toList();
      if (hasData.length > 0) {
        final appName = hasData.first.appName;
        final cat = hasData.first.category.toString().split('.')[1];
        var temp = {
          'count': 0,
          'appName': appName,
          'packageId': app.packageName,
          'duration': app.usage.inSeconds,
          'appCategory': cat == 'undefined' ? 'other' : cat,
        };
        usageDataList.add(temp);
      }
    });

    Response response = await MediaRepository().saveChildUsage(childEmail, now_yyyyMMdd(), usageDataList);
    if (response.statusCode == 200) {
      print('isi response save app usage : ${response.body}');
    } else {
      print('isi response save app usage : ${response.statusCode}');
    }
  }
}
