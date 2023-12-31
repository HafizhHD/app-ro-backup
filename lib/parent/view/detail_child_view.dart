import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_app_list_with_icon.dart';
import 'package:ruangkeluarga/model/rk_child_app_icon_list.dart';
import 'package:ruangkeluarga/model/rk_child_apps.dart';
import 'package:ruangkeluarga/model/rk_child_model.dart';
import 'package:ruangkeluarga/parent/view/config_rk_access_internet.dart';
import 'package:ruangkeluarga/parent/view/config_rk_batas_penggunaan.dart';
import 'package:ruangkeluarga/parent/view/config_rk_block_apps.dart';
import 'package:ruangkeluarga/parent/view/config_rk_contact.dart';
import 'package:ruangkeluarga/parent/view/config_rk_limit_device.dart';
import 'package:ruangkeluarga/parent/view/config_rk_location.dart';
import 'package:ruangkeluarga/parent/view/detail_child_activity.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/parent/view_model/appUsage_model.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'order/order.dart';

class DetailChildPage extends StatefulWidget {
  @override
  _DetailChildPageState createState() => _DetailChildPageState();
  final String title;
  final String name;
  final String email;
  final bool toLocation;
  List<Subscription> subscription;

  DetailChildPage(
      {Key? key,
      required this.title,
      required this.name,
      required this.email,
      this.toLocation = false,
      required this.subscription})
      : super(key: key);
}

// enum ModeAsuh { level1, level2, level3 }

class _DetailChildPageState extends State<DetailChildPage> {
  final parentController = Get.find<ParentController>();
  int dataTotal = 0;
  int dataTotalSecond = 0;
  late SharedPreferences prefs;
  String avgData = '0s';
  var dtx = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  var dty = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  String dateToday = '00.01';

  // List<charts.Series> seriesList = [];
  bool _switchLockScreen = false;
  bool _loadingLockScreen = false;
  bool _switchModeAsuh = false;
  bool _loadingGetData = false;
  bool _loadingFeatchData = false;
  int _switchLevel = 0;
  bool isSubscription = false;
  late List<AppUsages> listAppUsage;
  late List<AppListWithIcons> detailAplikasiChild = [];
  late List<dynamic> dataModeAsuh = [];

