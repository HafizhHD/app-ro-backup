import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:ruangkeluarga/child/home_child.dart';
import 'package:ruangkeluarga/child/setup_permission_child.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/parent/view/main/parent_main.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
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
  late bool _serviceEnabled;
  late LocationData _locationData;
  late Location location;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.isSignedIn() ? await _googleSignIn.signInSilently() : await _googleSignIn.signIn();
      if (googleUser != null) {
        await onLogin(googleUser);
      } else {}
    } catch (error) {
      print(error);
    }
  }

  Future onLogin(GoogleSignInAccount googleUser) async {
    String token = '';
    await _firebaseMessaging.getToken().then((fcmToken) {
      token = fcmToken!;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    googleUser.authentication.then((googleKey) async {
      print('access token : ${googleKey.accessToken}');
      await prefs.setString(rkEmailUser, googleUser.email.toString());
      await prefs.setString(rkUserName, googleUser.displayName.toString());
      await prefs.setString(rkPhotoUrl, googleUser.photoUrl.toString());
      await prefs.setString(accessGToken, googleKey.accessToken.toString());
      Response response = await MediaRepository().loginParent(googleUser.email.toString(), googleKey.accessToken.toString(), token, '1.0');
      await onHandleLogin(response);
    }).catchError((err) {
      print('inner error : $err');
    });
  }

  Future onHandleLogin(Response response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('response login ${response.body}');
    if (response.statusCode == 200) {
      print("user exist");
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonDataResult = json['resultData'];
        var tokenApps = jsonDataResult['token'];
        await prefs.setString(rkTokenApps, tokenApps);
        var jsonUser = jsonDataResult['user'];
        if (jsonUser != null) {
          List<dynamic> childsData = jsonUser['childs'];
          await prefs.setString(rkUserType, jsonUser['userType']);
          if (childsData != null) {
            if (childsData.length > 0) {
              await prefs.setString("rkChildName", childsData[0]['name']);
              await prefs.setString("rkChildEmail", childsData[0]['email']);

              await prefs.setBool(isPrefLogin, true);
              if (jsonUser['userType'] == "child") {
                _serviceEnabled = await location.serviceEnabled();
                if (!_serviceEnabled) {
                  _serviceEnabled = await location.requestService();
                  if (!_serviceEnabled) {
                    return;
                  }
                }
                _permissionGranted = await location.hasPermission();
                if (_permissionGranted == PermissionStatus.denied) {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SetupPermissionChildPage(title: 'ruang ortu', name: jsonUser['nameUser'])));
                } else {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => HomeChildPage(
                            title: 'ruang ortu',
                            email: childsData[0]['email'],
                            name: childsData[0]['name'],
                          )));
                }
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ParentMain()));
              }
            } else {
              await prefs.setBool(isPrefLogin, true);
              if (jsonUser['userType'] == "child") {
                _serviceEnabled = await location.serviceEnabled();
                if (!_serviceEnabled) {
                  _serviceEnabled = await location.requestService();
                  if (!_serviceEnabled) {
                    return;
                  }
                }
                _permissionGranted = await location.hasPermission();
                if (_permissionGranted == PermissionStatus.denied) {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SetupPermissionChildPage(title: 'ruang ortu', name: jsonUser['nameUser'])));
                } else {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => HomeChildPage(title: 'ruang ortu', email: jsonUser['emailUser'], name: jsonUser['nameUser'])));
                }
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ParentMain()));
              }
            }
          } else {
            await prefs.setBool(isPrefLogin, true);
            if (jsonUser['userType'] == "child") {
              _serviceEnabled = await location.serviceEnabled();
              if (!_serviceEnabled) {
                _serviceEnabled = await location.requestService();
                if (!_serviceEnabled) {
                  return;
                }
              }
              _permissionGranted = await location.hasPermission();
              if (_permissionGranted == PermissionStatus.denied) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SetupPermissionChildPage(title: 'ruang ortu', name: jsonUser['nameUser'])));
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HomeChildPage(title: 'ruang ortu', email: jsonUser['emailUser'], name: jsonUser['nameUser'])));
              }
            } else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ParentMain()));
            }
          }
        } else {}
      } else {
        await prefs.setBool(isPrefLogin, false);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SetupParentProfilePage(title: 'ruang ortu')));
      }
    } else if (response.statusCode == 404) {
      await prefs.setBool(isPrefLogin, false);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SetupParentProfilePage(title: 'ruang ortu')));
    } else {
      await prefs.setBool(isPrefLogin, false);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SetupParentProfilePage(title: 'ruang ortu')));
    }
  }

  void fetchUserLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied || _permissionGranted == PermissionStatus.deniedForever) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == PermissionStatus.denied || _permissionGranted == PermissionStatus.deniedForever) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print('long : ${_locationData.longitude} & lat : ${_locationData.latitude}');
    // final coordinates = new Coordinates(_locationData.latitude, _locationData.longitude);
    // var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    print('long : ${_locationData.longitude} & lat : ${_locationData.latitude}');
    onSaveLocation(_locationData);

    location.onLocationChanged.listen((dataLocation) {
      print('long : ${dataLocation.longitude} & lat : ${dataLocation.latitude}');
    });
  }

  void onSaveLocation(LocationData locations) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await MediaRepository().saveUserLocation(prefs.getString(rkEmailUser).toString(), locations, new DateTime.now().toString());
    // Response response = await MediaRepository().saveUserLocation("galih@defghi.global", locations, new DateTime.now().toString());
    if (response.statusCode == 200) {
      print('isi response save location : ${response.body}');
    } else {
      print('isi response save location : ${response.statusCode}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location = Location();
    // fetchUserLocation();
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
                      borderRadius: BorderRadius.only(bottomRight: borderRadiusSize, bottomLeft: borderRadiusSize),
                      image: DecorationImage(
                        image: AssetImage('assets/images/ruangortu-icon_x4.png'),
                        fit: BoxFit.contain,
                      )),
                ),
              ),
              Text(
                'Sign in / Login \ndengan menggunakan akun Google anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: cOrtuWhite,
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 50, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                        side: BorderSide(color: cOrtuWhite),
                        activeColor: cOrtuWhite,
                        checkColor: cPrimaryBg,
                        value: _okPolicy,
                        onChanged: (value) {
                          setState(() {
                            _okPolicy = !_okPolicy;
                          });
                        }),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Saya setuju dengan syarat dan ketentuan dari ruang-ortu',
                          style: TextStyle(color: cOrtuWhite),
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
                    title: Text('Sign in with Google', textAlign: TextAlign.center, style: TextStyle(color: cPrimaryBg)),
                    onTap: _okPolicy
                        ? () async {
                            showLoadingOverlay();
                            await _handleSignIn();
                            closeOverlay();
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
