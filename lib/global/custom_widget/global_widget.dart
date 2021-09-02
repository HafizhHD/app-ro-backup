import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';

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
              child: Theme(
                data: ThemeData.light(),
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
          ),
        ],
      ),
    );
  }
}

Widget roElevatedButton({Color cColor = cOrtuBlue, required Widget text, required Function()? onPress}) {
  return ElevatedButton(
    style: ButtonStyle(
      shape: MaterialStateProperty.all((RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) return Colors.grey.shade700;
          return cColor;
        },
      ),
      elevation: globalBtnElevation(),
    ),
    child: text,
    onPressed: onPress,
  );
}

MaterialStateProperty<double> globalBtnElevation() {
  return MaterialStateProperty.resolveWith((states) {
    if (states.contains(MaterialState.disabled) || states.contains(MaterialState.pressed)) return 0;
    if (states.contains(MaterialState.hovered)) return 6;
    return 4;
  });
}
