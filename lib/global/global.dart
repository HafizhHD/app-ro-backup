//export global files
export 'global_colors.dart';
export 'global_navigator_transition.dart';
export 'custom_widget/global_widget.dart';
export 'custom_widget/toggle_bar.dart';
export 'global_formatter.dart';
export 'global_snackbar.dart';
export 'global_enum.dart';

import 'package:permission_handler/permission_handler.dart';

///CONSTANT
const keyboardHeight = 150;
const appName = "Keluarga HKBP";

final String isPrefLogin = "isPrefLogin";
final String rkUserID = "rkUserID";
final String rkEmailUser = "rkEmailUser";
final String rkUserName = "rkUserName";
final String rkPhotoUrl = "rkPhotoUrl";
final String accessGToken = "accessGToken";
final String rkTokenApps = "rkTokenApps";
final String rkUserType = "rkUserType";
final String rkChilds = "rkChilds";
final String rkListAppIcons = "rkListAppIcons";
final String rkBaseUrlAppIcon = "rkBaseUrlAppIcon";

const AppIconPathRO = 'assets/images/ruangortu-icon.png';
const AppIconPathRO_x4 = 'assets/images/ruangortu-icon_4.png';
const AppIconPathHKBP = 'assets/images/hkbp/logo-keluargahkbp.png';
const currentAppIconPath = AppIconPathHKBP;

const ApkDownloadURL = 'https://drive.google.com/drive/folders/1U5V9ZbUel3O0kNBw96O4TY0m7TrLnTwe?usp=sharing';
const ApkDownloadURL_HKBP = 'https://drive.google.com/drive/folders/1nlj_EiHgD6goR-JTsdCaIfeomVHUFsNr?usp=sharing';

final urlPP = 'https://keluargahkbp.com/toc/privacy_policy_bahasa.html';
final urlTOC = 'https://keluargahkbp.com/toc/toc_bahasa.html';

Future<bool> childNeedPermission() async {
  final locationHandler = await Permission.location.status;
  final contactHandler = await Permission.contacts.status;
  final phoneHandler = await Permission.phone.status;
  final cameraHandler = await Permission.camera.status;
  final audioHandler = await Permission.microphone.status;
  // final smsHandler = await Permission.sms.status;
  print('Permision Status location : $locationHandler');
  print('Permision Status contact : $contactHandler');
  print('Permision Status phone : $phoneHandler');
  print('Permision Status camera : $cameraHandler');
  print('Permision Status microphone : $audioHandler');
  // print('Permision Status sms : $smsHandler');
  return locationHandler.isDenied || contactHandler.isDenied || phoneHandler.isDenied || cameraHandler.isDenied || audioHandler.isDenied;
}
