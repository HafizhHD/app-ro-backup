import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:ruangkeluarga/parent/view/config_rk_access_internet.dart';
import 'package:ruangkeluarga/parent/view/config_rk_batas_penggunaan.dart';
import 'package:ruangkeluarga/parent/view/config_rk_block_apps.dart';
import 'package:ruangkeluarga/parent/view/config_rk_contact.dart';
import 'package:ruangkeluarga/parent/view/config_rk_limit_device.dart';
import 'package:ruangkeluarga/parent/view/config_rk_location.dart';
import 'package:ruangkeluarga/parent/view/detail_child_activity.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailChildView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kontrol dan Konfigurasi',
      theme: ThemeData(primaryColor: Colors.white70),
      home: DetailChildPage(title: 'Kontrol dan Konfigurasi', name: '', email: ''),
    );
  }
}

class DetailChildPage extends StatefulWidget {
  // List<charts.Series> seriesList;
  @override
  _DetailChildPageState createState() => _DetailChildPageState();
  final String title;
  final String name;
  final String email;

  DetailChildPage({Key? key, required this.title, required this.name, required this.email}) : super(key: key);
}

class _DetailChildPageState extends State<DetailChildPage> {
  int dataTotal = 0;
  int dataTotalSecond = 0;
  late SharedPreferences prefs;
  String avgData = '0s';
  var dtx = [0, 0, 0, 0, 0, 0, 0];
  var dty = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  String dateToday = '00.01';
  int countUsage = 1;

  List<charts.Series<Sales, String>> _createRandomData() {
    final random = Random();

    final desktopSalesData = [
      Sales('${dty[0]}', dtx[0]),
      Sales('${dty[1]}', dtx[1]),
      Sales('${dty[2]}', dtx[2]),
      Sales('${dty[3]}', dtx[3]),
      Sales('${dty[4]}', dtx[4]),
      Sales('${dty[5]}', dtx[5]),
      Sales('${dty[6]}', dtx[6]),
    ];

    return [
      charts.Series<Sales, String>(
        id: 'Sales',
        domainFn: (Sales sales, _) => sales.year,
        measureFn: (Sales sales, _) => sales.sales,
        data: desktopSalesData,
        // fillColorFn: (Sales sales, _) {
        //   return charts.MaterialPalette.blue.shadeDefault;
        // },
      )
    ];
  }

  List<charts.Series> seriesList = [];
  bool _switchLockScreen = false;
  bool _switchModeAsuh = false;
  bool _switchLevel1 = false;
  bool _switchLevel2 = false;
  bool _switchLevel3 = false;

  void setBindingData() async {
    prefs = await SharedPreferences.getInstance();
    var outputFormat = DateFormat('HH.mm');
    var outputDate = outputFormat.format(DateTime.now());
    dateToday = outputDate;

    dataTotalSecond = await getUsageStatistik();
    dataTotal = dataTotalSecond ~/ 3600;
    int secs = dataTotalSecond;
    if (secs > 0) {
      int tmpAvg = secs ~/ countUsage;
      int totalHour = 0;
      if (tmpAvg >= 3600) {
        totalHour = tmpAvg ~/ 3600;
        tmpAvg = tmpAvg - (totalHour * 3600);
      }
      int totalMenit = 0;
      if (tmpAvg >= 60) {
        totalMenit = tmpAvg ~/ 60;
        tmpAvg = tmpAvg - (totalMenit * 60);
      }
      if (totalHour == 0) {
        if (totalMenit == 0) {
          avgData = '${tmpAvg}s';
        } else {
          avgData = '${totalMenit}m ${tmpAvg}s';
        }
      } else {
        avgData = '${totalHour}h ${totalMenit}m';
      }
    } else {
      avgData = '0s';
    }
    await prefs.setString("averageTime${widget.email}", avgData);
    onGetUsageDataWeekly();
    onLoadBar();
    setState(() {});
  }

  void onGetUsageDataWeekly() async {
    var outputFormat = DateFormat('yyyy-MM-dd');
    int usageFirst = 0;
    var dayFirst = outputFormat.format(findFirstDateOfTheWeek(DateTime.now()));
    usageFirst = await getDailyUsageStatistik(dayFirst) ~/ 3600;

    int usageSecond = 0;
    var daySecond = outputFormat.format(findSecondDateOfTheWeek(DateTime.now()));
    usageSecond = await getDailyUsageStatistik(daySecond) ~/ 3600;

    int usageThird = 0;
    var dayThird = outputFormat.format(findThirdDateOfTheWeek(DateTime.now()));
    usageThird = await getDailyUsageStatistik(dayThird) ~/ 3600;

    int usageFour = 0;
    var dayFour = outputFormat.format(findFourthDateOfTheWeek(DateTime.now()));
    usageFour = await getDailyUsageStatistik(dayFour) ~/ 3600;

    int usageFive = 0;
    var dayFive = outputFormat.format(findFifthDateOfTheWeek(DateTime.now()));
    usageFive = await getDailyUsageStatistik(dayFive) ~/ 3600;

    int usageSix = 0;
    var daySix = outputFormat.format(findSixthDateOfTheWeek(DateTime.now()));
    usageSix = await getDailyUsageStatistik(daySix) ~/ 3600;

    int usageLast = 0;
    var dayLast = outputFormat.format(findLastDateOfTheWeek(DateTime.now()));
    usageLast = await getDailyUsageStatistik(dayLast) ~/ 3600;

    print('last $usageLast');

    dtx = [usageFirst, usageSecond, usageThird, usageFour, usageFive, usageSix, usageLast];
    setState(() {});
  }

