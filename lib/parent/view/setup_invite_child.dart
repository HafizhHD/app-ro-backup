import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ruangkeluarga/global/custom_widget/photo_image_picker.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruangkeluarga/parent/view_model/sekolah_al_azhar_model.dart';

enum StatusStudyLevel { SD, SMP, SMA }

class SetupInviteChildPage extends StatefulWidget {
  final String? address;
  final String? userTypeStr;

  const SetupInviteChildPage({Key? key, this.address, this.userTypeStr})
      : super(key: key);
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
  TextEditingController cSekolahAlazhar = TextEditingController();
  StatusStudyLevel? _statusLevel = StatusStudyLevel.SD;
  String emailUser = '';
  String nameUser = '';
  String cAddress = '';

  ParentCharacter? parentGender;
  ChildGender? childGender;
  late FToast fToast;
  String birthDateString = '';
  DateTime birthDate = DateTime.now().subtract(Duration(days: 365 * 5));
  File? _selectedImage;
  SekolahAlAzhar? selectedSekolah;

  ParentController parentController = Get.find<ParentController>();

  void setBindingData() async {
    prefs = await SharedPreferences.getInstance();
    emailUser = prefs.getString(rkEmailUser)!;
    nameUser = prefs.getString(rkUserName)!;
    setState(() {});
  }

