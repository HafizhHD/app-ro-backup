import 'dart:convert';
import 'package:http/http.dart';
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

class DetailChildActivityPage extends StatefulWidget {
  final String name;
  final String email;
  final List<AppUsages> listAppUsageWeekly;
  final String averageTimeWeekly;
  final Widget weeklyChart;
  final String lastUpdate;

  @override
  _DetailChildActivityPageState createState() => _DetailChildActivityPageState();

  DetailChildActivityPage({
    Key? key,
    required this.name,
    required this.email,
    required this.listAppUsageWeekly,
    required this.averageTimeWeekly,
    required this.weeklyChart,
    required this.lastUpdate,
  }) : super(key: key);
}

class _DetailChildActivityPageState extends State<DetailChildActivityPage> {
  var inactiveColor = Colors.grey[700];
  var activeColor = Colors.grey[400];
  var types = 'week';
  int perPage = 7;
  int present = 0;
  int usageDatas = 0;
  int usageDataBar = 0;
  late Future<List<Application>> apps;
  SharedPreferences? prefs;
  String totalScreenTime = "";
  String avgTime = '0s';
  String avgTimeDaily = '0s';
  String totalToday = '0s';
  var dtx = [0, 0, 0, 0, 0, 0, 0];
  var dty = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  var dtxDaily = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  var dtyDaily = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];
  int countUsage = 1;

  Map<String, AppUsagesDetail> mapWeeklyAppUsage = {};
  Map<String, AppUsagesDetail> mapDailyAppUsage = {};

  late List<AppIconList> dataListIconApps;
  Map<String, String> mapAppIcon = {};
  String imageUrl = '';

  Future loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    var respList = jsonDecode(prefs!.getString(rkListAppIcons)!);
    imageUrl = "${prefs!.getString(rkBaseUrlAppIcon)}";

    var listIcons = respList['appIcons'];
    dataListIconApps = List<AppIconList>.from(listIcons.map((model) => AppIconList.fromJson(model)));
    dataListIconApps.forEach((e) {
      mapAppIcon[e.appId!] = e.appIcon!;
    });
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

  Future<List<dynamic>> getUsageStatsDaily() async {
    try {
      prefs = await SharedPreferences.getInstance();
      var outputFormat = DateFormat('yyyy-MM-dd');
      var outputDate = outputFormat.format(DateTime.now());
      List<dynamic> tmpReturn = [];
      List<dynamic> dataList = [];
      Response response = await MediaRepository().fetchAppUsageFilter(widget.email, outputDate);
      if (response.statusCode == 200) {
        print('isi response filter app usage : ${response.body}');
        var json = jsonDecode(response.body);
        if (json['resultCode'] == "OK") {
          var jsonDataResult = json['appUsages'] as List;
          if (jsonDataResult.length == 0) {
            return [];
          } else {
            tmpReturn = jsonDataResult[jsonDataResult.length - 1]['appUsages'] as List;
            tmpReturn.sort((a, b) {
              var aUsage = a['duration']; //before -> var adate = a.expiry;
              var bUsage = b['duration']; //before -> var bdate = b.expiry;
              return bUsage.compareTo(aUsage); //to get the order other way just switch `adate & bdate`
            });

            if (prefs!.getString(rkListAppIcons) != null) {
              var respList = jsonDecode(prefs!.getString(rkListAppIcons)!);
              var listIcons = respList['appIcons'];
              List<AppIconList> dataListIconApps = List<AppIconList>.from(listIcons.map((model) => AppIconList.fromJson(model)));
              var imageUrl = "${prefs!.getString(rkBaseUrlAppIcon)}";
              bool flagX = false;
              int indeksX = 0;
              for (int i = 0; i < tmpReturn.length; i++) {
                if (dataListIconApps.length > 0) {
                  for (int x = 0; x < dataListIconApps.length; x++) {
                    if (tmpReturn[i]['packageId'] == dataListIconApps[x].appId) {
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
                      "icon": "${imageUrl + dataListIconApps[indeksX].appIcon.toString()}"
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
                return bUsage.compareTo(aUsage); //to get the order other way just switch `adate & bdate`
              });
            } else {
              dataList = tmpReturn;
            }
          }
        }
      } else {
        print('isi response filter app usage : ${response.statusCode}');
      }
      return dataList;
      // return [];
    } on AppUsageException catch (exception) {
      print(exception);
      return [];
    }
  }

  Future setWeeklyData() async {
    widget.listAppUsageWeekly.forEach((appInfo) {
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
    setState(() {});
  }

  Future<bool?> dataHasLoad() async {
    if (mapWeeklyAppUsage.length > 0) return true;
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
    await setWeeklyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: cPrimaryBg,
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.name, style: TextStyle(color: cOrtuWhite)),
          backgroundColor: cPrimaryBg,
          iconTheme: IconThemeData(color: Colors.grey.shade700),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: cOrtuWhite),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0,
        ),
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
                chartDetail(types),
                Flexible(child: onLoadMostUsage(types)),
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
                margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
                child: Text('MOST USED', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cOrtuWhite)),
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

  Widget chartDetail(String type) {
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
              type == 'week' ? widget.averageTimeWeekly : avgTimeDaily,
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
            child: type == 'week' ? widget.weeklyChart : _chartDailyAverage(),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, left: 15),
            child: Align(
                alignment: Alignment.centerLeft, child: Text('Update today ${widget.lastUpdate}', style: TextStyle(fontSize: 14, color: cOrtuWhite))),
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
      tooltipBehavior: TooltipBehavior(enable: true, canShowMarker: false, format: 'point.x : point.y', header: ''),
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

                return ListTile(
                  leading: app.iconUrl != null && app.iconUrl != ''
                      ? Container(
                          margin: EdgeInsets.all(5).copyWith(right: 10),
                          child: Image.network(
                            imageUrl + app.iconUrl! ?? '',
                            height: 50,
                            fit: BoxFit.contain,
                          ))
                      : Container(
                          margin: EdgeInsets.all(5).copyWith(right: 10),
                          color: Colors.green,
                          height: 50,
                          child: Center(
                            child: Icon(Icons.android),
                          ),
                        ),
                  title: Text(app.appName, style: TextStyle(color: cOrtuWhite)),
                  subtitle: Row(
                    children: <Widget>[
                      Container(
                        width: (app.duration / appList[0].duration) * 200,
                        height: 5,
                        margin: EdgeInsets.only(right: 10.0),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
    return Container(
      child: Center(
        child: Text(
          'Data Kosong',
          style: TextStyle(color: cOrtuGrey),
        ),
      ),
    );
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
  final int average;

  DailyAverage(this.day, this.average);
}
