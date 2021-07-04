import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:ruangkeluarga/parent/view/setup_invite_child.dart';
import 'package:ruangkeluarga/utils/constant.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GenderCharacter { Ayah, Bunda }
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class SetupParentProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }

}

class SetupParentProfilePage extends StatefulWidget {
  SetupParentProfilePage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _SetupParentProfilePageState createState() => _SetupParentProfilePageState();

}

class _SetupParentProfilePageState extends State<SetupParentProfilePage> {
  late SharedPreferences prefs;
  TextEditingController cName = TextEditingController();
  TextEditingController cEmail = TextEditingController();
  TextEditingController cPhoneNumber = TextEditingController();
  TextEditingController cAlamat = TextEditingController();
  TextEditingController cStatus = TextEditingController();
  int _radioValue = 0;
  String namaUser = '';
  String emailUser = '';
  String phoneNumber = '';
  String photo = '';
  String accessToken = '';
  GenderCharacter? _character = GenderCharacter.Ayah;

  void onRegister() async {
    String token = '';
    await _firebaseMessaging.getToken().then((fcmToken) {
      token = fcmToken!;
    });
    String status = "Ayah";
    if(_character.toString() == "GenderCharacter.Ayah") {
      status = 'Ayah';
    } else {
      status = 'Bunda';
    }
    Response response = await MediaRepository().registerParent(cEmail.text, cName.text, token,
        photo, cPhoneNumber.text, cAlamat.text, status, accessToken);
    if(response.statusCode == 200) {
      print('isi response register : ${response.body}');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>
          SetupInviteChildPage(title: 'ruang keluarga')));
    } else {
      print('isi response register : ${response.statusCode}');
    }
  }

  void setBindingData() async {
    prefs = await SharedPreferences.getInstance();
    namaUser = prefs.getString(rkUserName)!;
    emailUser = prefs.getString(rkEmailUser)!;
    photo = prefs.getString(rkPhotoUrl)!;
    accessToken = prefs.getString(accessGToken)!;
    cName.text = namaUser;
    cEmail.text = emailUser;
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
    FlutterStatusbarcolor.setStatusBarColor(Color(0xff05745F));
    return Scaffold(
        body: Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10.0, left: 20.0, right: 10.0),
                    height: 80,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, $namaUser',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Silahkan lengkapi profile kamu sebagai orang tua di layanan ruang keluarga',
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Lengkapi Profil',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xff3BDFD2),
                              Color(0xff05745F),
                            ],
                          )
                      ),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                                width: MediaQuery.of(context).size.width,
                                child: Theme(
                                  data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                  child: TextField(
                                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                                    readOnly: true,
                                    keyboardType: TextInputType.text,
                                    minLines: 1,
                                    maxLines: 1,
                                    controller: cName,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Nama',
                                      contentPadding:
                                      const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                                width: MediaQuery.of(context).size.width,
                                child: Theme(
                                  data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                  child: TextField(
                                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                                    readOnly: true,
                                    keyboardType: TextInputType.emailAddress,
                                    minLines: 1,
                                    maxLines: 1,
                                    controller: cEmail,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Email',
                                      contentPadding:
                                      const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                                width: MediaQuery.of(context).size.width,
                                child: Theme(
                                  data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                  child: TextField(
                                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                                    keyboardType: TextInputType.number,
                                    minLines: 1,
                                    maxLines: 1,
                                    controller: cPhoneNumber,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'No. Handphone',
                                      contentPadding:
                                      const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                                width: MediaQuery.of(context).size.width,
                                child: Theme(
                                  data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                  child: TextField(
                                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                                    keyboardType: TextInputType.multiline,
                                    minLines: 3,
                                    maxLines: 5,
                                    controller: cAlamat,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Alamat',
                                      contentPadding:
                                      const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 20.0),
                                      child: Row(
                                        children: [
                                          Radio(
                                            value: GenderCharacter.Ayah,
                                            groupValue: _character,
                                            activeColor: Colors.white,
                                            onChanged: (GenderCharacter? value) {
                                              setState(() {
                                                _character = value;
                                              });
                                            },
                                          ),
                                          Text('Ayah', style: TextStyle(color: Colors.white, fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 20.0),
                                      child: Row(
                                        children: [
                                          Radio(
                                            value: GenderCharacter.Bunda,
                                            groupValue: _character,
                                            activeColor: Colors.white,
                                            onChanged: (GenderCharacter? value) {
                                              setState(() {
                                                _character = value;
                                              });
                                            },
                                          ),
                                          Text('Bunda', style: TextStyle(color: Colors.white, fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                                child: FlatButton(
                                  height: 50,
                                  minWidth: 300,
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(15.0),
                                  ),
                                  onPressed: () {
                                    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>
                                    //     SetupInviteChildPage(title: 'ruang keluarga')));
                                    onRegister();
                                  },
                                  color: Colors.white,
                                  child: Text(
                                    "Simpan",
                                    style: TextStyle(
                                      color: Color(0xff05745F),
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ]
            ),
          ),
        )
    );
  }
  
}