import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ruangkeluarga/child/child_main.dart';
import 'package:ruangkeluarga/child/home_child.dart';
import 'package:ruangkeluarga/child/setup_permission_child.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/parent/view/main/parent_main.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../parent/view/setup_profile_parent.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
Future signOutGoogle() async {
  await _googleSignIn.signOut();
  print("User Successfully Signed Out from Google Account");
}

class LoginPage extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';
  bool _okPolicy = false;

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.isSignedIn() ? await _googleSignIn.signInSilently() : await _googleSignIn.signIn();
      if (googleUser != null) {
        await onLogin(googleUser);
      } else {
        closeOverlay();
        showToastFailed(failedText: 'Gagal login google', ctx: context);
      }
    } catch (error) {
      closeOverlay();
      showSnackbar('$error', bgColor: Colors.red, pShowDuration: Duration(seconds: 10));
      print('Google Login Error: $error');
    }
  }

  Future onLogin(GoogleSignInAccount googleUser) async {
    String token = '';
    await _firebaseMessaging.getToken().then((fcmToken) {
      token = fcmToken!;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await googleUser.authentication.then((googleKey) async {
      print('access token : ${googleKey.accessToken}');
      await prefs.setString(rkEmailUser, googleUser.email.toString());
      await prefs.setString(rkUserName, googleUser.displayName.toString());
      await prefs.setString(rkPhotoUrl, googleUser.photoUrl.toString());
      await prefs.setString(accessGToken, googleKey.accessToken.toString());
      Response response = await MediaRepository().userLogin(googleUser.email.toString(), googleKey.accessToken.toString(), token, '1.0');
      await onHandleLogin(response);
    }).catchError((err) {
      print('inner error : $err');
    });
  }

  Future onHandleLogin(Response response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('response login ${response.body}');
    try {
      if (response.statusCode == 200) {
        print("user exist");
        var json = jsonDecode(response.body);
        if (json['resultCode'] == "OK") {
          final parentController = Get.find<ParentController>();
          var jsonDataResult = json['resultData'];
          var tokenApps = jsonDataResult['token'];
          await prefs.setString(rkTokenApps, tokenApps);
          var jsonUser = jsonDataResult['user'];
          await prefs.setString(rkUserID, jsonUser["_id"]);
          await prefs.setString(rkUserType, jsonUser['userType']);
          await prefs.setBool(isPrefLogin, true);
          parentController.userId = jsonUser["_id"];
          parentController.userName = jsonUser["nameUser"];
          parentController.emailUser = jsonUser["emailUser"];

          if (jsonUser['userType'] == "child") {
            if (await childNeedPermission()) {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SetupPermissionChildPage(email: jsonUser['emailUser'], name: jsonUser['nameUser'])));
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => ChildMain(
                          childEmail: jsonUser['emailUser'],
                          childName: jsonUser['nameUser'],
                        )),
                (Route<dynamic> route) => false,
              );
            }
          } else {
            List<dynamic> childsData = jsonUser['childs'];
            if (childsData.length > 0) {
              await prefs.setString("rkChildName", childsData[0]['name']);
              await prefs.setString("rkChildEmail", childsData[0]['email']);
            }
            // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ParentMain()));
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ParentMain()),
              (Route<dynamic> route) => false,
            );
          }
        } else {
          await prefs.setBool(isPrefLogin, false);
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SetupParentProfilePage(title: 'ruang ortu')));
        }
      } else {
        await prefs.setBool(isPrefLogin, false);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SetupParentProfilePage(title: 'ruang ortu')));
      }
    } catch (e, s) {
      print('onHandleLogin error : $e');
      print('onHandleLogin stack : $s');
    }
  }

  late TapGestureRecognizer _onTapPP;
  late TapGestureRecognizer _onTapTOC;
  bool readPP = false;
  bool readTOC = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _onTapPP = TapGestureRecognizer()
      ..onTap = () {
        readPP = true;
        showPrivacyPolicy();
        setState(() {});
      };
    _onTapTOC = TapGestureRecognizer()
      ..onTap = () {
        readTOC = true;
        showTermCondition();
        setState(() {});
      };
  }

  @override
  void dispose() {
    _onTapPP.dispose();
    _onTapTOC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadiusSize = Radius.circular(10);
    final screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: cPrimaryBg,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 50),
                  height: screenSize.height / 2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: cOrtuWhite,
                      borderRadius: BorderRadius.all(borderRadiusSize),
                      image: DecorationImage(
                        image: AssetImage(currentAppIconPath),
                        fit: BoxFit.contain,
                      )),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Sign in / Login \ndengan menggunakan akun Google anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: cOrtuWhite,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                        side: BorderSide(color: cOrtuWhite),
                        activeColor: cOrtuWhite,
                        checkColor: cPrimaryBg,
                        value: _okPolicy,
                        onChanged: (value) {
                          setState(() => _okPolicy = !_okPolicy);
                        }),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: RichText(
                          text: TextSpan(
                            text: 'Saya telah membaca dan menyetujui \n',
                            style: TextStyle(color: cOrtuWhite),
                            children: <TextSpan>[
                              TextSpan(
                                recognizer: _onTapPP,
                                text: 'Kebijakan Privasi',
                                style: TextStyle(
                                  color: cOrtuBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: ' dan ',
                                style: TextStyle(
                                  color: cOrtuWhite,
                                ),
                              ),
                              TextSpan(
                                recognizer: _onTapTOC,
                                text: 'Syarat dan Ketentuan',
                                style: TextStyle(
                                  color: cOrtuBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '\ndari $appName',
                                style: TextStyle(
                                  color: cOrtuWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  margin: const EdgeInsets.all(10).copyWith(bottom: 50),
                  width: screenSize.width / 1.5,
                  decoration: BoxDecoration(
                    color: _okPolicy ? cOrtuWhite : cDisabled,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    tileColor: _okPolicy ? cOrtuWhite : cDisabled,
                    leading: Container(
                        padding: EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/google_logo.png',
                        )),
                    title: Text('Sign in with Google', textAlign: TextAlign.center, style: TextStyle(color: _okPolicy ? cPrimaryBg : cOrtuWhite)),
                    onTap: _okPolicy
                        ? () async {
                            showLoadingOverlay();
                            await _handleSignIn();
                            // Navigator.of(context)
                            //     .pushReplacement(MaterialPageRoute(builder: (context) => SetupParentProfilePage(title: 'ruang ortu')));
                          }
                        : null,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

Future logoutParent() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
