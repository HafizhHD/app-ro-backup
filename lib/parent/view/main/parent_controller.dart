import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_child_model.dart';
import 'package:ruangkeluarga/model/rk_spouse_model.dart';
import 'package:ruangkeluarga/parent/view/main/parent_main.dart';
import 'package:ruangkeluarga/parent/view/main/parent_model.dart';
import 'package:ruangkeluarga/parent/view_model/appUsage_model.dart';
// import 'package:ruangkeluarga/parent/view_model/gereja_hkbp_model.dart';
import 'package:ruangkeluarga/parent/view_model/inbox_notification_model.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import 'package:usage_stats/usage_stats.dart';

class ParentController extends GetxController {
  ///ParentData Locale
  String userName = '';
  String userId = '';
  String emailUser = '';
  var _bottomNavIndex = 2.obs;
  bool hasLogin = false;

  /// Parent Data Fetch
  late SharedPreferences prefs;
  late ParentProfile parentProfile;
  Rx<Future<List<Child>>> fChildList = Future<List<Child>>.value(<Child>[]).obs;
  Rx<Future<List<Spouse>>> fSpouseList =
      Future<List<Spouse>>.value(<Spouse>[]).obs;
  List<Spouse> spouseList = [];
  RxMap _modeAsuh = <int, int>{}.obs;

  ///INBOX DATA
  var inboxData = <InboxNotif>[];
  var unreadNotif = 0.obs;

  ///Child Activity Detail
  Map<String, List<AppUsages>> mapChildActivity = {},
      mapChildActivityDaily = {};
  Map<String, String> mapChildScreentime = {},
      mapChildScreentimeGaming = {},
      mapChildScreentimeSocial = {},
      mapChildScreentimeDaily = {};

  ///Getter & Setter
  int get bottomNavIndex => _bottomNavIndex.value;

  void setBottomNavIndex(int index) {
    _bottomNavIndex.value = index;
    // update();
  }

  void setModeAsuh(int childIndex, int value) {
    _modeAsuh[childIndex] = value;
    update();
  }

  void setParentProfile(ParentProfile p) {
    //tg
    parentProfile = p;
    update();
  }

  void logoutParent() {
    hasLogin = false;
    update();
  }

  int getmodeAsuh(int childIndex) => _modeAsuh[childIndex];

  @override
  void onInit() {
    super.onInit();
    initAsync();
    getBinding();
  }

