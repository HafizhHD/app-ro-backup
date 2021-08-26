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

class WSearchBar extends StatelessWidget {
  final Function(String)? fOnChanged;
  final TextEditingController? tecController;
  final String hintText;
  WSearchBar({this.fOnChanged, this.tecController, this.hintText = "Cari"});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: cOrtuWhite, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Padding(
          //   padding: EdgeInsets.only(left: SizeConfig.dPaddingVSmall, right: SizeConfig.dPaddingVSmallestPlus),
          //   child: Icon(Icons.search, color: cDefaultIcon),
          // ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: TextField(
                  onChanged: fOnChanged,
                  controller: tecController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    // hintStyle: TextStyle(fontSize: SizeConfig.dFontSizeFixMedium),
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    // fontSize: SizeConfig.dFontSizeFixMedium,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
