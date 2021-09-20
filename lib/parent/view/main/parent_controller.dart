import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_child_model.dart';
import 'package:ruangkeluarga/parent/view/main/parent_main.dart';
import 'package:ruangkeluarga/parent/view/main/parent_model.dart';
import 'package:ruangkeluarga/parent/view_model/gereja_hkbp_model.dart';
import 'package:ruangkeluarga/parent/view_model/inbox_notification_model.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';

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
  RxMap _modeAsuh = <int, int>{}.obs;

  ///INBOX DATA
  var inboxData = <InboxNotif>[];
  var unreadNotif = 0.obs;

  ///LIST GEREJA HKBP
  List<GerejaHKBP> listGereja = [];

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
    getListGerejaHKBP();
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
    Response response = await MediaRepository().getParentChildData(userID ?? '');
    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body)['user'];
      parentProfile = ParentProfile.fromJson(jsonUser);
      return parentProfile.children ?? [];
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
    Response response = await MediaRepository().userLogin(prefs.getString(rkEmailUser)!, prefs.getString(accessGToken)!, token, '1.0');
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
    Response res = await MediaRepository().fetchParentInbox(parentProfile.email);
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
              showToastSuccess(ctx: Get.context!, successText: 'Berhasil menghapus notifikasi');
            } else
              showToastFailed(ctx: Get.context!, failedText: 'Gagal menghapus notifikasi');
          },
          child: Text('Hapus', style: TextStyle(color: cOrtuBlue)),
        ),
      ],
    ));
  }

  Future getListGerejaHKBP() async {
    Response res = await MediaRepository().fetchGerejaHKBP();
    if (res.statusCode == 200) {
      print('print res getListGerejaHKBP ${res.body}');
      final json = jsonDecode(res.body);
      if (json['resultCode'] == "OK") {
        List HKBPData = json['HKBPData'];
        listGereja = HKBPData.map((e) => GerejaHKBP.fromJson(e)).toList();
        update();
      }
    }
  }
}
