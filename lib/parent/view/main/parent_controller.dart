import 'dart:convert';

import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_child_model.dart';
import 'package:ruangkeluarga/parent/view/home_parent.dart';
import 'package:ruangkeluarga/parent/view/main/parent_model.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';

class ParentController extends GetxController {
  String userName = '';
  String emailUser = '';
  late SharedPreferences prefs;
  late ParentProfile parentProfile;
  Rx<Future<List<Child>>> fChildList = Future<List<Child>>.value(<Child>[]).obs;
  RxMap _modeAsuh = <int, int>{}.obs;
  var _bottomNavIndex = 0.obs;

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
  }

  void initAsync() async {
    prefs = await SharedPreferences.getInstance();
  }

  void getParentChildData() {
    fChildList.value = _getUserData();
  }

  Future loginData() async {
    fChildList.value = onLogin();
  }

  Future<List<Child>> _getUserData() async {
    prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString(rkUserID);
    Response response = await MediaRepository().getParentChildData(userID ?? '');
    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body)['user'];
      parentProfile = ParentProfile.fromJson(jsonUser);
      return parentProfile.children;
    }
    return [];
  }

  Future<List<Child>> onLogin() async {
    prefs = await SharedPreferences.getInstance();
    String token = '';
    await firebaseMessaging.getToken().then((fcmToken) {
      token = fcmToken!;
    });
    Response response = await MediaRepository().loginParent(prefs.getString(rkEmailUser)!, prefs.getString(accessGToken)!, token, '1.0');
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
          final childsData = parentProfile.children;
          if (childsData.length > 0) {
            await prefs.setString(rkUserID, parentProfile.id);
            await prefs.setString(rkUserType, parentProfile.userType);
            await prefs.setString("rkChildName", childsData[0].name ?? "");
            await prefs.setString("rkChildEmail", childsData[0].email ?? "");
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
}