  void setBindingData() async {
    prefs = await SharedPreferences.getInstance();
    dateToday = now_HHmm();

    setState(() {});
    if (widget.toLocation) {
      WidgetsFlutterBinding.ensureInitialized();
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (context) => RKConfigLocationPage(
                  title: 'Penelurusan Lokasi',
                  email: widget.email,
                  name: widget.name)))
          .then((value) {
        setState(() {
          _loadingGetData = true;
        });
        getModeAsuh();
      });
    }
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
    return dateTime
        .add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }

  void onGetUsageDataWeekly() async {
    var outputFormat = DateFormat('yyyy-MM-dd');
    double usageFirst = 0;
    var dayFirst = outputFormat.format(findFirstDateOfTheWeek(DateTime.now()));
    usageFirst = await getDailyUsageStatistik(dayFirst) / 3600;

    double usageSecond = 0;
    var daySecond =
        outputFormat.format(findSecondDateOfTheWeek(DateTime.now()));
    usageSecond = await getDailyUsageStatistik(daySecond) / 3600;

    double usageThird = 0;
    var dayThird = outputFormat.format(findThirdDateOfTheWeek(DateTime.now()));
    usageThird = await getDailyUsageStatistik(dayThird) / 3600;

    double usageFour = 0;
    var dayFour = outputFormat.format(findFourthDateOfTheWeek(DateTime.now()));
    usageFour = await getDailyUsageStatistik(dayFour) / 3600;

    double usageFive = 0;
    var dayFive = outputFormat.format(findFifthDateOfTheWeek(DateTime.now()));
    usageFive = await getDailyUsageStatistik(dayFive) / 3600;

    double usageSix = 0;
    var daySix = outputFormat.format(findSixthDateOfTheWeek(DateTime.now()));
    usageSix = await getDailyUsageStatistik(daySix) / 3600;

    double usageLast = 0;
    var dayLast = outputFormat.format(findLastDateOfTheWeek(DateTime.now()));
    usageLast = await getDailyUsageStatistik(dayLast) / 3600;

    print('first $usageFirst');

    dtx = [
      usageFirst,
      usageSecond,
      usageThird,
      usageFour,
      usageFive,
      usageSix,
      usageLast
    ];
    setState(() {});
  }

  Future<int> getDailyUsageStatistik(String tanggal) async {
    prefs = await SharedPreferences.getInstance();
    int seconds = 0;
    final thisDayAppUsage =
        listAppUsage.where((e) => e.appUsageDate == tanggal);
    if (thisDayAppUsage.length > 0) {
      var data = thisDayAppUsage.first.appUsagesDetail;
      // print('inilah a');
      // print(thisDayAppUsage.first.appUsageDate);
      data.forEach((e) {
        // print('inilah b');
        // print(e.duration);
        seconds += e.duration;
      });
    }
    return seconds ~/ 1000;
  }

  @override
  void initState() {
    super.initState();
    fetchModeLock();
    getModeAsuh();

    setBindingData();
    parentController.getWeeklyUsageStatistic();
    parentController.getDailyUsageStatistic();
    listAppUsage = parentController.mapChildActivity[widget.email] ?? [];
    avgData = parentController.mapChildScreentime[widget.email] ?? '0s';
    if (widget.subscription.length > 0) isSubscription = true;
    onGetUsageDataWeekly();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: cPrimaryBg,
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.name, style: TextStyle(color: cOrtuWhite)),
          backgroundColor: cTopBg,
          iconTheme: IconThemeData(color: Colors.grey.shade700),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: cOrtuWhite),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0,
        ),
        body: Container(
          padding: EdgeInsets.all(10),
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
                      wDailyAverageChart(),
                      Container(
                        margin: EdgeInsets.only(bottom: 10, left: 15),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Updated today $dateToday',
                                style:
                                    TextStyle(fontSize: 14, color: cOrtuText))),
                      ),
                      // Divider(
                      //   thickness: 1,
                      //   color: cOrtuText,
                      // ),
                      if (isSubscription == false)
                        MaterialButton(
                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upgrade_rounded,
                                    color: cOrtuWhite),
                                SizedBox(width: 10),
                                  Text('Upgrade Paket',
                                      style: TextStyle(
                                          color: cOrtuWhite,
                                          fontSize: 16))
                              ]),
                          color: Colors.blue,
                          onPressed: () async {
                            await parentController.getListPackage();
                            var r = await Get.to(() => OrderPage(childEmail:
                            widget.email, parentEmail:
                              parentController.parentProfile.email),
                            );
                            if (r) {
                              parentController.getParentChildData();
                              closeOverlay();
                            }
                          },
                        ),
                      Container(
                        margin: EdgeInsets.all(10.0),
                        child: Text('MODE ASUH INSTANT',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: cOrtuText)),
                      ),
                      wKontrolInstant(isSubscription),
                      // Divider(
                      //   thickness: 1,
                      //   color: cOrtuText,
                      // ),
                      Container(
                        margin: EdgeInsets.all(10.0),
                        child: Text('FUNGSI KONTROL',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: cOrtuText)),
                      ),
                      wKontroldanKonfigurasi(),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget wKontrolKonfigurasiContent({
    required String title,
    required String content,
    required Function() onTap,
    bool? isSubscribtion,
  }) {
    return InkWell(
      onTap: isSubscribtion == true ? onTap
        : null,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
                top: 10.0, left: 10.0, right: 20.0, bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$title',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cOrtuText),
                ),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: Icon(
                    Icons.build_outlined,
                    color: Colors.blue,
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
            child: Text(
              '$content',
              style: TextStyle(color: cOrtuText),
            ),
          ),
        ],
      ),
    );
  }

  Widget wKontroldanKonfigurasi() {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: cOrtuLightGrey),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          wKontrolKonfigurasiContent(
            title: 'Lokasi',
            content:
                'Dengan Geofencing, Anda dapat mengatur peringatan ketika mereka'
                'memasuki atau meninggalkan lokasi tertentu. Anda juga dapat melihat lokasi'
                'mereka saat ini dan riwayat lokasi kapan saja untuk mencari tahu dimana'
                'mereka dulu dan dimana mereka saat ini kapan saja.',
            onTap: () => {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => RKConfigLocationPage(
                          title: 'Penelurusan Lokasi',
                          email: widget.email,
                          name: widget.name)))
                  .then((value) {
                setState(() {
                  _loadingGetData = true;
                });
                getModeAsuh();
              })
            },
            isSubscribtion: isSubscription
          ),
          wKontrolKonfigurasiContent(
            title: 'Kontak',
            content:
                'Anda dapat melihat daftar kontak anak-anak Anda, catatan panggilan'
                'dan pesan SMS untuk mengetahui siapa yang telah mereka hubungi.'
                'Anda juga dapat mengatur kontak dalam daftar hitam untuk mendapatkan'
                'pemberitahuan bila ada kontak yang dibuat dengan orang yang tidak diinginkan.',
            onTap: () => {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => ConfigRKContactPage(
                          title: 'Daftar Kontak',
                          name: widget.name,
                          email: widget.email)))
                  .then((value) {
                setState(() {
                  _loadingGetData = true;
                });
                getModeAsuh();
              })
            },
            isSubscribtion: isSubscription,
          ),
          // wKontrolKonfigurasiContent(
          //   title: 'Akses Internet',
          //   content: 'Dengan SafeSearch, Anda dapat memperbaiki penelusuran negatif'
          //       'pada mesin peencarian Google. Pemfilteran internet memungkinkan'
          //       'Anda memblokir situs web, gambar dan video dari kategori tertentu yang'
          //       'Anda pilih. Anda juga dapat melihat riwayat internet dan bookmark mereka.',
          //   onTap: () => Navigator.of(context)
          //       .push(MaterialPageRoute(builder: (context) => RKConfigAccessInternetPage(title: 'Akses Internet', name: widget.name))).then((value){
          //     setState(() {
          //       _loadingGetData = true;
          //     });
          //     getModeAsuh();
          //   }),
          // ),
          wKontrolKonfigurasiContent(
            title: 'Batas Penggunaan',
            content:
                'Dengan menggunakan aplikasi Ruang ORTU untuk orang tua dari perangkat'
                'anda. Anda dapat memantau dan mengontrol perangkat anak-anak anda'
                'dari mana saja di dunia. Dapatkan aplikasi, internet, dan statistik'
                'penggunaan telepon langsung dari dasbor anda.',
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute<Object>(
                    builder: (BuildContext context) =>
                        RKConfigBatasPenggunaanPage(
                            title: 'Batas Penggunaan',
                            name: widget.name,
                            email: widget.email)),
                ).then((value) {
                  setState(() {
                    _loadingGetData = true;
                  });
                  getModeAsuh();
                }),
              },
            isSubscribtion: isSubscription
          ),
          wKontrolKonfigurasiContent(
            title: 'Blok Aplikasi / Games',
            content:
                'Tetapkan jadwal untuk aplikasi atau game tertentu agar anak anda'
                'dapat menggunakanya hanya pada waktu yang dijadwalkan.'
                'Anda juga dapat memblokir sepenuhnya aplikasi atau game apa pun'
                'yang anda anggap berbahaya dan tidak ingin diberikan akses kepada mereka.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<Object>(
                  builder: (BuildContext context) => RKConfigBlockAppsPage(
                        email: widget.email,
                        nama: widget.name,
                      )),
            ).then((value) {
              setState(() {
                _loadingGetData = true;
              });
              getModeAsuh();
            }),
            isSubscribtion: isSubscription
          ),
          wKontrolKonfigurasiContent(
            title: 'Set Jadwal Penggunaan',
            content:
                'Tetapkan jadwal agar anak Anda dapat menggunakan ponsel mereka hanya pada'
                'waktu tertentu dan memblokir akses selama waktu makan malam atau saat'
                'waktunya tidur. Anda juga dapat langsung memblokir akses ke ponsel'
                'mereka dengan fitur kunci layar.',
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => RKConfigLimitDevicePage(
                        title: 'Jadwal Penggunaan',
                        name: widget.name,
                        email: widget.email)))
                .then((value) {
              setState(() {
                _loadingGetData = true;
              });
              getModeAsuh();
            }),
            isSubscribtion: isSubscription
          ),
        ],
      ),
    );
  }

  Widget wKontrolInstant(bool isSubscription) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: cOrtuLightGrey),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (_loadingLockScreen)
              ? Container(
                  margin: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Mode Kunci Layar',
                          style: TextStyle(fontSize: 16, color: cOrtuText),
                        ),
                      ),
                      Container(
                        child: CupertinoSwitch(
                          activeColor: cAsiaBlue,
                          value: _switchLockScreen,
                          onChanged: isSubscription == true ? (value) {
                            fetchUpdateModeLock(!_switchLockScreen);
                            }
                            : null,
                        ),
                      )
                    ],
                  ),
                )
              : wProgressIndicator(),
          (dataModeAsuh.length <= 0)
              ? wProgressIndicator()
              : Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Text(
                                'Mode Asuh',
                                style:
                                    TextStyle(fontSize: 16, color: cOrtuText),
                              ),
                            ),
                            Container(
                              child: CupertinoSwitch(
                                activeColor: cAsiaBlue,
                                value: _switchModeAsuh,
                                onChanged: isSubscription == true ?
                                    (value) async {
                                  prefs = await SharedPreferences.getInstance();
                                  setState(() {
                                    _loadingGetData = true;
                                    _switchModeAsuh = value;
                                    /*if(!_switchModeAsuh){
                                prefs.setInt("LVL_MODE"+widget.name.toUpperCase(), 0);
                              }*/
                                    // prefs.setBool("MODE_ASUH"+widget.name.toUpperCase(), _switchModeAsuh);
                                    if (value) _switchLevel = 0;
                                    updateDatatoFirebase(0);
                                  });
                                }
                                : null,
                              ),
                            )
                          ],
                        ),
                      ),
                      if (_switchModeAsuh)
                        Theme(
                          data: cOrtuTheme,
                          child: Container(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: dataModeAsuh.map((e) {
                                  int _switch = 0;
                                  int index = dataModeAsuh.indexOf(e);
                                  _switch = index;
                                  return modeAsuhLevelTile(
                                    leading: Radio<int>(
                                      value: _switch,
                                      groupValue: _switchLevel,
                                      activeColor: cAsiaBlue,
                                      onChanged: (int? value) {
                                        setState(() {
                                          _loadingGetData = true;
                                          _switchLevel = _switch;
                                          // prefs.setInt("LVL_MODE"+widget.name.toUpperCase(), dataModeAsuh.indexOf(e));
                                          updateDatatoFirebase(
                                              dataModeAsuh.indexOf(e));
                                        });
                                      },
                                    ),
                                    title: Text(
                                      (e['modeAsuhLable'] != null)
                                          ? e['modeAsuhLable']
                                          : '',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _switchLevel == _switch
                                              ? cAsiaBlue
                                              : cOrtuText),
                                    ),
                                    subtitle: Text(
                                      (e['description'] != null)
                                          ? e['description']
                                          : '',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                          color: _switchLevel == _switch
                                              ? cAsiaBlue
                                              : cOrtuText),
                                    ),
                                  );
                                }).toList()),
                          ),
                        ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget wDailyAverageChart() {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: cOrtuLightGrey),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(10.0),
            child: Text(
              'Daily Average',
              style: TextStyle(fontSize: 16, color: cOrtuText),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10.0),
            child: Text(
              '$avgData',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cOrtuText,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10.0),
            height: MediaQuery.of(context).size.height / 4,
            child: _chartDailyAverage(),
          ),
          TextButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lihat Detail Penggunaan',
                    style: TextStyle(color: cAsiaBlue)),
                Icon(Icons.arrow_forward, color: cAsiaBlue),
              ],
            ),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => DetailChildActivityPage(
                          name: widget.name,
                          email: widget.email,
                          lastUpdate: dateToday,
                        )))
                .then((value) {
              setState(() {
                onGetUsageDataWeekly();
                _loadingGetData = true;
              });
              getModeAsuh();
            }),
          ),
        ],
      ),
    );
  }

  Widget _chartDailyAverage() {
    final weeklyData = [
      DailyAverage('${dty[0]}', dtx[0]),
      DailyAverage('${dty[1]}', dtx[1]),
      DailyAverage('${dty[2]}', dtx[2]),
      DailyAverage('${dty[3]}', dtx[3]),
      DailyAverage('${dty[4]}', dtx[4]),
      DailyAverage('${dty[5]}', dtx[5]),
      DailyAverage('${dty[6]}', dtx[6]),
    ];

    List<ColumnSeries<DailyAverage, String>> _columnData = [
      ColumnSeries<DailyAverage, String>(
        color: cAsiaBlue,
        borderColor: Colors.red,
        trackColor: Colors.teal,
        dataSource: weeklyData,
        // borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), topRight: Radius.circular(10)),
        xValueMapper: (data, _) => data.day,
        yValueMapper: (data, _) => data.average,
      ),
    ];

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
          maximum: 24 - dtx.reduce(max) < 1 ? 24 : dtx.reduce(max) ~/ 1 + 1),
      series: _columnData,
      tooltipBehavior: TooltipBehavior(
          enable: true,
          canShowMarker: false,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
            print(
                '${point.x} : ${point.y ~/ 1}h ${((point.y - (point.y ~/ 1)) * 60) ~/ 1}m');
            return Container(
                margin: EdgeInsets.all(5),
                child: Text(
                    '${point.x} : ${point.y ~/ 1}h ${((point.y - (point.y ~/ 1)) * 60) ~/ 1}m',
                    style: TextStyle(color: cOrtuWhite)));
          },
          header: ''),
    );
  }

  Widget modeAsuhLevelTile({
    required Widget leading,
    required Widget title,
    required Widget subtitle,
  }) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: EdgeInsets.only(top: 15, bottom: 5), child: title),
                subtitle,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<AppListWithIcons>> fetchAppList() async {
    prefs = await SharedPreferences.getInstance();

    var response = await MediaRepository().fetchAppList(widget.email);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        // print("response aplikasi list : " + json.toString());
        if (json['appdevices'].length > 0) {
          try {
            var appDevices = json['appdevices'][0];
            List<dynamic> tmpData = appDevices['appName'];
            prefs.setString("ID_CHILD_USAGE", appDevices['_id']);
            List<dynamic> dataList = [];

            List<ApplicationInstalled> dataAppsInstalled =
                List<ApplicationInstalled>.from(tmpData
                    .map((model) => ApplicationInstalled.fromJson(model)));
            var imageUrl = "${prefs.getString(rkBaseUrlAppIcon)}";

            List<AppIconList> dataListIconApps = [];
            if (prefs.getString(rkListAppIcons) != null) {
              var respList = jsonDecode(prefs.getString(rkListAppIcons)!);
              var listIcons = respList['appIcons'];
              dataListIconApps = List<AppIconList>.from(
                  listIcons.map((model) => AppIconList.fromJson(model)));
            }

            for (int i = 0; i < dataAppsInstalled.length; i++) {
              final appIcon = dataListIconApps
                  .where((e) => e.appId == dataAppsInstalled[i].packageId)
                  .toList();
              dataList.add({
                "appName": "${dataAppsInstalled[i].appName}",
                "packageId": "${dataAppsInstalled[i].packageId}",
                "blacklist": dataAppsInstalled[i].blacklist,
                "appCategory": dataAppsInstalled[i].appCategory,
                "limit": (dataAppsInstalled[i].limit != null)
                    ? dataAppsInstalled[i].limit.toString()
                    : '0',
                "appIcons": appIcon.length > 0
                    ? "${imageUrl + appIcon.first.appIcon.toString()}"
                    : '',
              });
            }
            List<AppListWithIcons> data = List<AppListWithIcons>.from(
                dataList.map((model) => AppListWithIcons.fromJson(model)));
            data.sort((a, b) => a.appName!.compareTo(b.appName!));
            setState(() {
              detailAplikasiChild = data;
            });
            return data;
          } catch (e, s) {
            print(e);
            print(s);
            return [];
          }
        } else {
          return [];
        }
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<dynamic>> fetchListModeAsuhh() async {
    var response = await MediaRepository().fetchListModeAsuh(widget.email);
    if (response.statusCode == 200) {
      // print('Fetch mode asuh: ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        if (json['modeAsuh'].length > 0) {
          return json['modeAsuh'];
        } else {
          return [];
        }
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<void> fetchModeLock() async {
    var response = await MediaRepository().fetchModeLock(widget.email);
    print('isi response fetchModeLock : ${response.body}');
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        if (json['resultData'] != null) {
          var result = json['resultData'];
          if (result['lockStatus'] != null) {
            setState(() {
              _switchLockScreen = result['lockStatus'];
              _loadingLockScreen = true;
            });
          } else {
            setState(() {
              _loadingLockScreen = true;
            });
          }
        } else {
          setState(() {
            _loadingLockScreen = true;
          });
        }
      } else {
        setState(() {
          _loadingLockScreen = true;
        });
      }
    } else {
      setState(() {
        _loadingLockScreen = true;
      });
    }
  }

  Future<void> fetchUpdateModeLock(bool lockStatus) async {
    showLoadingOverlay();
    var response =
        await MediaRepository().fetchUpdateModeLock(widget.email, lockStatus);
    print('isi response fetchUpdateModeLock : ${response.body}');
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        if (json['resultData'] != null) {
          var result = json['resultData'];
          print('lockStatus : ${result['lockStatus']}');
          if (result['lockStatus'] != null) {
            setState(() {
              _switchLockScreen = result['lockStatus'];
            });
            closeOverlay();
            showToastSuccess(
                ctx: context,
                successText: 'Perubahan mode kunci layar berhasil!');
          } else {
            closeOverlay();
            showToastFailed(
                ctx: context, failedText: 'Perubahan mode kunci layar gagal!');
          }
        } else {
          closeOverlay();
          showToastFailed(
              ctx: context, failedText: 'Perubahan mode kunci layar gagal!');
        }
      } else {
        closeOverlay();
        showToastFailed(
            ctx: context, failedText: 'Perubahan mode kunci layar gagal!');
      }
    } else {
      closeOverlay();
      showToastFailed(
          ctx: context, failedText: 'Perubahan mode kunci layar gagal!');
    }
  }

  Future<dynamic> filterModeAsuhh() async {
    var response = await MediaRepository().filterModeAsuh(widget.email);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        if (json['childModeAsuhs'].length > 0) {
          return json['childModeAsuhs'];
        } else {
          return [];
        }
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<bool> updateModeAsuhh(String modeAsuhName) async {
    var response =
        await MediaRepository().updateModeAsuh(widget.email, modeAsuhName);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  void getModeAsuh() {
    if (_loadingGetData) {
      showLoadingOverlay();
    }
    fetchListModeAsuhh().then((value1) {
      if (value1 != null && value1.length > 0) {
        filterModeAsuhh().then((value2) {
          if (value2 != null) {
            if (value2['modeAsuh'] != null &&
                value2['modeAsuhName'] != null &&
                value2['modeAsuh'].toString().toUpperCase() == 'ON' &&
                value2['modeAsuhName'].toString().isNotEmpty) {
              fetchAppList().then((value) async {
                setState(() {
                  dataModeAsuh = value1;
                  _switchModeAsuh = true;
                  var data = dataModeAsuh
                      .where((element) =>
                          element['modeAsuhName'].toString().toLowerCase() ==
                          value2['modeAsuhName'].toString().toLowerCase())
                      .first;
                  if (data != null) {
                    _switchLevel = dataModeAsuh.indexOf(data);
                  } else {
                    _switchLevel = 0;
                  }
                });
                if (_loadingGetData) {
                  closeOverlay();
                }
              }).onError((error, stackTrace) {
                if (_loadingGetData) {
                  closeOverlay();
                }
              });
            } else {
              fetchAppList().then((value) async {
                setState(() {
                  dataModeAsuh = value1;
                  _switchModeAsuh = false;
                  _switchLevel = 0;
                });
                if (_loadingGetData) {
                  closeOverlay();
                }
              }).onError((error, stackTrace) {
                if (_loadingGetData) {
                  closeOverlay();
                }
              });
            }
          } else {
            fetchAppList().then((value) async {
              setState(() {
                dataModeAsuh = value1;
                _switchModeAsuh = false;
                _switchLevel = 0;
              });
              if (_loadingGetData) {
                closeOverlay();
              }
            }).onError((error, stackTrace) {
              if (_loadingGetData) {
                closeOverlay();
              }
            });
          }
        }).onError((error, stackTrace) {
          if (_loadingGetData) {
            closeOverlay();
          }
        });
      } else {
        if (_loadingGetData) {
          closeOverlay();
        }
      }
    }).onError((error, stackTrace) {
      if (_loadingGetData) {
        closeOverlay();
      }
    });
  }

  Future<void> updateDatatoFirebase(int index) async {
    showLoadingOverlay();
    List<Map<String, dynamic>> data = [];
    var id_child_usage = await prefs.getString('ID_CHILD_USAGE');
    if (id_child_usage != null) {
      if (dataModeAsuh.length > 0) {
        String namaModeAsuh = '';
        if (_switchModeAsuh) {
          namaModeAsuh = dataModeAsuh[index]['modeAsuhName'];
        }
        updateModeAsuhh(namaModeAsuh).then((value) {
          closeOverlay();
        }).onError((error, stackTrace) {
          closeOverlay();
        });
      }
    }
  }
}

/// Sample sales data type.
class DailyAverage {
  final String day;
  final double average;

  DailyAverage(this.day, this.average);
}
