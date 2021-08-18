import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global_colors.dart';

Future showLoadingOverlay() {
  return Get.dialog(
      Container(
        color: Colors.transparent,
        child: Center(
          child: wProgressIndicator(),
        ),
      ),
      barrierDismissible: false);
}

Widget wProgressIndicator() {
  return Center(
    child: CircularProgressIndicator(color: cOrtuOrange),
  );
}

void closeOverlay({bool all = false}) {
  Get.back(closeOverlays: all);
}
