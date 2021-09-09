import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import 'package:ruangkeluarga/child/child_model.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/main.dart';
import 'package:ruangkeluarga/model/rk_child_apps.dart';
import 'package:ruangkeluarga/plugin_device_app.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildController extends GetxController {
  var _bottomNavIndex = 0.obs;
  var childID = '';
  var childEmail = '';
  late ChildProfile childProfile;

  int get bottomNavIndex => _bottomNavIndex.value;
  void setBottomNavIndex(int index) {
    _bottomNavIndex.value = index;
    // update();
  }

  void initData() async {
    onMessageListen();
    getChildData();
    saveCurrentAppList();
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

  void getChildData() async {
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
    final listAppLocal = await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: false, onlyAppsWithLaunchIntent: false);
    final listAppServer = await getListAppServer();

    final listAppsOK = listAppLocal.map((localApp) {
      final cat = localApp.category.toString().split('.')[1];
      final onServerApp = listAppServer.where((serverApp) => serverApp.packageId == localApp.packageName).toList();
      final isBlacklist = onServerApp.length > 0 ? onServerApp.first.blacklist : false;
      return ApplicationInstalled(
        appName: localApp.appName,
        packageId: localApp.packageName,
        blacklist: isBlacklist,
        appCategory: cat == 'undefined' ? 'other' : cat,
        appIcon: localApp is ApplicationWithIcon ? "data:image/png;base64,${base64Encode(localApp.icon)}" : '',
      );
    }).toList();

    Response response = await MediaRepository().saveAppList(childEmail, listAppsOK);
    if (response.statusCode == 200) {
      print('save appList ${response.body}');
    } else {
      print('gagal simpan appList ${response.statusCode}');
    }
  }
}
