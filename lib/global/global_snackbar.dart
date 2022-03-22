import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

void showToastSuccess({required String successText, required BuildContext ctx}) {
  FToast().init(ctx).showToast(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Color(0xff05745F),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(
                width: 12.0,
              ),
              Flexible(child: Text(successText, style: TextStyle(color: Colors.white, fontSize: 12))),
            ],
          ),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
      );
}

void showToastFailed({required String failedText, required BuildContext ctx}) {
  FToast().init(ctx).showToast(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.redAccent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close, color: Colors.white),
              SizedBox(
                width: 12.0,
              ),
              Text(failedText, style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
      );

  showToastFailed({required String failedText, required BuildContext ctx}) {
    FToast().init(ctx).showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.redAccent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close, color: Colors.white),
            SizedBox(
              width: 12.0,
            ),
            Text(failedText, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }
}
