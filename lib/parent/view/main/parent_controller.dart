import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentController extends GetxController {
  String userName = '';
  String emailUser = '';
  var _bottomNavIndex = 0.obs;

  int get bottomNavIndex => _bottomNavIndex.value;

  void setBottomNavIndex(int index) {
    _bottomNavIndex.value = index;
    // update();
  }

  @override
  void onInit() {
    super.onInit();
    getBinding();
  }

  void getBinding() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString(rkUserName) ?? '';
    emailUser = prefs.getString(rkEmailUser) ?? '';
  }
}
