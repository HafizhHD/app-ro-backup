import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:ruangkeluarga/child/setup_permission_child.dart';
import 'package:ruangkeluarga/login.dart';

class ConfirmPrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Confirm Privacy Policy",
      home: ConfirmPrivacyPolicyPage(title: "Confirm Privacy Policy"),
    );
  }

}

class ConfirmPrivacyPolicyPage extends StatefulWidget {
  ConfirmPrivacyPolicyPage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _ConfirmPrivacyPolicyState createState() => _ConfirmPrivacyPolicyState();

}

class _ConfirmPrivacyPolicyState extends State<ConfirmPrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Color(0xff05745F));
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                height: 300,
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
                    Container(
                      margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Izin Akses Data Perangkat',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Untuk dapat menggunakan layanan ruang keluarga, kami memerlukan izin untuk mengakses data google anda untuk verifikasi.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                          width: MediaQuery.of(context).size.width,
                          child: FlatButton(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                            onPressed: () {},
                            color: Colors.white,
                            child: Text(
                              "Baca Kebijakan Privasi",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Raleway',
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                          width: MediaQuery.of(context).size.width,
                          child: FlatButton(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                  builder: (context) => Login()));
                              // Navigator.of(context).pushReplacement(MaterialPageRoute(
                              //     builder: (context) => SetupPermissionChildPage(title: 'Setup Permission',)));
                            },
                            color: Colors.white,
                            child: Text(
                              "Setuju",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Raleway',
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                          width: MediaQuery.of(context).size.width,
                          child: FlatButton(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                            onPressed: () {},
                            color: Colors.white,
                            child: Text(
                              "Tolak",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Raleway',
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
          ],
        ),
      ),
    );
  }

}