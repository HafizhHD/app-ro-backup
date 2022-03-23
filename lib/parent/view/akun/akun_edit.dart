import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import 'package:ruangkeluarga/global/custom_widget/photo_image_picker.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

class AkunEditPage extends StatefulWidget {
  String id;
  String name;
  String email;
  String? phoneNum;
  String? alamat;
  bool isParent;
  GenderCharacter? parentGender;
  DateTime? birthDate;
  String? imgUrl;

  AkunEditPage({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNum,
    this.alamat,
    required this.isParent,
    this.parentGender = GenderCharacter.Ayah,
    this.birthDate,
    this.imgUrl,
  });

  @override
  _AkunEditPageState createState() => _AkunEditPageState();
}

class _AkunEditPageState extends State<AkunEditPage> {
  TextEditingController cName = TextEditingController();
  TextEditingController cEmail = TextEditingController();
  TextEditingController cPhoneNumber = TextEditingController();
  TextEditingController cAlamat = TextEditingController();
  String birthDateString = '';
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    cName.text = widget.name;
    cEmail.text = widget.email;
    cPhoneNumber.text = widget.phoneNum ?? '';
    cAlamat.text = widget.alamat ?? '';
    if (widget.birthDate != null)
      birthDateString = dateTimeTo_ddMMMMyyyy(widget.birthDate!);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final borderRadiusSize = Radius.circular(10);

    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: cPrimaryBg,
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
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screenSize.height / 4,
                        ),
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
                                : widget.imgUrl != null && widget.imgUrl != ''
                                    ? Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              borderRadiusSize),
                                          image: widget.imgUrl!.contains('http')
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                      widget.imgUrl!),
                                                  fit: BoxFit.cover)
                                              : DecorationImage(
                                                  image: AssetImage(
                                                      widget.imgUrl!),
                                                  fit: BoxFit.cover),
                                        ),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(Icons.edit, size: 30),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: cOrtuBlue,
                                          borderRadius: BorderRadius.all(
                                              borderRadiusSize),
                                        ),
                                        child: Center(
                                            child: Icon(Icons.add_a_photo,
                                                size: 50)),
                                      ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(splashColor: Colors.transparent),
                          child: TextFormField(
                            validator: (val) {
                              print(val);
                              if (val == '') return "Mohon masukan nama anda";
                              return null;
                            },
                            autovalidateMode: AutovalidateMode.always,

                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
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
                        width: MediaQuery.of(context).size.width,
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(splashColor: Colors.transparent),
                          child: TextField(
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                            readOnly: true,
                            keyboardType: TextInputType.emailAddress,
                            minLines: 1,
                            maxLines: 1,
                            controller: cEmail,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: cOrtuWhite,
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
                      Container(
                        margin: const EdgeInsets.only(top: 10.0, bottom: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(splashColor: Colors.transparent),
                          child: TextField(
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                            keyboardType: TextInputType.number,
                            minLines: 1,
                            maxLines: 1,
                            controller: cPhoneNumber,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: cOrtuWhite,
                              hintText: 'No. Telp',
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
                                initialDate: widget.birthDate ??
                                    DateTime.now()
                                        .subtract(Duration(days: 365 * 5)),
                                firstDate: DateTime(1940, 1),
                                lastDate: DateTime.now());
                            if (picked != null && picked != widget.birthDate) {
                              setState(() {
                                widget.birthDate = picked;
                                birthDateString = dateTimeTo_ddMMMMyyyy(picked);
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
                                      border: InputBorder.none,
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
                      Container(
                        margin: const EdgeInsets.only(top: 10.0, bottom: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(splashColor: Colors.transparent),
                          child: TextField(
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                            keyboardType: TextInputType.multiline,
                            minLines: 3,
                            maxLines: 5,
                            controller: cAlamat,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: cOrtuWhite,
                              hintText: 'Alamat',
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
                      if (widget.isParent)
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
                                    groupValue: widget.parentGender,
                                    activeColor: cOrtuBlue,
                                    onChanged: (GenderCharacter? value) {
                                      setState(
                                          () => widget.parentGender = value);
                                    },
                                  ),
                                ),
                              ),
                              Flexible(
                                child: ListTile(
                                  title: Text("Bunda"),
                                  leading: Radio<GenderCharacter>(
                                    value: GenderCharacter.Bunda,
                                    groupValue: widget.parentGender,
                                    activeColor: cOrtuBlue,
                                    onChanged: (GenderCharacter? value) {
                                      setState(
                                          () => widget.parentGender = value);
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
                      constraints: BoxConstraints(minHeight: 50),
                      child: FlatButton(
                        disabledColor: cOrtuGrey,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(15.0),
                        ),
                        onPressed: cName.text != '' || cPhoneNumber.text != ''
                            ? () async {
                                if (cName.text == '') {
                                  showToastSuccess(
                                      ctx: context,
                                      successText: 'Silahkan isi Nama');
                                }
                                showLoadingOverlay();
                                print('widget.isParent ${widget.isParent}');
                                if (widget.isParent) {
                                  final res = await onEditProfileParent();
                                  if (res.statusCode == 200) {
                                    showToastSuccess(
                                        ctx: context,
                                        successText:
                                            'Berhasil edit data user ${widget.name}');
                                    await Get.find<ParentController>()
                                        .getParentChildData();
                                    Get.close(2);
                                  } else {
                                    closeOverlay();
                                    showToastFailed(
                                        ctx: context,
                                        failedText:
                                            'Gagal edit data user ${widget.name}');
                                  }
                                } else {
                                  final res = await onEditProfileChild();
                                  if (res.statusCode == 200) {
                                    showToastSuccess(
                                        ctx: context,
                                        successText:
                                            'Berhasil edit data anak ${widget.name}');
                                    await Get.find<ParentController>()
                                        .getParentChildData();
                                    Get.close(2);
                                  } else {
                                    closeOverlay();
                                    showToastFailed(
                                        ctx: context,
                                        failedText:
                                            'Gagal edit data anak ${widget.name}');
                                  }
                                }
                              }
                            : null,
                        color: cOrtuBlue,
                        child: Text(
                          "SIMPAN",
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
        ));
  }

  Future<Response> onEditProfileParent() async {
    final Uint8List? _imageBytes =
        _selectedImage != null ? _selectedImage!.readAsBytesSync() : null;
    Map<String, dynamic> editedValue = {
      "nameUser": cName.text,
      "phoneNumber": cPhoneNumber.text,
      "address": cAlamat.text,
      "parentStatus":
          (widget.parentGender ?? GenderCharacter.Ayah).toEnumString(),
    };
    if (_imageBytes != null)
      editedValue["imagePhoto"] =
          "data:image/png;base64,${base64Encode(_imageBytes)}";
    if (widget.birthDate != null)
      editedValue["birdDate"] = widget.birthDate?.toIso8601String();

    return await MediaRepository().editUser(widget.id, editedValue);
  }

  Future<Response> onEditProfileChild() async {
    final Uint8List? _imageBytes =
        _selectedImage != null ? _selectedImage!.readAsBytesSync() : null;
    Map<String, dynamic> editedValue = {
      "nameUser": cName.text,
      "phoneNumber": cPhoneNumber.text,
      "address": cAlamat.text,
      "birdDate": widget.birthDate?.toIso8601String(),
    };
    if (_imageBytes != null)
      editedValue["imagePhoto"] =
          "data:image/png;base64,${base64Encode(_imageBytes)}";
    if (widget.birthDate != null)
      editedValue["birdDate"] = widget.birthDate?.toIso8601String();

    return await MediaRepository().editUser(widget.id, editedValue);
  }
}
