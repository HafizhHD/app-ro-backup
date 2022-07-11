import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../utils/base_service/service_controller.dart';
import 'global.dart';

class HelpPage extends StatefulWidget {
  final String? address;
  final String? userTypeStr;

  const HelpPage({Key? key, this.address, this.userTypeStr})
      : super(key: key);
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState  extends State<HelpPage> {
  final appInfo = Get.find<RKServiceController>().appInfo;
  late SharedPreferences prefs;
  String emailUser = '';
  String nameUser = '';
  void setBindingData() async {
    prefs = await SharedPreferences.getInstance();
    emailUser = prefs.getString(rkEmailUser)!;
    nameUser = prefs.getString(rkUserName)!;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setBindingData();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final borderRadiusSize = Radius.circular(10);
    return Scaffold(
        appBar: AppBar(
          title: Text('Bantuan', style: TextStyle(color: cOrtuWhite)),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: cTopBg,
        ),
        backgroundColor: cPrimaryBg,
        body: Container(
          margin: const EdgeInsets.only(
              left: 20.0, right: 20.0, bottom: 20, top: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 15, right: 15),
                          child: Container(
                              child: TextButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty.all(
                                          cAsiaBlue)),
                                  child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.privacy_tip_outlined,
                                            color: cOrtuWhite),
                                        SizedBox(width: 10),
                                        Text('Kebijakan Privasi',
                                            style: TextStyle(
                                                color: cOrtuWhite,
                                                fontSize: 16))
                                      ]),
                                  onPressed: () async {
                                    showPrivacyPolicy();
                                  })
                          ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Container(
                            child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(
                                        cAsiaBlue)),
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_rounded,
                                          color: cOrtuWhite),
                                      SizedBox(width: 10),
                                      Text('Syarat dan Ketentuan',
                                          style: TextStyle(
                                              color: cOrtuWhite,
                                              fontSize: 16))
                                    ]),
                                onPressed: () async {
                                  showTermCondition();
                                })
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Container(
                            child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(
                                        cAsiaBlue)),
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.help_outline_rounded,
                                          color: cOrtuWhite),
                                      SizedBox(width: 10),
                                      Text('FAQ',
                                          style: TextStyle(
                                              color: cOrtuWhite,
                                              fontSize: 16))
                                    ]),
                                onPressed: () async {
                                  showFAQ();
                                })
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Container(
                            child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(
                                        cAsiaBlue)),
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.chat_outlined,
                                          color: cOrtuWhite),
                                      SizedBox(width: 10),
                                      Text('Chat Bantuan',
                                          style: TextStyle(
                                              color: cOrtuWhite,
                                              fontSize: 16))
                                    ]),
                                onPressed: () async {
                                  await _launchWhatsapp(context);
                                })
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('  Versi ${appInfo.version}'),
                    ]),
              )
            ],
          ),
        ));
  }
}

_launchWhatsapp(context) async {
  var whatsapp = "+628119004410";
  var whatsappAndroid =Uri.parse("whatsapp://send?phone=$whatsapp&text=");
  try {
    final bool nativeAppLaunchSucceeded = await launchUrl(
      whatsappAndroid,
      mode: LaunchMode.externalNonBrowserApplication,
    );
    if (!nativeAppLaunchSucceeded) {
      print('Error buka WA: ');
    }
  } catch(e) {
    print('Error buka WA: ' + e.toString());
    showToastFailed(
        failedText: 'Pastikan anda sudah menginstall aplikasi WhatsApp',
        ctx: context);
  }
}



