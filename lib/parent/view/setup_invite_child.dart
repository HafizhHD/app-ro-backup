import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart';
import 'package:ruangkeluarga/parent/view/home_parent.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GenderCharacter { Pria, Perempuan }
enum StatusStudyLevel { SD, SMP, SMA }

class SetupInviteChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}

class SetupInviteChildPage extends StatefulWidget {
  SetupInviteChildPage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _SetupInviteChildPageState createState() => _SetupInviteChildPageState();
}

class _SetupInviteChildPageState extends State<SetupInviteChildPage> {
  late SharedPreferences prefs;
  TextEditingController cChildEmail = TextEditingController();
  TextEditingController cPhoneNumber = TextEditingController();
  TextEditingController cChildName = TextEditingController();
  TextEditingController cChildAge = TextEditingController();
  TextEditingController cChildOfNumber = TextEditingController();
  TextEditingController cChildNumber = TextEditingController();
  GenderCharacter? _character = GenderCharacter.Pria;
  StatusStudyLevel? _statusLevel = StatusStudyLevel.SD;
  String emailUser = '';
  String nameUser = '';
  late FToast fToast;

  void setBindingData() async {
    prefs = await SharedPreferences.getInstance();
    emailUser = prefs.getString(rkEmailUser)!;
    nameUser = prefs.getString(rkUserName)!;
    setState(() {});
  }

  void onInviteChild() async {
    String status = "SD";
    if (_statusLevel.toString() == "StatusStudyLevel.SD") {
      status = 'SD';
    } else if (_statusLevel.toString() == "StatusStudyLevel.SMP") {
      status = 'SMP';
    } else {
      status = 'SMA';
    }
    await prefs.setString("rkChildName", cChildName.text);
    Response response = await MediaRepository().inviteChild(emailUser, cChildEmail.text, cPhoneNumber.text, cChildName.text,
        int.parse(cChildAge.text), status, int.parse(cChildOfNumber.text), int.parse(cChildNumber.text));
    if (response.statusCode == 200) {
      print('isi response invite : ${response.body}');
      _showToastSuccess();
      await prefs.setBool(isPrefLogin, true);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeParentPage(title: 'ruang keluarga')));
    } else {
      await prefs.setBool(isPrefLogin, false);
      _showToastFailed();
      print('isi response invite : ${response.statusCode}');
    }
  }

  Widget toastSuccess = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Color(0xff05745F),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check, color: Colors.white),
        SizedBox(
          width: 12.0,
        ),
        Text("Undang anak berhasil.", style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  );

  Widget toastFailed = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.redAccent,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.close, color: Colors.white),
        SizedBox(
          width: 12.0,
        ),
        Text("Maaf, undang anak gagal.\nSilahkan coba kembali", style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  );

  _showToastSuccess() {
    fToast.showToast(
      child: toastSuccess,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  _showToastFailed() {
    fToast.showToast(
      child: toastFailed,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fToast = FToast();
    fToast.init(context);
    setBindingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                    '$nameUser',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Daftarkan akun google anak anda untuk aktivasi di layanan ruang keluarga',
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Daftarkan Akun Anak',
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
                  )),
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
                            controller: cChildName,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Nama',
                              contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
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
                            controller: cChildEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Email',
                              contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
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
                            controller: cPhoneNumber,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'No. Handphone',
                              contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
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
                            controller: cChildAge,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Umur Anak',
                              contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
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
                            controller: cChildOfNumber,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Jumlah Anak',
                              contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
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
                            controller: cChildNumber,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Anak Ke',
                              contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
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
                                    value: StatusStudyLevel.SD,
                                    groupValue: _statusLevel,
                                    activeColor: Colors.white,
                                    onChanged: (StatusStudyLevel? value) {
                                      setState(() {
                                        _statusLevel = value;
                                      });
                                    },
                                  ),
                                  Text('SD', style: TextStyle(color: Colors.white, fontSize: 16)),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 20.0),
                              child: Row(
                                children: [
                                  Radio(
                                    value: StatusStudyLevel.SMP,
                                    groupValue: _statusLevel,
                                    activeColor: Colors.white,
                                    onChanged: (StatusStudyLevel? value) {
                                      setState(() {
                                        _statusLevel = value;
                                      });
                                    },
                                  ),
                                  Text('SMP', style: TextStyle(color: Colors.white, fontSize: 16)),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 20.0),
                              child: Row(
                                children: [
                                  Radio(
                                    value: StatusStudyLevel.SMA,
                                    groupValue: _statusLevel,
                                    activeColor: Colors.white,
                                    onChanged: (StatusStudyLevel? value) {
                                      setState(() {
                                        _statusLevel = value;
                                      });
                                    },
                                  ),
                                  Text('SMA', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                            //     HomeParentPage(title: 'ruang keluarga')));
                            onInviteChild();
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
        ]),
      ),
    ));
  }
}
