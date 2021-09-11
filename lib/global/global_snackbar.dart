import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';

void closeOpenDialogs() {
  if ((Get.isBottomSheetOpen ?? false) || (Get.isDialogOpen ?? false) || Get.isOverlaysOpen || (Get.isSnackbarOpen ?? false)) Get.back();
}

void showSnackbar(
  String pText, {
  Color bgColor = cOrtuBlue,
  Duration pShowDuration = const Duration(seconds: 4),
  SnackPosition position = SnackPosition.BOTTOM,
}) {
  closeOpenDialogs();
  Get.snackbar(
    "", //title
    "", //message
    titleText: Center(
      child: Padding(
          padding: EdgeInsets.all(5),
          child: Text(
            pText,
            style: TextStyle(color: cPrimaryBg, fontSize: 15),
            textAlign: TextAlign.left,
          )),
    ),
    backgroundColor: bgColor,
    colorText: cPrimaryBg,
    snackPosition: position,
    messageText: SizedBox(),
    borderRadius: 10,
    isDismissible: false,
    duration: pShowDuration,
  );
}

void showSnackbarSuccessWithTap(String pText, {required Function() fOnTap, Duration pShowDuration = const Duration(seconds: 5)}) {
  closeOpenDialogs();
  Get.snackbar(
    "", //title
    "", //message
    titleText: Center(
      child: Padding(
          padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
          child: Text(
            pText,
            style: TextStyle(color: cOrtuWhite, fontSize: 15),
            textAlign: TextAlign.left,
          )),
    ),
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: cOrtuWhite,
    colorText: Colors.white,
    messageText: SizedBox(),
    // icon: Padding(
    //   padding:
    //       EdgeInsets.only(left: SizeConfig.dPaddingFixShortSmall, top: SizeConfig.dPaddingFixShortSmall, bottom: SizeConfig.dPaddingFixShortSmall),
    //   child: Image.asset(
    //     'assets/images/snackbar-success.png',
    //   ),
    // ),
    // padding: EdgeInsets.only(
    //   left: SizeConfig.dPaddingFixShortMedium,
    //   right: SizeConfig.dPaddingFixShortMedium,
    // ),
    // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
    duration: pShowDuration,
    mainButton: TextButton(
        onPressed: fOnTap,
        child: Text(
          'Buka file',
          textAlign: TextAlign.justify,
          style: TextStyle(color: cOrtuOrange),
        )),
  );
}

Future<bool> onWillPopApp() async {
  final bool res = await Get.dialog(AlertDialog(
    title: new Text('Konfirmasi tutup', style: new TextStyle(fontSize: 20.0)),
    content: new Text('Yakin ingin menutup aplikasi?'),
    actions: <Widget>[
      new TextButton(
        onPressed: () {
          Get.back(result: true);
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        },
        child: new Text('Ya', style: new TextStyle(color: cOrtuBlue)),
      ),
      new TextButton(
        onPressed: () {
          Get.back(result: false);
        },
        child: new Text('Tidak', style: new TextStyle(color: cOrtuBlue)),
      )
    ],
  ));

  return res;
}
