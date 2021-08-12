import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:ruangkeluarga/child/home_child.dart';
import 'package:ruangkeluarga/child/setup_permission_child.dart';
import 'package:ruangkeluarga/parent/view/home_parent.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../parent/view/setup_profile_parent.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Login",
      home: LoginPage(title: "Login"),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';
  late bool _serviceEnabled;
  late LocationData _locationData;
  late Location location;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.isSignedIn() ? await _googleSignIn.signInSilently() : await _googleSignIn.signIn();
      if (googleUser != null) {
        onLogin(googleUser);
      } else {}
    } catch (error) {
      print(error);
    }
  }

  void onLogin(GoogleSignInAccount googleUser) async {
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
      onHandleLogin(response);
    }).catchError((err) {
      print('inner error : $err');
    });
  }

  void onHandleLogin(Response response) async {
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
                      MaterialPageRoute(builder: (context) => SetupPermissionChildPage(title: 'ruang keluarga', name: jsonUser['nameUser'])));
                } else {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => HomeChildPage(
                            title: 'ruang keluarga',
                            email: childsData[0]['email'],
                            name: childsData[0]['name'],
                          )));
                }
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeParentPage(title: 'ruang keluarga')));
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
                      MaterialPageRoute(builder: (context) => SetupPermissionChildPage(title: 'ruang keluarga', name: jsonUser['nameUser'])));
                } else {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => HomeChildPage(title: 'ruang keluarga', email: jsonUser['emailUser'], name: jsonUser['nameUser'])));
                }
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeParentPage(title: 'ruang keluarga')));
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
                    MaterialPageRoute(builder: (context) => SetupPermissionChildPage(title: 'ruang keluarga', name: jsonUser['nameUser'])));
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HomeChildPage(title: 'ruang keluarga', email: jsonUser['emailUser'], name: jsonUser['nameUser'])));
              }
            } else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeParentPage(title: 'ruang keluarga')));
            }
          }
        } else {}
      } else {
        await prefs.setBool(isPrefLogin, false);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SetupParentProfilePage(title: 'ruang keluarga')));
      }
    } else if (response.statusCode == 404) {
      await prefs.setBool(isPrefLogin, false);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SetupParentProfilePage(title: 'ruang keluarga')));
    } else {
      await prefs.setBool(isPrefLogin, false);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SetupParentProfilePage(title: 'ruang keluarga')));
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
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            height: 80,
            child: Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                //mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    "ruang",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 30),
                  ),
                  Text(
                    " keluarga",
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffFF018786), fontSize: 30),
                  )
                ],
              ),
            ),
          ),
          Container(
              child: Container(
            height: 120,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff3BDFD2),
                    Color(0xff05745F),
                  ],
                )),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(
                'Masuk dengan',
                style: TextStyle(color: Colors.white),
              ),
              Container(
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                  width: MediaQuery.of(context).size.width,
                  /*child: FlatButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                          ),
                          onPressed: () {},
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,// Replace with a Row for horizontal icon + text
                            children: <Widget>[
                              Icon(
                                Icons.add,
                              ),
                              Text(
                                "Google",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Raleway',
                                  fontSize: 14.0,
                                ),
                              )
                            ],
                          ),
                        ),*/
                  /*child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white
                          ),
                          child: Container(
                            child: Center(
                              child: Text(
                                "Google",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),*/
                  child: FlatButton(
                      height: 50,
                      onPressed: () => {
                            // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SetupParentProfilePage(title: 'ruang keluarga')))
                            _handleSignIn()
                            // fetchUserLocation()
                          },
                      child: Stack(
                        children: <Widget>[
                          Align(alignment: Alignment.centerLeft, child: Image.asset('assets/images/icon_google.png', width: 24.0, height: 24.0)),
                          Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Google",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey, fontSize: 18),
                              ))
                        ],
                      ),
                      color: Colors.white,
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)))),
            ]),
          ))
        ]),
      ),
    );
  }
}
