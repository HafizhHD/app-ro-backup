import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/login/login.dart';
import 'package:ruangkeluarga/main.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/utils/background_service_new.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minimize_app/minimize_app.dart';

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
  final Function(String)? fOnSubmitted;
  final TextEditingController? tecController;
  final String hintText;
  WSearchBar(
      {this.fOnChanged,
      this.fOnSubmitted,
      this.tecController,
      this.hintText = "Cari"});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: cOrtuLightGrey, borderRadius: BorderRadius.circular(10)),
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
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Theme(
                data: ThemeData.light(),
                child: TextField(
                    onChanged: fOnChanged,
                    onSubmitted: fOnSubmitted,
                    controller: tecController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: hintText,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                      ),
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

Widget roElevatedButton(
    {Color cColor = cAsiaBlue,
    double radius = 10,
    required Widget text,
    required Function()? onPress}) {
  return ElevatedButton(
    style: ButtonStyle(
      shape: MaterialStateProperty.all((RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius)))),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled))
            return Colors.grey.shade700;
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
    if (states.contains(MaterialState.disabled) ||
        states.contains(MaterialState.pressed)) return 0;
    if (states.contains(MaterialState.hovered)) return 6;
    return 4;
  });
}

Future<bool> onWillCloseApp() async {
  // final bool res = await Get.dialog(AlertDialog(
  //   title: new Text('Konfirmasi tutup', style: new TextStyle(fontSize: 20.0)),
  //   content: new Text('Yakin ingin menutup aplikasi?'),
  //   actions: <Widget>[
  //     new TextButton(
  //       onPressed: () {
  //         Get.back(result: false);
  //       },
  //       child: new Text('Tidak', style: new TextStyle(color: cOrtuBlue)),
  //     ),
  //     new TextButton(
  //       onPressed: () {
  //         Get.back(result: true);
  //         SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //       },
  //       child: new Text('Ya', style: new TextStyle(color: cOrtuBlue)),
  //     ),
  //   ],
  // ));
  //
  // return res;
  MinimizeApp.minimizeApp();
  return false;
}

bool showKeyboard(BuildContext ctx) =>
    MediaQuery.of(ctx).viewInsets.bottom > keyboardHeight;

void logUserOut() {
  Get.dialog(
    AlertDialog(
      title: const Text('Konfirmasi'),
      content: const Text('Apakah anda yakin ingin keluar aplikasi ?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel', style: TextStyle(color: cAsiaBlue)),
        ),
        TextButton(
          onPressed: () async {
            showLoadingOverlay();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            await signOutGoogle();
            Get.find<ParentController>().logoutParent();
            closeOverlay();
            Navigator.pushAndRemoveUntil(
              Get.context!,
              MaterialPageRoute(builder: (builder) => MyHomePage()),
              (route) => false,
            );
          },
          child: const Text('OK', style: TextStyle(color: cAsiaBlue)),
        ),
      ],
    ),
  );
}
