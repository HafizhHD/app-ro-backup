import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:ruangkeluarga/global/global_colors.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

class RKSettingAppLimit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}

class RKSettingAppLimitPage extends StatefulWidget {
  // List<charts.Series> seriesList;
  @override
  _RKSettingAppLimitPageState createState() => _RKSettingAppLimitPageState();
  final String title;
  final String name;
  final String email;

  RKSettingAppLimitPage(
      {Key? key, required this.title, required this.name, required this.email})
      : super(key: key);
}

class _RKSettingAppLimitPageState extends State<RKSettingAppLimitPage> {
  String timeSet = 'Set';
  int timeLimitHourSet = 0;
  int timeLimiteSet = 0;
  late FToast fToast;

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
        Text("Maaf, simpan limit usage gagal.\nSilahkan coba kembali",
            style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  );

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
        Text("Tambah batas penggunaan berhasil.",
            style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  );

  _showToastFailed() {
    fToast = FToast();
    fToast.init(context);
    fToast.showToast(
      child: toastFailed,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  _showToastSuccess() {
    fToast.showToast(
      child: toastSuccess,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  void onSaveTimeLimit(BuildContext context) async {
    Response response = await MediaRepository()
        .addLimitUsage(widget.email, widget.name, timeLimiteSet, 'Aktif');
    if (response.statusCode == 200) {
      _showToastSuccess();
      Navigator.pop(context, true);
    } else {
      _showToastFailed();
      Navigator.pop(context, true);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: cOrtuWhite)),
        backgroundColor: cTopBg,
        iconTheme: IconThemeData(color: Colors.grey.shade700),
        actions: <Widget>[
          GestureDetector(
            child: Container(
              margin: EdgeInsets.only(right: 20.0),
              child: Align(
                child: Text(
                  'Tambah',
                  style: TextStyle(
                      color: Color(0xffFF018786), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () {
              onSaveTimeLimit(context);
              // Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              //     RKTambahBatasanPage(title: widget.title, name: widget.name, email: widget.email)));
            },
          ),
          /*IconButton(onPressed: () {}, icon: Icon(
            Icons.add,
            color: Colors.grey.shade700,
          ),),*/
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.grey[300],
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
              height: 50,
              color: Colors.grey,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Time',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(
                          '$timeSet',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        var outputFormat = DateFormat('H:m');
                        DatePicker.showTimePicker(context,
                            showTitleActions: true, onChanged: (date) {
                          print('change $date in time zone ' +
                              date.timeZoneOffset.inHours.toString());
                        }, onConfirm: (date) {
                          print('confirm ${outputFormat.format(date)}');
                          setState(() {
                            timeLimitHourSet = int.parse(
                                    outputFormat.format(date).split(":")[0]) *
                                60;
                            timeLimiteSet = timeLimitHourSet +
                                int.parse(
                                    outputFormat.format(date).split(":")[1]);
                            print('confirm ${outputFormat.format(date)}');
                            if (int.parse(
                                    outputFormat.format(date).split(":")[1]) ==
                                0) {
                              timeSet =
                                  "${outputFormat.format(date).split(":")[0]}jam, Setiap Hari";
                            } else {
                              timeSet =
                                  "${int.parse(outputFormat.format(date).split(":")[0])}jam${int.parse(outputFormat.format(date).split(":")[1])}min, Setiap Hari";
                            }
                          });
                        },
                            currentTime: outputFormat
                                .parse(outputFormat.format(DateTime.now())));
                      },
                    )
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width,
              child: Text(
                  'Batas penggunaan gadget akan di aktifkan ke semua device yang terhubung kedalam email ini'),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: 50.0, left: 10.0, right: 10.0, bottom: 5.0),
              width: MediaQuery.of(context).size.width,
              child: Text(
                'Kategori, Aplikasi dan Website',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              color: Colors.grey,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10.0),
                      child: Text(
                        '${widget.name}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
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