  Future<int> getUsageStatistik() async {
    prefs = await SharedPreferences.getInstance();
    int seconds = 0;
    var outputFormat = DateFormat('yyyy-MM-dd');
    var startDate = outputFormat.format(findFirstDateOfTheWeek(DateTime.now()));
    var endDate = outputFormat.format(findLastDateOfTheWeek(DateTime.now()));
    Response response = await MediaRepository().fetchAppUsageFilterRange(widget.email, startDate, endDate);
    if (response.statusCode == 200) {
      print('isi response filter app usage : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonDataResult = json['appUsages'] as List;
        await prefs.setString("childAppUsage", jsonEncode(jsonDataResult));
        if (jsonDataResult.length == 0) {
          await prefs.setInt("dataMinggu${widget.email}", 0);
        } else {
          countUsage = jsonDataResult.length;
          for (int j = 0; j < jsonDataResult.length; j++) {
            var data = jsonDataResult[j]['appUsages'] as List;
            for (int i = 0; i < data.length; i++) {
              var jsonDt = data[i];
              int sec = jsonDt['duration'];
              seconds = seconds + sec;
            }
          }
          await prefs.setInt("dataMinggu${widget.email}", seconds);
        }
      }
    } else {
      print('isi response filter app usage : ${response.statusCode}');
      await prefs.setInt("dataMinggu${widget.email}", 0);
    }
    return seconds;
  }

  Future<int> getDailyUsageStatistik(String tanggal) async {
    prefs = await SharedPreferences.getInstance();
    int seconds = 0;
    Response response = await MediaRepository().fetchAppUsageFilter(widget.email, tanggal);
    if (response.statusCode == 200) {
      print('isi response filter app usage : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonDataResult = json['appUsages'] as List;
        await prefs.setString("childAppUsage", jsonEncode(jsonDataResult));
        if (jsonDataResult.length == 0) {
          await prefs.setInt("dataMinggu${widget.email}", 0);
        } else {
          var data = jsonDataResult[jsonDataResult.length - 1]['appUsages'] as List;
          for (int i = 0; i < data.length; i++) {
            var jsonDt = data[i];
            int sec = jsonDt['duration'];
            seconds = seconds + sec;
          }
          await prefs.setInt("dataMinggu${widget.email}", seconds);
        }
      }
    } else {
      print('isi response filter app usage : ${response.statusCode}');
      await prefs.setInt("dataMinggu${widget.email}", 0);
    }
    return seconds;
  }

  DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }

  DateTime findSecondDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 2));
  }

  DateTime findThirdDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 3));
  }

  DateTime findFourthDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 4));
  }

  DateTime findFifthDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 5));
  }

  DateTime findSixthDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 6));
  }

  DateTime findLastDateOfTheWeek(DateTime dateTime) {
    return dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }

  @override
  void initState() {
    super.initState();
    // seriesList = _createRandomData(dataTotal, dtx);
    setBindingData();
  }

  barChart() {
    return charts.BarChart(
      _createRandomData(),
      animate: true,
      vertical: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.grey.shade700)),
        backgroundColor: Colors.white70,
        iconTheme: IconThemeData(color: Colors.grey.shade700),
      ),
      backgroundColor: Colors.grey[300],
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.all(20.0),
                        child: Text('${widget.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 3.0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.all(10.0),
                              child: Text(
                                'Daily Average',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    '$avgData',
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                /*Container(
                                  margin: EdgeInsets.only(right: 10.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 10.0),
                                        child: Icon(
                                          Icons.arrow_circle_down,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        '30% from last week',
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                )*/
                              ],
                            ),
                            onLoadBar(),
                            Container(
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(border: Border.all(width: 0.2, color: Colors.grey)),
                            ),
                            ListTile(
                              title: Text('Lihat Semua Aktifitas'),
                              trailing: Icon(
                                Icons.keyboard_arrow_right,
                                color: Colors.grey.shade700,
                              ),
                              onTap: () => {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) => DetailChildActivityPage(name: widget.name, email: widget.email)))
                              },
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0, bottom: 5.0),
                        child: Text('Update today $dateToday', style: TextStyle(fontSize: 14)),
                      ),
                      Container(
                        margin: EdgeInsets.all(20.0),
                        child: Text('Kontrol Instant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 3.0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      'Mode Kunci Layar',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    child: CupertinoSwitch(
                                      value: _switchLockScreen,
                                      onChanged: (value) {
                                        setState(() {
                                          _switchLockScreen = value;
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            onShowSettingAsuh(_switchModeAsuh),
                            onShowModeAsuh(_switchModeAsuh)
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(20.0),
                        child: Text('Kontrol dan Konfigurasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 3.0,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 20.0, bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Lokasi',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.settings,
                                        color: Colors.blue,
                                      ),
                                      onTap: () => {
                                        Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => RKConfigLocationPage(
                                                  title: 'Penelurusan Lokasi',
                                                  email: widget.email,
                                                  name: widget.name,
                                                )))
                                      },
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                                child: Text('Dengan Geofencing, Anda dapat mengatur peringatan ketika mereka'
                                    'memasuki atau meninggalkan lokasi tertentu. Anda juga dapat melihat lokasi'
                                    'mereka saat ini dan riwayat lokasi kapan saja untuk mencari tahu dimana'
                                    'mereka dulu dan dimana mereka saat ini kapan saja.'),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 20.0, bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Kontak',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.settings,
                                        color: Colors.blue,
                                      ),
                                      onTap: () => {
                                        /*showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  elevation: 16,
                                                  child: Container(
                                                    height: 400.0,
                                                    child: ListView(
                                                      children: <Widget>[
                                                        SizedBox(height: 20),
                                                        Center(
                                                          child: Text(
                                                            "Perpanjang Aktivasi Langganan",
                                                            style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                        SizedBox(height: 20),
                                                        Center(
                                                          child: Text(
                                                            "Masukan nomor voucher anda",
                                                            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.only(left: 20.0, right: 20.0),
                                                          child: TextField(
                                                              decoration: InputDecoration(
                                                                fillColor: Colors.grey,
                                                                border: OutlineInputBorder(),
                                                                labelText: 'Kode Voucher...',
                                                              )
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                              );
                                            }
                                        )*/
                                        Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) =>
                                                ConfigRKContactPage(title: 'Daftar Kontak', name: widget.name, email: widget.email)))
                                      },
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                                child: Text('Anda dapat melihat daftar kontak anak-anak Anda, catatan panggilan'
                                    'dan pesan SMS untuk mengetahui siapa yang telah mereka hubungi.'
                                    'Anda juga dapat mengatur kontak dalam daftar hitam untuk mendapatkan'
                                    'pemberitahuan bila ada kontak yang dibuat dengan orang yang tidak diinginkan.'),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 20.0, bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Akses Internet',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.settings,
                                        color: Colors.blue,
                                      ),
                                      onTap: () => {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(builder: (context) => RKConfigAccessInternetPage(title: 'Akses Internet')))
                                      },
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                                child: Text('Dengan SafeSearch, Anda dapat memperbaiki penelusuran negatif'
                                    'apa pun di Google, Bing atau Youtube. Pemfilteran internet memungkinkan'
                                    'Anda memblokir situs web, gambar dan video dari kategori tertentu yang'
                                    'Anda pilih. Anda juga dapat melihat riwayat internet dan bookmark mereka.'),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 20.0, bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Set Jadwal Penggunaan',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.settings,
                                        color: Colors.blue,
                                      ),
                                      onTap: () => {
                                        Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) =>
                                                RKConfigLimitDevicetPage(title: 'Jadwal Penggunaan', name: widget.name, email: widget.email)))
                                      },
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                                child: Text('Tetapkan jadwal agar anak Anda dapat menggunakan ponsel mereka hanya pada'
                                    'waktu tertentu dan memblokir akses selama waktu makan malam atau saat'
                                    'waktunya tidur. Anda juga dapat langsung memblokir akses ke ponsel'
                                    'mereka dengan fitur kunci layar.'),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 20.0, bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Blok Aplikasi / Games',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.settings,
                                        color: Colors.blue,
                                      ),
                                      onTap: () => {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<Object>(builder: (BuildContext context) => RKConfigBlockAppsPage(email: widget.email)),
                                        )
                                      },
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                                child: Text('Tetapkan jadwal untuk aplikasi atau game tertentu agar anak anda'
                                    'dapat menggunakanya hanya pada waktu yang dijadwalkan.'
                                    'Anda juga dapat memblokir sepenuhnya aplikasi atau game apa pun'
                                    'yang anda anggap berbahaya dan tidak ingin diberikan akses kepada mereka.'),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 20.0, bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Batas Penggunaan Gadget',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.settings,
                                        color: Colors.blue,
                                      ),
                                      onTap: () => {
                                        /*showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  elevation: 16,
                                                  child: Container(
                                                    height: 400.0,
                                                    child: ListView(
                                                      children: <Widget>[
                                                        SizedBox(height: 20),
                                                        Center(
                                                          child: Text(
                                                            "Perpanjang Aktivasi Langganan",
                                                            style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                        SizedBox(height: 20),
                                                        Center(
                                                          child: Text(
                                                            "Masukan nomor voucher anda",
                                                            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.only(left: 20.0, right: 20.0),
                                                          child: TextField(
                                                              decoration: InputDecoration(
                                                                fillColor: Colors.grey,
                                                                border: OutlineInputBorder(),
                                                                labelText: 'Kode Voucher...',
                                                              )
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                              );
                                            }
                                        )*/
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<Object>(
                                              builder: (BuildContext context) =>
                                                  RKConfigBatasPenggunaanPage(title: 'Batas Penggunaan', name: widget.name, email: widget.email)),
                                        )
                                      },
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                                child: Text('Dengan menggunakan aplikasi Ruang Keluarga untuk orang tua dari perangkat'
                                    'anda. Anda dapat memantau dan mengontrol perangkat anak-anak anda'
                                    'dari mana saja di dunia. Dapatkan aplikasi, internet, dan statistik'
                                    'penggunaan telepon langsung dari dasbor anda.'),
                              ),
                            ],
                          ))
                    ],
                  )),
                ),
              ),
            ],
          )),
    );
  }

  Widget onShowSettingAsuh(bool flag) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Text(
              'Mode Asuh',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Container(
            child: CupertinoSwitch(
              value: _switchModeAsuh,
              onChanged: (value) {
                setState(() {
                  _switchModeAsuh = value;
                  _switchLevel1 = true;
                  _switchLevel2 = false;
                  _switchLevel3 = false;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget onLoadBar() {
    return Container(
      margin: EdgeInsets.all(10.0),
      height: 200,
      child: barChart(),
    );
  }

  Widget onShowModeAsuh(bool flag) {
    if (flag) {
      return Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Diperketat Level 1',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                CupertinoSwitch(
                  value: _switchLevel1,
                  onChanged: (value) {
                    setState(() {
                      _switchLevel1 = value;
                      _switchLevel2 = false;
                      _switchLevel3 = false;
                      if (value) {
                        onShowModeAsuh(_switchLevel1);
                      } else {
                        _switchModeAsuh = value;
                        onShowSettingAsuh(_switchModeAsuh);
                      }
                    });
                  },
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
            child: Text('Dengan Geofencing, Anda dapat mengatur peringatan ketika mereka'
                'memasuki atau meninggalkan lokasi tertentu. Anda juga dapat melihat lokasi'
                'mereka saat ini dan riwayat lokasi kapan saja untuk mencari tahu dimana'
                'mereka dulu dan dimana mereka saat ini kapan saja.'),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Diperketat Level 2',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                CupertinoSwitch(
                  value: _switchLevel2,
                  onChanged: (value) {
                    setState(() {
                      _switchLevel2 = value;
                      _switchLevel1 = false;
                      _switchLevel3 = false;
                      if (value) {
                        onShowModeAsuh(_switchLevel2);
                      } else {
                        _switchModeAsuh = value;
                        onShowSettingAsuh(_switchModeAsuh);
                      }
                    });
                  },
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
            child: Text('Dengan Geofencing, Anda dapat mengatur peringatan ketika mereka'
                'memasuki atau meninggalkan lokasi tertentu. Anda juga dapat melihat lokasi'
                'mereka saat ini dan riwayat lokasi kapan saja untuk mencari tahu dimana'
                'mereka dulu dan dimana mereka saat ini kapan saja.'),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Diperketat Level 3',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                CupertinoSwitch(
                  value: _switchLevel3,
                  onChanged: (value) {
                    setState(() {
                      _switchLevel3 = value;
                      _switchLevel2 = false;
                      _switchLevel1 = false;
                      if (value) {
                        onShowModeAsuh(_switchLevel3);
                      } else {
                        _switchModeAsuh = value;
                        onShowSettingAsuh(_switchModeAsuh);
                      }
                    });
                  },
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
            child: Text('Dengan Geofencing, Anda dapat mengatur peringatan ketika mereka'
                'memasuki atau meninggalkan lokasi tertentu. Anda juga dapat melihat lokasi'
                'mereka saat ini dan riwayat lokasi kapan saja untuk mencari tahu dimana'
                'mereka dulu dan dimana mereka saat ini kapan saja.'),
          ),
        ]),
      );
    } else {
      return Container();
    }
  }
}

/// Sample sales data type.
class Sales {
  final String year;
  final int sales;

  Sales(this.year, this.sales);
}
