import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RKServiceController extends GetxController {
  late PackageInfo appInfo;

  @override
  void onInit() async {
    super.onInit();
    appInfo = await PackageInfo.fromPlatform();
  }
}
