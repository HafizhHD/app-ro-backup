import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_child_app_icon_list.dart';
import 'package:ruangkeluarga/parent/view_model/appUsage_model.dart';
import 'package:ruangkeluarga/plugin_device_app.dart';
import 'package:ruangkeluarga/utils/app_usage.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'main/parent_controller.dart';

class DetailChildActivityPage extends StatefulWidget {
  final String name;
  final String email;
  //final List<AppUsages> listAppUsageWeekly;
  //final String averageTimeWeekly;
  //final Widget weeklyChart;
  final String lastUpdate;

  @override
  _DetailChildActivityPageState createState() =>
      _DetailChildActivityPageState();

  DetailChildActivityPage({
    Key? key,
    required this.name,
    required this.email,
    //required this.listAppUsageWeekly,
    //required this.averageTimeWeekly,
    //required this.weeklyChart,
    required this.lastUpdate,
  }) : super(key: key);
}

class _DetailChildActivityPageState extends State<DetailChildActivityPage> {
  final parentController = Get.find<ParentController>();
  var inactiveColor = Colors.grey[700];
  var activeColor = Colors.grey[400];
  var types = 'week';
  int perPage = 7;
  int present = 0;
  int usageDatas = 0;
  int usageDataBar = 0;
  late Future<List<Application>> apps;

  List<AppUsages> listAppUsage = [], listAppUsageWeekly = [];
  String avgData = '0s', averageTimeWeekly = '0s';
  String lastUpdated = '';