  void getBinding() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString(rkUserName) ?? '';
    emailUser = prefs.getString(rkEmailUser) ?? '';
    update();
  }

  void initAsync() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future getParentChildData() async {
    fChildList.value = _getUserData();
    await fChildList.value;
    update();
  }

  Future loginData() async {
    fChildList.value = onLogin();
  }

  Future futureHasLogin() async {
    await fChildList.value;
  }

  Future<List<Child>> _getUserData() async {
    prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString(rkUserID);
    Response response =
        await MediaRepository().getParentChildData(userID ?? '');
    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body)['user'];
      if (jsonDecode(response.body)['resultCode'] == "OK") {
        parentProfile = ParentProfile.fromJson(jsonUser);
        spouseList = parentProfile.spouse ?? [];
        return parentProfile.children ?? [];
      } else {
        logUserOut();
        return [];
      }
    }
    return [];
  }

  Future<List<Child>> onLogin() async {
    if (hasLogin) return parentProfile.children ?? [];
    prefs = await SharedPreferences.getInstance();
    String token = '';
    await firebaseMessaging.getToken().then((fcmToken) {
      token = fcmToken!;
    });
    Response response = await MediaRepository().userLogin(
        prefs.getString(rkEmailUser)!,
        prefs.getString(accessGToken)!,
        token,
        '1.0');
    if (response.statusCode == 200) {
      print("user exist ${response.body}");
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonDataResult = json['resultData'];
        var tokenApps = jsonDataResult['token'];
        await prefs.setString(rkTokenApps, tokenApps);
        var jsonUser = jsonDataResult['user'];
        print('jsonUser = $jsonUser');

        if (jsonUser != null) {
          parentProfile = ParentProfile.fromJson(jsonUser);
          final childsData = parentProfile.children ?? [];
          getInboxNotif();
          getWeeklyUsageStatistic();
          getDailyUsageStatistic();
          if (childsData.length > 0) {
            await prefs.setString(rkUserID, parentProfile.id);
            await prefs.setString(rkUserType, parentProfile.userType);
            await prefs.setString("rkChildName", childsData[0].name ?? "");
            await prefs.setString("rkChildEmail", childsData[0].email ?? "");
            hasLogin = true;
            return childsData;
          }
          return [];
        } else {
          return [];
        }
      } else {
        return [];
      }
    } else if (response.statusCode == 404) {
      return [];
    } else {
      return [];
    }
  }

  Future getAppIconList() async {
    Response res = await MediaRepository().fetchAppIconList();
    if (res.statusCode == 200) {
      print('print res fetchAppIconList ${res.body}');
      final json = jsonDecode(res.body);
      if (json['resultCode'] == "OK") {
        await prefs.setString(rkListAppIcons, res.body);
        await prefs.setString(rkBaseUrlAppIcon, json['baseUrl']);
      }
    }
  }

  Future getInboxNotif() async {
    Response res =
        await MediaRepository().fetchParentInbox(parentProfile.email);
    if (res.statusCode == 200) {
      print('print res fetchParentInbox ${res.body}');
      final json = jsonDecode(res.body);
      if (json['resultCode'] == "OK") {
        unreadNotif.value = 0;
        final List dataInbox = json['inbox'];
        inboxData = dataInbox.map((e) {
          final notif = InboxNotif.fromJson(e);
          if (!notif.readStatus) unreadNotif.value++;
          return notif;
        }).toList();
        inboxData.sort((a, b) => b.createAt.compareTo(a.createAt));
        update();
      }
    }
  }

  Future readNotifByID(String id, int index) async {
    Response res = await MediaRepository().updateReadNotif(id);
    if (res.statusCode == 200) {
      print('print res updateReadNotif ${res.body}');
      final json = jsonDecode(res.body);
      if (json['resultCode'] == "OK") {
        inboxData[index].readStatus = true;
        unreadNotif.value--;
        update();
      }
    }
  }

  Future<bool?> deleteNotif(String notifID) async {
    return Get.dialog<bool>(AlertDialog(
      title: Text('Hapus Notifikasi'),
      content: Text('Yakin ingin menghapus notifikasi ini?'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(result: false);
          },
          child: Text('Batal', style: TextStyle(color: cOrtuBlue)),
        ),
        TextButton(
          onPressed: () async {
            showLoadingOverlay();
            final response = await MediaRepository().removeInboxNotif(notifID);
            if (response.statusCode == 200) {
              await getInboxNotif();
              closeOverlay();
              closeOverlay();
              showToastSuccess(
                  ctx: Get.context!,
                  successText: 'Berhasil menghapus notifikasi');
            } else
              showToastFailed(
                  ctx: Get.context!, failedText: 'Gagal menghapus notifikasi');
          },
          child: Text('Hapus', style: TextStyle(color: cOrtuBlue)),
        ),
      ],
    ));
  }

  ///child activity
  DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }

  DateTime findLastDateOfTheWeek(DateTime dateTime) {
    return dateTime
        .add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }

  DateTime findFirstHourOfTheDay(DateTime dateTime) {
    return dateTime.subtract(Duration(
        hours: dateTime.hour,
        minutes: dateTime.minute,
        seconds: dateTime.second,
        milliseconds: dateTime.millisecond));
  }

  DateTime findLastHourOfTheDay(DateTime dateTime) {
    return dateTime.add(Duration(
        hours: 23 - dateTime.hour,
        minutes: 59 - dateTime.minute,
        seconds: 59 - dateTime.second,
        milliseconds: 999 - dateTime.millisecond));
  }

  Future getWeeklyUsageStatistic() async {
    var outputFormat = DateFormat('yyyy-MM-dd');
    var startDate = outputFormat.format(findFirstDateOfTheWeek(DateTime.now()));
    var endDate = outputFormat.format(findLastDateOfTheWeek(DateTime.now()));
    if (parentProfile.children != null) {
      parentProfile.children!.forEach((child) async {
        Response response = await MediaRepository()
            .fetchAppUsageFilterRange(child.email!, startDate, endDate);
        if (response.statusCode == 200) {
          int seconds = 0, secondsGaming = 0, secondsSocial = 0;
          // print('isi response filter app usage : ${response.body}');
          var json = jsonDecode(response.body);
          if (json['resultCode'] == "OK") {
            var jsonDataResult = json['appUsages'] as List;
            final listAppUsage =
                jsonDataResult.map((e) => AppUsages.fromJson(e)).toList();
            mapChildActivity[child.email!] = listAppUsage;
            listAppUsage.forEach((appUsage) {
              appUsage.appUsagesDetail.forEach((e) {
                seconds += e.duration;
                if (e.appCategory == 'game') secondsGaming += e.duration;
                if (e.appCategory == 'social') secondsSocial += e.duration;
              });
            });
          }
          mapChildScreentime[child.email!] = setAverageDaily(seconds ~/ 1000);
          mapChildScreentimeGaming[child.email!] =
              setAverageDaily(secondsGaming ~/ 1000);
          mapChildScreentimeSocial[child.email!] =
              setAverageDaily(secondsSocial ~/ 1000);
          update();
        }
      });
    }
  }

  Future getDailyUsageStatistic() async {
    //var outputFormat = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS');
    var outputFormat = DateFormat('yyyy-MM-dd');
    print('Ini tgl sekarang: ${outputFormat.format(DateTime.now())}');
    var startDate = outputFormat.format(findFirstHourOfTheDay(DateTime.now()));
    var endDate = outputFormat.format(findLastHourOfTheDay(DateTime.now()));
    print('Ini start date: $startDate, end date: $endDate');

    List<UsageInfo> usageInfo = await UsageStats.queryUsageStats(
        findFirstHourOfTheDay(DateTime.now()),
        findLastHourOfTheDay(DateTime.now()));

    usageInfo.forEach((e) {
      // print('Ini nama pekejnya ${e.packageName}');
      // print(
      //     'Ini pertama dipake ${DateTime.fromMillisecondsSinceEpoch(int.parse(e.firstTimeStamp!))}');
      // print(
      //     'Ini terakhir dipake ${DateTime.fromMillisecondsSinceEpoch(int.parse(e.lastTimeStamp!))}');
    });

    if (parentProfile.children != null) {
      parentProfile.children!.forEach((child) async {
        Response response = await MediaRepository()
            .fetchAppUsageFilterRange(child.email!, startDate, endDate);
        if (response.statusCode == 200) {
          int seconds = 0;
          // print('isi response filter app usage punya Daily : ${response.body}');
          var json = jsonDecode(response.body);
          if (json['resultCode'] == "OK") {
            var jsonDataResult = json['appUsages'] as List;
            final listAppUsage =
                jsonDataResult.map((e) => AppUsages.fromJson(e)).toList();
            mapChildActivityDaily[child.email!] = listAppUsage;
            listAppUsage.forEach((appUsage) {
              appUsage.appUsagesDetail.forEach((e) {
                e.usageHour!.forEach((h) {
                  var startTimeStamp = DateTime.parse(h['lastTimeStamp'])
                      .subtract(Duration(
                          milliseconds: int.parse(h['durationInStamp'])));
                  Duration dur = DateTime.parse(h['lastTimeStamp'])
                      .difference(findFirstHourOfTheDay(DateTime.now()));
                  Duration durStart = startTimeStamp
                      .difference(findFirstHourOfTheDay(DateTime.now()));
                  print('dur: $dur, dur2: $durStart');
                  if (durStart.inSeconds < 0) if (dur.inSeconds >= 0)
                    seconds += dur.inMilliseconds;
                  else
                    seconds += int.parse(h['durationInStamp']);
                });
              });
            });
          }
          // seconds ~/= 1000;
          // print('total durationnya: $seconds detik');
          mapChildScreentimeDaily[child.email!] =
              setAverageDaily(seconds ~/ 1000);
          update();
        }
      });
    }
  }

  String setAverageDaily(int secs) {
    String avgData = '0s';
    if (secs > 0) {
      int tmpAvg = secs ~/ 1;
      int totalHour = 0;
      if (tmpAvg >= 3600) {
        totalHour = tmpAvg ~/ 3600;
        tmpAvg = tmpAvg - (totalHour * 3600);
      }
      int totalMenit = 0;
      if (tmpAvg >= 60) {
        totalMenit = tmpAvg ~/ 60;
        tmpAvg = tmpAvg - (totalMenit * 60);
      }
      if (totalHour == 0) {
        if (totalMenit == 0) {
          avgData = '${tmpAvg}s';
        } else {
          avgData = '${totalMenit}m ${tmpAvg}s';
        }
      } else {
        avgData = '${totalHour}h ${totalMenit}m';
      }
    }
    return avgData;
  }
}