  void onInviteChild() async {
    showLoadingOverlay();
    String studyLevel = "SD";
    String namaSekolah = "";
    String lokasiSekolah = "";
    if (selectedSekolah != null) {
      final s = selectedSekolah?.jenjang;
      studyLevel = s!;
      final n = selectedSekolah?.nama;
      namaSekolah = n!;
      final l = selectedSekolah?.lokasi;
      lokasiSekolah = l!;
    }
    String userTypeString = widget.userTypeStr!;
    String genderString =
        childGender != null ? childGender!.toEnumString() : 'Pria';
    String parentStatusString =
        parentGender != null ? parentGender!.toEnumString() : '';
    if (parentStatusString == 'Bunda') genderString = 'Wanita';
    await prefs.setString("rkChildName", cChildName.text);
    final Uint8List? _imageBytes =
        _selectedImage != null ? _selectedImage!.readAsBytesSync() : null;
    final allData = [
      emailUser,
      cChildEmail.text,
      cPhoneNumber.text,
      cChildName.text,
      10,
      studyLevel,
      1,
      1,
      _imageBytes != null
          ? "data:image/png;base64,${base64Encode(_imageBytes)}"
          : "",
      birthDate.toIso8601String(),
      cAddress,
      userTypeString,
      namaSekolah,
    ];
    http.Response response = await MediaRepository().inviteChild(
      emailUser,
      cChildEmail.text,
      cPhoneNumber.text,
      cChildName.text,
      10,
      studyLevel,
      1,
      1,
      _imageBytes != null
          ? "data:image/png;base64,${base64Encode(_imageBytes)}"
          : "",
      birthDate.toIso8601String(),
      cAddress,
      userTypeString,
      parentStatusString,
      genderString,
      namaSekolah,
      lokasiSekolah,
    );
    print('isi response invite : ${response.body}');
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        _showToastSuccess();
        await prefs.setBool(isPrefLogin, true);
        closeOverlay();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (ctx) => InviteChildQR(
                    allData: allData,
                    showToastSuccess: _showToastSuccess,
                    showToastFailed: _showToastFailed,
                    prefs: prefs,
                    userType: userTypeString)),
            result: 'AddChild');
      } else {
        await prefs.setBool(isPrefLogin, false);
        closeOverlay();
        _showToastFailed();
        showToastFailed(ctx: context, failedText: json['message']);
      }
    } else {
      await prefs.setBool(isPrefLogin, false);
      closeOverlay();
      _showToastFailed();
    }
  }

  Widget toastSuccess() {
    return Container(
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
          Flexible(
            child: Text(
                "Pesan aktivasi telah berhasil dikirimkan pada email ${cChildEmail.text}",
                style: TextStyle(color: Colors.white, fontSize: 12),
                overflow: TextOverflow.visible),
          )
        ],
      ),
    );
  }

  Widget toastFailed() {
    String userType =
        widget.userTypeStr != null && widget.userTypeStr == 'parent'
            ? 'co-parent'
            : 'anak';
    return Container(
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
          Text("Maaf, undang $userType gagal.\nSilahkan coba kembali",
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  _showToastSuccess() {
    fToast.showToast(
      child: toastSuccess(),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  _showToastFailed() {
    fToast.showToast(
      child: toastFailed(),
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
    final screenSize = MediaQuery.of(context).size;
    final borderRadiusSize = Radius.circular(10);
    cAddress = widget.address!;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Buat Profile', style: TextStyle(color: cOrtuWhite)),
          leading: SizedBox(),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close))
          ],
          backgroundColor: cTopBg,
          elevation: 0,
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
                      ConstrainedBox(
                        constraints:
                            BoxConstraints(maxHeight: screenSize.height / 4),
                        child: GestureDetector(
                          onTap: () async {
                            final imgPicker = await openCamOrDirDialog();
                            if (imgPicker != null)
                              setState(() => _selectedImage = imgPicker);
                          },
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: _selectedImage != null
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(borderRadiusSize),
                                      image: DecorationImage(
                                          image: FileImage(_selectedImage!),
                                          fit: BoxFit.cover),
                                    ),
                                  )
                                : Container(
                                    height: screenSize.height / 3,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: cAsiaBlue,
                                      borderRadius:
                                          BorderRadius.all(borderRadiusSize),
                                    ),
                                    child: Center(
                                        child:
                                            Icon(Icons.add_a_photo, size: 50)),
                                  ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(splashColor: Colors.transparent),
                          child: TextFormField(
                            validator: (val) {
                              if (val == '') return 'Mohon lengkapi nama';
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                            keyboardType: TextInputType.text,
                            minLines: 1,
                            maxLines: 1,
                            controller: cChildName,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(color: cOrtuOrange),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Nama Lengkap',
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: cOrtuButton),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: cOrtuButton),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10.0, bottom: 10),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(splashColor: Colors.transparent),
                          child: TextFormField(
                            validator: (val) {
                              if (val == '')
                                return 'Mohon lengkapi akun email.';
                              else if (val != null && !isEmail(val))
                                return 'Mohon gunakan format email yang benar.';
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                            keyboardType: TextInputType.emailAddress,
                            minLines: 1,
                            maxLines: 1,
                            controller: cChildEmail,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(color: cOrtuOrange),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Email',
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: cOrtuButton),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: cOrtuButton),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                                initialDatePickerMode: DatePickerMode.year,
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark(),
                                    child: child!,
                                  );
                                },
                                context: context,
                                initialDate: birthDate,
                                firstDate: DateTime(1940, 1),
                                lastDate: DateTime(DateTime.now().year,
                                    DateTime.now().month, DateTime.now().day));
                            if (picked != null && picked != birthDate) {
                              setState(() {
                                birthDate = picked;
                                birthDateString =
                                    dateTimeTo_ddMMMMyyyy(birthDate);
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
                                      contentPadding: const EdgeInsets.only(
                                          left: 14.0, bottom: 8.0, top: 8.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: cOrtuButton),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: cOrtuButton),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      hintText: birthDateString == ''
                                          ? "- Pilih Tanggal -"
                                          : birthDateString,
                                      hintStyle: birthDateString == ''
                                          ? TextStyle(fontSize: 16)
                                          : TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
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
                      if (widget.userTypeStr == 'child')
                        Theme(
                          data: ThemeData.light(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
                                child: ListTile(
                                  title: Text("Pria"),
                                  horizontalTitleGap: 0,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Radio<ChildGender>(
                                    value: ChildGender.Pria,
                                    groupValue: childGender,
                                    activeColor: cAsiaBlue,
                                    onChanged: (ChildGender? value) {
                                      setState(() => childGender = value);
                                    },
                                  ),
                                ),
                              ),
                              Flexible(
                                child: ListTile(
                                  title: Text("Wanita"),
                                  horizontalTitleGap: 0,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Radio<ChildGender>(
                                    value: ChildGender.Wanita,
                                    groupValue: childGender,
                                    activeColor: cAsiaBlue,
                                    onChanged: (ChildGender? value) {
                                      setState(() => childGender = value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (widget.userTypeStr == 'child')
                        Container(
                          child: TextField(
                            onTap: () async {
                              print('SELECT Sekolah');
                              final selected = await selectedSekolahAlAzhar(
                                  Get.find<ParentController>()
                                      .listSekolahAlAzhar);
                              if (selected != null) {
                                selectedSekolah = selected;
                                cSekolahAlazhar.text = selected.nama;
                                setState(() {});
                              }
                            },
                            textAlignVertical: TextAlignVertical.center,
                            style:
                                TextStyle(fontSize: 14.0, color: Colors.black),
                            readOnly: true,
                            minLines: 1,
                            maxLines: 3,
                            controller: cSekolahAlazhar,
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.arrow_drop_down_rounded,
                                color: cPrimaryBg,
                              ),
                              filled: true,
                              fillColor: cOrtuWhite,
                              hintText: 'Pilih Sekolah',
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 8.0),
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
                      SizedBox(height: 10),
                      if (widget.userTypeStr == 'parent')
                        Theme(
                          data: ThemeData.light(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
                                child: ListTile(
                                  title: Text("Ayah"),
                                  horizontalTitleGap: 0,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Radio<ParentCharacter>(
                                    value: ParentCharacter.Ayah,
                                    groupValue: parentGender,
                                    activeColor: cAsiaBlue,
                                    onChanged: (ParentCharacter? value) {
                                      setState(() => parentGender = value);
                                    },
                                  ),
                                ),
                              ),
                              Flexible(
                                child: ListTile(
                                  title: Text("Bunda"),
                                  horizontalTitleGap: 0,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Radio<ParentCharacter>(
                                    value: ParentCharacter.Bunda,
                                    groupValue: parentGender,
                                    activeColor: cAsiaBlue,
                                    onChanged: (ParentCharacter? value) {
                                      setState(() => parentGender = value);
                                    },
                                  ),
                                ),
                              ),
                              Flexible(
                                child: ListTile(
                                  title: Text("Lainnya"),
                                  horizontalTitleGap: 0,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Radio<ParentCharacter>(
                                    value: ParentCharacter.Lainnya,
                                    groupValue: parentGender,
                                    activeColor: cAsiaBlue,
                                    onChanged: (ParentCharacter? value) {
                                      setState(() => parentGender = value);
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
              showKeyboard(context)
                  ? SizedBox()
                  : Container(
                      margin: EdgeInsets.only(top: 10),
                      child: FlatButton(
                        height: 50,
                        minWidth: 300,
                        disabledColor: cOrtuGrey,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(15.0),
                        ),
                        onPressed: cChildName.text != '' &&
                                cChildEmail.text != '' &&
                                isEmail(cChildEmail.text) &&
                                (parentGender != null ||
                                    widget.userTypeStr == 'child')
                            ? () {
                                onInviteChild();
                              }
                            : null,
                        color: cAsiaBlue,
                        child: Text(
                          "LANJUTKAN",
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                            color: cOrtuWhite,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ));
  }
}

class InviteChildQR extends StatelessWidget {
  final List<Object>? allData;
  final VoidCallback? showToastSuccess;
  final VoidCallback? showToastFailed;
  final SharedPreferences? prefs;
  final String? userType;

  const InviteChildQR(
      {Key? key,
      this.allData,
      this.showToastSuccess,
      this.showToastFailed,
      this.prefs,
      this.userType})
      : super(key: key);

  void onReInviteChild(
      oAllData, oShowToastSuccess, oShowToastFailed, oPrefs) async {
    showLoadingOverlay();
    await oPrefs.setString("rkChildName", oAllData[3]!);
    http.Response response =
        await MediaRepository().sendEmailInvitation(oAllData[0], oAllData[1]);
    print('isi response invite : ${response.body}');
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        oShowToastSuccess();
        await oPrefs.setBool(isPrefLogin, true);
        closeOverlay();
      } else {
        await oPrefs.setBool(isPrefLogin, false);
        closeOverlay();
        oShowToastFailed();
      }
    } else {
      await oPrefs.setBool(isPrefLogin, false);
      closeOverlay();
      oShowToastFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final FToast fToast = FToast().init(context);
    final String userTypeStrings =
        userType != null && userType == 'parent' ? 'co-parent' : 'anak';

    Widget toastSuccess() {
      return Container(
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
            Flexible(
              child: Text(
                  "Pesan aktivasi telah berhasil dikirimkan pada email ${allData![1]}}",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.visible),
            )
          ],
        ),
      );
    }

    final Widget toastFailed = Container(
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
          Text("Maaf, undang $userTypeStrings gagal.\nSilahkan coba kembali",
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );

    _showToastSuccess() {
      fToast.showToast(
        child: toastSuccess(),
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

    return Material(
      color: cPrimaryBg,
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text:
                                  'Untuk menghubungkan ke perangkat $userTypeStrings,',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  '\nscan QR berikut di perangkat $userTypeStrings untuk aktivasi & download aplikasi ',
                              style: TextStyle(fontSize: 16)),
                          TextSpan(text: appName)
                        ],
                        style: TextStyle(color: cOrtuText),
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 3,
                      color: Colors.white,
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(5),
                      child: Align(
                          alignment: Alignment.center,
                          child: QrImage(data: ApkDownloadURL_ORTU)),
                    ),
                    RichText(
                        text: TextSpan(children: [
                          TextSpan(text: 'Atau dengan cara kedua\n\n'),
                          TextSpan(
                              text: 'Periksa Email ${allData![1]} Anda ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'lalu '),
                          TextSpan(
                              text: 'klik Aktivasi ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: '& download aplikasi ' +
                                  appName +
                                  ' di perangkat $userTypeStrings Anda')
                        ], style: TextStyle(fontSize: 16, color: cOrtuText)),
                        textAlign: TextAlign.justify),
                    RichText(
                        text: TextSpan(children: [
                          TextSpan(text: 'Belum mendapatkan email aktivasi?\n'),
                          TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  onReInviteChild(
                                      allData,
                                      showToastSuccess != null
                                          ? showToastSuccess
                                          : _showToastSuccess,
                                      showToastFailed != null
                                          ? showToastFailed
                                          : _showToastFailed,
                                      prefs);
                                },
                              text: 'Kirim Ulang',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: cOrtuInkWell))
                        ], style: TextStyle(fontSize: 16, color: cOrtuText)),
                        textAlign: TextAlign.justify),
                    SizedBox(height: 10)
                  ])),
              Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: FlatButton(
                    height: 50,
                    minWidth: 300,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(15.0),
                    ),
                    onPressed: () {
                      Navigator.pop(context, 'AddChild');
                    },
                    color: cAsiaBlue,
                    child: Text(
                      "KEMBALI KE HOME",
                      style: TextStyle(
                        color: cOrtuWhite,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ]),
              // Container(
              //   margin: EdgeInsets.all(10),
              //   child: FlatButton(
              //     height: 50,
              //     minWidth: 300,
              //     shape: new RoundedRectangleBorder(
              //       borderRadius: new BorderRadius.circular(15.0),
              //     ),
              //     onPressed: () {
              //       onReInviteChild(
              //           allData,
              //           showToastSuccess != null
              //               ? showToastSuccess
              //               : _showToastSuccess,
              //           showToastFailed != null
              //               ? showToastFailed
              //               : _showToastFailed,
              //           prefs);
              //     },
              //     color: cOrtuBlue,
              //     child: Text(
              //       "Kirim Ulang Email Aktivasi",
              //       style: TextStyle(
              //         fontFamily: 'Raleway',
              //         fontWeight: FontWeight.bold,
              //         fontSize: 20.0,
              //       ),
              //     ),
              //   ),
              // ),
              // Container(
              //   margin: EdgeInsets.all(10),
              //   child: FlatButton(
              //     height: 50,
              //     minWidth: 300,
              //     shape: new RoundedRectangleBorder(
              //       borderRadius: new BorderRadius.circular(15.0),
              //     ),
              //     onPressed: () async {
              //       Navigator.pop(context, 'AddChild');
              //     },
              //     color: cOrtuBlue,
              //     child: Text(
              //       "KEMBALI KE HOME",
              //       style: TextStyle(
              //         fontFamily: 'Raleway',
              //         fontWeight: FontWeight.bold,
              //         fontSize: 20.0,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<SekolahAlAzhar?> selectedSekolahAlAzhar(
    List<SekolahAlAzhar> listSekolah) async {
  List<SekolahAlAzhar> searchList = listSekolah;
  return await Get.bottomSheet<SekolahAlAzhar>(
    StatefulBuilder(
      builder: (ctx, setState) {
        return Container(
          decoration: BoxDecoration(
              color: cOrtuGrey,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15))),
          padding: EdgeInsets.only(top: 20, left: 15, right: 15),
          child: Column(
            children: [
              WSearchBar(
                hintText: 'Cari Sekolah',
                fOnChanged: (text) {
                  searchList = listSekolah
                      .where((e) =>
                          e.nama.toLowerCase().contains(text.toLowerCase()) ||
                          e.deskripsi
                              .toLowerCase()
                              .contains(text.toLowerCase()))
                      .toList();
                  setState(() {});
                },
              ),
              Flexible(
                  child: ListView.separated(
                physics: BouncingScrollPhysics(),
                separatorBuilder: (ctx, idx) => Divider(color: cPrimaryBg),
                itemCount: searchList.length,
                itemBuilder: (ctx, idx) {
                  final item = searchList[idx];
                  return ListTile(
                    title: Text(item.nama),
                    // subtitle: item.alamat != '' ? Text(item.alamat) : null,
                    onTap: () {
                      Get.back(result: item);
                    },
                  );
                },
              ))
            ],
          ),
        );
      },
    ),
  );
}