  SharedPreferences? prefs;
  String totalScreenTime = "";
  String avgTime = '0s';
  String avgTimeDaily = '0s';
  String totalToday = '0s';
  var dtx = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  var dty = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  var dtxDaily = [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0
  ];
  var dtyDaily = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23
  ];
  int countUsage = 1;

  Map<String, AppUsagesDetail> mapWeeklyAppUsage = {};
  Map<String, AppUsagesDetail> mapDailyAppUsage = {};
  List<dynamic> dailyAppUsage = [];

  late List<AppIconList> dataListIconApps;
  Map<String, String> mapAppIcon = {};
  String imageUrl = '';

  Future loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    var respList = jsonDecode(prefs!.getString(rkListAppIcons)!);
    imageUrl = "${prefs!.getString(rkBaseUrlAppIcon)}";

    var listIcons = respList['appIcons'];
    dataListIconApps = List<AppIconList>.from(
        listIcons.map((model) => AppIconList.fromJson(model)));
    dataListIconApps.forEach((e) {
      mapAppIcon[e.appId!] = e.appIcon!;
    });
  }

  Future<void> onGetUsageDataDaily() async {
    listAppUsage.forEach((e) {
      e.appUsagesDetail.forEach((f) {
        f.duration = 0;
        // f.usageHour!.forEach((g) {
        //   print('Ini adalah time untuk ${f.appName}: ${g["durationInStamp"]}');
        // });
      });
    });
    double avgDataDaily = 0;
    DateTime dateTime = DateTime.now();
    for (int i = 0; i < dtxDaily.length; i++) {
      var hourly = dateTime.subtract(Duration(
          hours: dateTime.hour - i,
          minutes: dateTime.minute,
          seconds: dateTime.second,
          milliseconds: dateTime.millisecond));
      dtxDaily[i] = await getHourlyUsageStatistik(hourly) / 1.0;
      avgDataDaily += dtxDaily[i];
      dtxDaily[i] /= 60;
      print('Ini $i, ${dtxDaily[i]}');
    }
    setState(() {
      avgData = parentController.setAverageDaily(avgDataDaily ~/ 1.0);
    });
    await setDailyData();
  }

  Future<int> getHourlyUsageStatistik(DateTime tanggal) async {
    prefs = await SharedPreferences.getInstance();

    int seconds = 0;
    print('Ini tanggal: ${tanggal.toLocal().toString()}');
    setState(() {
      listAppUsage.forEach((e) {
        e.appUsagesDetail.forEach((f) {
          int totalSecsPerApp = 0;
          f.usageHour!.forEach((t) {
            int secondsPerApp = 0;
            var lastTimeStamp = DateTime.parse(t['lastTimeStamp']);
            var startTimeStamp = lastTimeStamp.subtract(
                Duration(milliseconds: int.parse(t['durationInStamp'])));
            print('Last time stamp: ' + lastTimeStamp.toLocal().toString());
            print('First time stamp: ' + startTimeStamp.toLocal().toString());
            Duration dif1 = lastTimeStamp.difference(tanggal);
            Duration dif2 = tanggal.difference(startTimeStamp);

            print('Masuk sini! Gils last. Dif1: $dif1, Dif2: $dif2');
            if (int.parse(t['durationInStamp']) > 0) {
              if (dif1.inSeconds >= 0) {
                if (dif1.inSeconds >= 3600) {
                  if (dif2.inSeconds >= 0) {
                    seconds += 3600000;
                    secondsPerApp += 3600000;
                  } else if (-dif2.inSeconds < 3600) {
                    seconds += 3600000 + dif2.inMilliseconds;
                    secondsPerApp += 3600000 + dif2.inMilliseconds;
                  }
                } else {
                  if (dif2.inSeconds < 0) {
                    seconds += int.parse(t['durationInStamp']);
                    secondsPerApp += int.parse(t['durationInStamp']);
                  } else {
                    seconds += dif1.inMilliseconds;
                    secondsPerApp += dif1.inMilliseconds;
                  }
                }
              }
            }
            print(
                'Durasi menit untuk aplikasi ${f.appName}: ${secondsPerApp ~/ 60}');
            totalSecsPerApp += secondsPerApp;
          });
          print('Total seccs per app ${f.appName}: $totalSecsPerApp');
          f.duration += totalSecsPerApp ~/ 1000;
          print('Durasi per aplikasi: ${f.duration}');
        });
      });
    });
    return seconds ~/ 1000;
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

  Future<void> onGetUsageDataWeekly() async {
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
        listAppUsageWeekly.where((e) => e.appUsageDate == tanggal);
    if (thisDayAppUsage.length > 0) {
      var data = thisDayAppUsage.first.appUsagesDetail;
      print('inilah a');
      print(thisDayAppUsage.first.appUsageDate);
      data.forEach((e) {
        print('inilah b');
        print(e.duration);
        seconds += e.duration;
      });
    }
    return seconds~/1000;
  }

  //Ga Dipake
  Future<List<dynamic>> getUsageStatsDaily() async {
    try {
      prefs = await SharedPreferences.getInstance();
      var outputFormat = DateFormat('yyyy-MM-dd');
      var outputDate = outputFormat.format(DateTime.now());
      List<dynamic> tmpReturn = [];
      List<dynamic> dataList = [];
      http.Response response = await MediaRepository()
          .fetchAppUsageFilter(widget.email, outputDate, isDaily: true);
      if (response.statusCode == 200) {
        print('isi response filter app usage si Dailynya : ${response.body}');
        var json = jsonDecode(response.body);
        if (json['resultCode'] == "OK") {
          var jsonDataResult = json['appUsages'] as List;
          if (jsonDataResult.length == 0) {
            return [];
          } else {
            tmpReturn =
                jsonDataResult[jsonDataResult.length - 1]['appUsages'] as List;
            tmpReturn.sort((a, b) {
              var aUsage = a['duration']; //before -> var adate = a.expiry;
              var bUsage = b['duration']; //before -> var bdate = b.expiry;
              return bUsage.compareTo(
                  aUsage); //to get the order other way just switch `adate & bdate`
            });

            if (prefs!.getString(rkListAppIcons) != null) {
              var respList = jsonDecode(prefs!.getString(rkListAppIcons)!);
              var listIcons = respList['appIcons'];
              List<AppIconList> dataListIconApps = List<AppIconList>.from(
                  listIcons.map((model) => AppIconList.fromJson(model)));
              var imageUrl = "${prefs!.getString(rkBaseUrlAppIcon)}";
              bool flagX = false;
              int indeksX = 0;
              for (int i = 0; i < tmpReturn.length; i++) {
                if (dataListIconApps.length > 0) {
                  for (int x = 0; x < dataListIconApps.length; x++) {
                    if (tmpReturn[i]['packageId'] ==
                        dataListIconApps[x].appId) {
                      indeksX = x;
                      flagX = true;
                      break;
                    }
                  }
                  if (flagX) {
                    dataList.add({
                      "packageId": "${tmpReturn[i]['packageId']}",
                      "appName": tmpReturn[i]['appName'],
                      "duration": tmpReturn[i]['duration'],
                      "icon":
                          "${imageUrl + dataListIconApps[indeksX].appIcon.toString()}"
                    });
                  } else {
                    dataList.add({
                      "packageId": "${tmpReturn[i]['packageId']}",
                      "appName": tmpReturn[i]['appName'],
                      "duration": tmpReturn[i]['duration'],
                      "icon": ""
                    });
                  }
                }
              }
              dataList.sort((a, b) {
                var aUsage = a['duration']; //before -> var adate = a.expiry;
                var bUsage = b['duration']; //before -> var bdate = b.expiry;
                return bUsage.compareTo(
                    aUsage); //to get the order other way just switch `adate & bdate`
              });
            } else {
              dataList = tmpReturn;
            }
          }
        }
      } else {
        print(
            'isi response filter app usage dailynya bruh : ${response.statusCode}');
      }
      print('Isi dataList: $dataList');
      return dataList;
      // return [];
    } on AppUsageException catch (exception) {
      print(exception);
      return [];
    }
  }

  Future setWeeklyData() async {
    setState(() {
      //print(widget.weeklyChart.toString());
      mapWeeklyAppUsage = {};
      listAppUsageWeekly.forEach((appInfo) {
        appInfo.appUsagesDetail.forEach((appDetail) {
          final temp = mapWeeklyAppUsage[appDetail.packageId];
          if (temp != null) {
            temp.duration += appDetail.duration;
            mapWeeklyAppUsage[appDetail.packageId] = temp;
          } else {
            mapWeeklyAppUsage[appDetail.packageId] = AppUsagesDetail(
              appName: appDetail.appName,
              packageId: appDetail.packageId,
              duration: appDetail.duration,
              appCategory: appDetail.appCategory,
              iconUrl: mapAppIcon[appDetail.packageId],
            );
          }
        });
      });
    });
  }

  Future setDailyData() async {
    setState(() {
      mapDailyAppUsage = {};
      listAppUsage.forEach((appInfo) {
        appInfo.appUsagesDetail.forEach((appDetail) {
          final temp = mapDailyAppUsage[appDetail.packageId];
          if (temp != null) {
            temp.duration += appDetail.duration;
            mapDailyAppUsage[appDetail.packageId] = temp;
          } else {
            mapDailyAppUsage[appDetail.packageId] = AppUsagesDetail(
              appName: appDetail.appName,
              packageId: appDetail.packageId,
              duration: appDetail.duration,
              appCategory: appDetail.appCategory,
              iconUrl: mapAppIcon[appDetail.packageId],
            );
          }
        });
      });
    });
  }

  Future<bool?> dataHasLoad() async {
    if (mapWeeklyAppUsage.length > 0) return true;
    return null;
  }

  Future<bool?> dataDailyHasLoad() async {
    if (mapDailyAppUsage.length > 0) return true;
    return null;
  }

  @override
  void initState() {
    super.initState();
    initAsync();
    WidgetsFlutterBinding.ensureInitialized();
  }

  void initAsync() async {
    await loadPrefs();
    listAppUsage = parentController.mapChildActivityDaily[widget.email] ?? [];
    avgData = parentController.mapChildScreentimeDaily[widget.email] ?? '0s';
    listAppUsageWeekly = parentController.mapChildActivity[widget.email] ?? [];
    averageTimeWeekly =
        parentController.mapChildScreentime[widget.email] ?? '0s';
    listAppUsage.forEach((e) {
      e.appUsagesDetail.forEach((f) {
        f.duration = 0;
        f.usageHour!.forEach((g) {
          print('Ini adalah time untuk ${f.appName}: ${g["durationInStamp"]}');
        });
      });
    });
    onGetUsageDataDaily();
    onGetUsageDataWeekly();
    await setWeeklyData();
    //dailyAppUsage = await getUsageStatsDaily();
  }

  Future<void> updateChart() async {
    mapDailyAppUsage = {};
    mapWeeklyAppUsage = {};
    await parentController.getWeeklyUsageStatistic();
    await parentController.getDailyUsageStatistic();
    listAppUsage = parentController.mapChildActivityDaily[widget.email] ?? [];
    avgData = parentController.mapChildScreentimeDaily[widget.email] ?? '0s';
    listAppUsageWeekly = parentController.mapChildActivity[widget.email] ?? [];
    averageTimeWeekly =
        parentController.mapChildScreentime[widget.email] ?? '0s';
    listAppUsage.forEach((e) {
      e.appUsagesDetail.forEach((f) {
        f.duration = 0;
        f.usageHour!.forEach((g) {
          print('Ini adalah time untuk ${f.appName}: ${g["durationInStamp"]}');
        });
      });
    });
    lastUpdated = now_HHmm();
    await onGetUsageDataDaily();
    await onGetUsageDataWeekly();
    await setWeeklyData();
    await Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      centerTitle: true,
      title: Text(widget.name, style: TextStyle(color: cOrtuWhite)),
      backgroundColor: cPrimaryBg,
      iconTheme: IconThemeData(color: Colors.grey.shade700),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: cOrtuWhite),
        onPressed: () => Navigator.of(context).pop(),
      ),
      elevation: 0,
    );
    return Scaffold(
        backgroundColor: cPrimaryBg,
        appBar: appBar,
        body: Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ToggleBar(
                    labels: ['Mingguan', 'Harian'],
                    onSelectionUpdated: (index) {
                      if (index == 0)
                        types = 'week';
                      else
                        types = 'day';
                      setState(() {});
                    }),
                RefreshIndicator(
                    onRefresh: () async {
                      await updateChart();
                      await updateChart();
                    },
                    child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        child: Container(
                            height: MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top * 1.5 -
                                appBar.preferredSize.height * 2,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  chartDetail(types, updateChart),
                                  Flexible(child: onLoadMostUsage(types))
                                ]))))
              ],
            )));
  }

  Widget onLoadMostUsage(String type) {
    return Theme(
      data: ThemeData.dark(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
                child: Text('MOST USED',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cOrtuWhite)),
              ),
            ],
          ),
          Flexible(
            child: Container(
              height: 400,
              margin: EdgeInsets.all(10.0),
              child: type == 'week' ? onMostWeekData() : onMostDay(),
            ),
          ),
        ],
      ),
    );
  }

  Widget chartDetail(String type, updateChart) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(10.0),
            child: Text(
              type == 'week' ? 'Rata-rata Mingguan' : 'Rata-rata Harian',
              style: TextStyle(fontSize: 16, color: cOrtuWhite),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10.0),
            child: Text(
              type == 'week' ? averageTimeWeekly : avgData,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cOrtuWhite,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10.0),
            height: MediaQuery.of(context).size.height / 4,
            child:
                type == 'week' ? _chartWeeklyAverage() : _chartDailyAverage(),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Update today ${lastUpdated != '' ? lastUpdated : widget.lastUpdate}',
                      style: TextStyle(fontSize: 14, color: cOrtuWhite)),
                  TextButton(
                      style: TextButton.styleFrom(
                          textStyle: TextStyle(fontSize: 14, color: cOrtuBlue)),
                      onPressed: () async {
                        showLoadingOverlay();
                        await updateChart();
                        await updateChart();
                        closeOverlay(); //second call for actually update the chart
                      },
                      child:
                          Row(children: [Icon(Icons.refresh), Text('Refresh')]))
                ]),
          ),
        ],
      ),
    );
  }

  Widget _chartDailyAverage() {
    final desktopSalesData = [
      DailyAverage('${dtyDaily[0]}', dtxDaily[0]),
      DailyAverage('${dtyDaily[1]}', dtxDaily[1]),
      DailyAverage('${dtyDaily[2]}', dtxDaily[2]),
      DailyAverage('${dtyDaily[3]}', dtxDaily[3]),
      DailyAverage('${dtyDaily[4]}', dtxDaily[4]),
      DailyAverage('${dtyDaily[5]}', dtxDaily[5]),
      DailyAverage('${dtyDaily[6]}', dtxDaily[6]),
      DailyAverage('${dtyDaily[7]}', dtxDaily[7]),
      DailyAverage('${dtyDaily[8]}', dtxDaily[8]),
      DailyAverage('${dtyDaily[9]}', dtxDaily[9]),
      DailyAverage('${dtyDaily[10]}', dtxDaily[10]),
      DailyAverage('${dtyDaily[11]}', dtxDaily[11]),
      DailyAverage('${dtyDaily[12]}', dtxDaily[12]),
      DailyAverage('${dtyDaily[13]}', dtxDaily[13]),
      DailyAverage('${dtyDaily[14]}', dtxDaily[14]),
      DailyAverage('${dtyDaily[15]}', dtxDaily[15]),
      DailyAverage('${dtyDaily[16]}', dtxDaily[16]),
      DailyAverage('${dtyDaily[17]}', dtxDaily[17]),
      DailyAverage('${dtyDaily[18]}', dtxDaily[18]),
      DailyAverage('${dtyDaily[19]}', dtxDaily[19]),
      DailyAverage('${dtyDaily[20]}', dtxDaily[20]),
      DailyAverage('${dtyDaily[21]}', dtxDaily[21]),
      DailyAverage('${dtyDaily[22]}', dtxDaily[22]),
      DailyAverage('${dtyDaily[23]}', dtxDaily[23]),
    ];

    List<ColumnSeries<DailyAverage, String>> _columnData = [
      ColumnSeries<DailyAverage, String>(
        color: cOrtuBlue,
        borderColor: Colors.red,
        trackColor: Colors.teal,
        dataSource: desktopSalesData,
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
      series: _columnData,
      tooltipBehavior: TooltipBehavior(
          enable: true,
          canShowMarker: false,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
            print(
                '${point.x} : ${point.y ~/ 1}m ${((point.y - (point.y ~/ 1)) * 60) ~/ 1}s');
            return Container(
                margin: EdgeInsets.all(5),
                child: Text(
                    '${point.x} : ${point.y ~/ 1}m ${((point.y - (point.y ~/ 1)) * 60) ~/ 1}s',
                    style: TextStyle(color: cOrtuWhite)));
          },
          header: ''),
    );
  }

  Widget _chartWeeklyAverage() {
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
        color: cOrtuBlue,
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

  Widget onMostWeekData() {
    List<AppUsagesDetail> appList = [];
    mapWeeklyAppUsage.forEach((key, appData) {
      appList.add(appData);
    });
    appList.sort((a, b) => b.duration.compareTo(a.duration));
    return FutureBuilder(
        future: dataHasLoad(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return wProgressIndicator();
          return Container(
            child: ListView.separated(
              separatorBuilder: (ctx, idx) => Divider(height: 1),
              itemCount: appList.length,
              itemBuilder: (ctx, index) {
                final app = appList[index];
                var secs = app.duration ~/ 1000;
                int jam = 0;
                if (secs >= 3600) {
                  jam = secs ~/ 3600;
                  secs = secs - (jam * 3600);
                }
                int menit = 0;
                if (secs >= 60) {
                  menit = secs ~/ 60;
                  secs = secs - (menit * 60);
                }
                int sec = secs;
                String usageData = "0s";
                if (jam == 0) {
                  if (menit == 0) {
                    usageData = "${sec.toString()}s";
                  } else {
                    usageData = "${menit.toString()}m ${sec.toString()}s";
                  }
                } else {
                  usageData = "${jam.toString()}h ${menit.toString()}m";
                }

                String iconUrl =  app.iconUrl! ?? '';
                return ListTile(
                  leading: app.iconUrl != null && app.iconUrl != ''
                      ? Container(
                          margin: EdgeInsets.all(5).copyWith(right: 10),
                          child: Image.network(
                            imageUrl + iconUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ))
                      : Container(
                          margin: EdgeInsets.all(5).copyWith(right: 10),
                          color: Colors.green,
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Icon(Icons.android),
                          ),
                        ),
                  title: Text(app.appName, style: TextStyle(color: cOrtuWhite)),
                  subtitle: Row(
                    children: <Widget>[
                      Container(
                        width: (app.duration / appList[0].duration) * 180,
                        height: 5,
                        margin: EdgeInsets.only(right: 10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Color(0xffFF018786)),
                      ),
                      Text(usageData, style: TextStyle(color: cOrtuWhite))
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  Widget onMostDay() {
    List<AppUsagesDetail> appList = [];
    mapDailyAppUsage.forEach((key, appData) {
      print('usage menit: ${appData.duration}');
      if (appData.duration > 0) appList.add(appData);
    });
    appList.sort((a, b) => b.duration.compareTo(a.duration));
    return FutureBuilder(
        future: dataDailyHasLoad(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return wProgressIndicator();
          return Container(
            child: ListView.separated(
              separatorBuilder: (ctx, idx) => Divider(height: 1),
              itemCount: appList.length,
              itemBuilder: (ctx, index) {
                final app = appList[index];
                var secs = app.duration;
                int jam = 0;
                if (secs >= 3600) {
                  jam = secs ~/ 3600;
                  secs = secs - (jam * 3600);
                }
                int menit = 0;
                if (secs >= 60) {
                  menit = secs ~/ 60;
                  secs = secs - (menit * 60);
                }
                int sec = secs;
                String usageData = "0s";
                if (jam == 0) {
                  if (menit == 0) {
                    usageData = "${sec.toString()}s";
                  } else {
                    usageData = "${menit.toString()}m ${sec.toString()}s";
                  }
                } else {
                  usageData = "${jam.toString()}h ${menit.toString()}m";
                }

                String iconUrl = app.iconUrl! ?? '';
                return ListTile(
                  leading: app.iconUrl != null && app.iconUrl != ''
                      ? Container(
                          margin: EdgeInsets.all(5).copyWith(right: 10),
                          child: Image.network(
                            imageUrl + iconUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ))
                      : Container(
                          margin: EdgeInsets.all(5).copyWith(right: 10),
                          color: Colors.green,
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Icon(Icons.android),
                          ),
                        ),
                  title: Text(app.appName, style: TextStyle(color: cOrtuWhite)),
                  subtitle: Row(
                    children: <Widget>[
                      Container(
                        width: (app.duration / appList[0].duration) * 180,
                        height: 5,
                        margin: EdgeInsets.only(right: 10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Color(0xffFF018786)),
                      ),
                      Text(usageData, style: TextStyle(color: cOrtuWhite))
                    ],
                  ),
                );
              },
            ),
          );
        });
  }
}

/// Sample sales data type.
class Sales {
  final String year;
  final int sales;

  Sales(this.year, this.sales);
}

class DailyAverage {
  final String day;
  final double average;

  DailyAverage(this.day, this.average);
}
