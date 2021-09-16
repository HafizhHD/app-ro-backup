import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ruangkeluarga/global/custom_widget/photo_image_picker.dart';

import 'package:ruangkeluarga/global/global_formatter.dart';
import 'package:ruangkeluarga/login/login.dart';
import 'package:ruangkeluarga/parent/view/home_parent.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/main/parent_main.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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
  String namaUser = '';
  String emailUser = '';
  String phoneNumber = '';
  String photo = '';
  String accessToken = '';
  String birthDateString = '';
  DateTime birthDate = DateTime.now().subtract(Duration(days: 365 * 5));
  GenderCharacter? _character = GenderCharacter.Ayah;
  File? _selectedImage;
  final List<String> listGerejaHKBP = ['Petojo', 'Grogol', 'Tanjung Duren', 'Duren Sawit', 'Cengkareng', 'Green Lake', 'Taman Alfa', 'Pemabelas'];
  String? selectedGereja;

  void onRegister() async {
    String token = '';
    await _firebaseMessaging.getToken().then((fcmToken) {
      token = fcmToken!;
    });

    final Uint8List? _imageBytes = _selectedImage != null ? _selectedImage!.readAsBytesSync() : null;
    Response response = await MediaRepository().registerParent(
      cEmail.text,
      cName.text,
      token,
      photo,
      cPhoneNumber.text,
      cAlamat.text,
      (_character ?? GenderCharacter.Ayah).toEnumString(),
      accessToken,
      _imageBytes != null ? "data:image/png;base64,${base64Encode(_imageBytes)}" : "",
    );
    if (response.statusCode == 200) {
      print('isi response register : ${response.body}');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ParentMain()),
        (Route<dynamic> route) => false,
      );
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
    final screenSize = MediaQuery.of(context).size;
    final borderRadiusSize = Radius.circular(10);

    return WillPopScope(
      onWillPop: () async {
        signOutGoogle();
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Buat Profile'),
            leading: SizedBox(),
            actions: [
              IconButton(
                  onPressed: () {
                    signOutGoogle();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close))
            ],
            backgroundColor: cPrimaryBg,
            elevation: 0,
          ),
          backgroundColor: cPrimaryBg,
          body: Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: screenSize.height / 4),
                          child: GestureDetector(
                            onTap: () async {
                              final imgPicker = await openCamOrDirDialog();
                              if (imgPicker != null) setState(() => _selectedImage = imgPicker);
                            },
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _selectedImage != null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(borderRadiusSize),
                                        image: DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover),
                                      ),
                                    )
                                  : photo != ''
                                      ? Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(borderRadiusSize),
                                            image: DecorationImage(image: NetworkImage(photo), fit: BoxFit.cover),
                                          ),
                                        )
                                      : Container(
                                          height: screenSize.height / 3,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: cOrtuBlue,
                                            borderRadius: BorderRadius.all(borderRadiusSize),
                                          ),
                                          child: Center(child: Icon(Icons.add_a_photo, size: 50)),
                                        ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                          width: MediaQuery.of(context).size.width,
                          child: Theme(
                            data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                            child: TextFormField(
                              validator: (val) {
                                print(val);
                                if (val == '') return "Mohon masukan nama anda";
                                return null;
                              },
                              autovalidateMode: AutovalidateMode.always,

                              style: TextStyle(fontSize: 16.0, color: Colors.black),
                              // readOnly: true,
                              keyboardType: TextInputType.text,
                              minLines: 1,
                              maxLines: 1,
                              controller: cName,
                              decoration: InputDecoration(
                                errorStyle: TextStyle(color: cOrtuOrange),
                                filled: true,
                                fillColor: cOrtuWhite,
                                hintText: 'Nama Lengkap',
                                contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: cOrtuWhite),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: cOrtuWhite),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Container(
                        //   margin: const EdgeInsets.only(top: 10.0, bottom: 10),
                        //   width: MediaQuery.of(context).size.width,
                        //   child: Theme(
                        //     data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                        //     child: TextField(
                        //       style: TextStyle(fontSize: 16.0, color: Colors.black),
                        //       readOnly: true,
                        //       keyboardType: TextInputType.emailAddress,
                        //       minLines: 1,
                        //       maxLines: 1,
                        //       controller: cEmail,
                        //       decoration: InputDecoration(
                        //         filled: true,
                        //         fillColor: cOrtuWhite,
                        //         hintText: 'Email',
                        //         contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                        //         focusedBorder: OutlineInputBorder(
                        //           borderSide: BorderSide(color: cOrtuWhite),
                        //           borderRadius: BorderRadius.circular(10),
                        //         ),
                        //         enabledBorder: UnderlineInputBorder(
                        //           borderSide: BorderSide(color: cOrtuWhite),
                        //           borderRadius: BorderRadius.circular(10),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 10),
                          padding: EdgeInsets.only(left: 10.0, right: 10),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) => value == null ? 'Harus dipilih' : null,
                            value: selectedGereja,
                            items: listGerejaHKBP
                                .map((value) => DropdownMenuItem(
                                      child: Text(
                                        value,
                                      ),
                                      value: value,
                                    ))
                                .toList(),
                            onChanged: (v) {
                              selectedGereja = v;
                              setState(() {});
                            },
                            isExpanded: true,
                            hint: Text(
                              'Pilih Gereja',
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10.0, bottom: 10),
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
                                fillColor: cOrtuWhite,
                                hintText: 'No. Telp',
                                contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: cOrtuWhite),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: cOrtuWhite),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Tanggal Lahir (opsional)',
                              style: TextStyle(color: cOrtuGrey),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10.0, bottom: 10),
                          decoration: BoxDecoration(
                            color: cOrtuWhite,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                  initialDatePickerMode: DatePickerMode.year,
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context),
                                      child: child!,
                                    );
                                  },
                                  context: context,
                                  initialDate: birthDate,
                                  firstDate: DateTime(1940, 1),
                                  lastDate: DateTime.now());
                              print('Picked: $picked');
                              if (picked != null && picked != birthDate) {
                                setState(() {
                                  birthDate = picked;
                                  birthDateString = dateTimeTo_ddMMMMyyyy(birthDate);
                                });
                              }
                            },
                            child: IgnorePointer(
                              ignoring: true,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                                        border: InputBorder.none,
                                        hintText: birthDateString == '' ? "- Pilih Tanggal -" : birthDateString,
                                        hintStyle: birthDateString == '' ? TextStyle(fontSize: 16) : TextStyle(fontSize: 16, color: Colors.black),
                                      ),
                                      readOnly: true,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(
                                      Icons.calendar_today,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10.0, bottom: 10),
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
                                fillColor: cOrtuWhite,
                                hintText: 'Alamat',
                                contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: cOrtuWhite),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: cOrtuWhite),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Theme(
                          data: ThemeData.dark(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
                                child: ListTile(
                                  title: Text("Ayah"),
                                  leading: Radio<GenderCharacter>(
                                    value: GenderCharacter.Ayah,
                                    groupValue: _character,
                                    activeColor: cOrtuBlue,
                                    onChanged: (GenderCharacter? value) {
                                      setState(() => _character = value);
                                    },
                                  ),
                                ),
                              ),
                              Flexible(
                                child: ListTile(
                                  title: Text("Bunda"),
                                  leading: Radio<GenderCharacter>(
                                    value: GenderCharacter.Bunda,
                                    groupValue: _character,
                                    activeColor: cOrtuBlue,
                                    onChanged: (GenderCharacter? value) {
                                      setState(() => _character = value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                !showKeyboard(context)
                    ? SizedBox()
                    : Container(
                        child: FlatButton(
                          height: 50,
                          minWidth: 300,
                          disabledColor: cOrtuGrey,
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(15.0),
                          ),
                          onPressed: cName.text != '' && cPhoneNumber != ''
                              ? () {
                                  onRegister();
                                }
                              : null,
                          color: cOrtuBlue,
                          child: Text(
                            "LANJUTKAN",
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          )),
    );
  }
}
