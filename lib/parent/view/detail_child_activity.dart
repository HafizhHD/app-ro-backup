import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:ruangkeluarga/model/rk_child_app_icon_list.dart';
import 'package:ruangkeluarga/plugin_device_app.dart';
import 'package:ruangkeluarga/utils/app_usage.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailChildActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }

}

class DetailChildActivityPage extends StatefulWidget {
  final String name;
  final String email;

  @override
  _DetailChildActivityPageState createState() => _DetailChildActivityPageState();

  DetailChildActivityPage({Key? key, required this.name, required this.email}) : super(key: key);
}

class _DetailChildActivityPageState extends State<DetailChildActivityPage> {
  var inactiveColor = Colors.grey[700];
  var activeColor = Colors.grey[400];
  var types = 'week';
  bool _showSystemApps = false;
  bool _onlyLaunchableApps = false;
  int perPage  = 7;
  int present = 0;
  int usageDatas = 0;
  int usageDataBar = 0;
  late Future<List<Application>> apps;
  List<Application>? appsListData;
  List<Application> itemsApp = [];
  List<AppUsageInfo> items = [];
  List<dynamic> itemsTmp = [];
  // List<AppUsageInfo> _infos = [];
  List<dynamic> _list = [];
  List<dynamic> _infos = [];
  List<AppUsageInfo> itemsDays = [];
  List<AppUsageInfo> _infosDays = [];
  List<dynamic> _ListDays = [];
  List<dynamic> _ItemsDays = [];
  List<AppUsageInfo> tempInfos = [];
  SharedPreferences? prefs;
  String totalScreenTime = "";
  String avgTime = '0s';
  String avgTimeDaily = '0s';
  String totalToday = '0s';
  String dateToday = '00.01';
  var dtx = [0,0,0,0,0,0,0];
  var dty = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
  var dtxDaily = [0,0,0,0,0,0,0];
  var dtyDaily = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
  int countUsage = 1;
  String lineWeekStatus = 'Minggu Lalu';

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

  List<charts.Series<Sales, String>> _createRandomDataDaily() {
    final random = Random();

    final desktopSalesData = [
      Sales('${dtyDaily[0]}', dtxDaily[0]),
      Sales('${dtyDaily[1]}', dtxDaily[1]),
      Sales('${dtyDaily[2]}', dtxDaily[2]),
      Sales('${dtyDaily[3]}', dtxDaily[3]),
      Sales('${dtyDaily[4]}', dtxDaily[4]),
      Sales('${dtyDaily[5]}', dtxDaily[5]),
      Sales('${dtyDaily[6]}', dtxDaily[6]),
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

  void showMoredata(String type) {
    if (type == "week") {
      setState(() {
        // int indeks = apps.length - items.length;
        int indeks = _infos.length - itemsTmp.length;
        if (indeks > perPage) {
          present = itemsTmp.length + perPage;
        } else {
          present = itemsTmp.length + indeks;
        }
      });
    }
    else {
      setState(() {
        // int indeks = apps.length - items.length;
        int indeks = _ListDays.length - _ItemsDays.length;
        if (indeks > perPage) {
          present = _ItemsDays.length + perPage;
        } else {
          present = _ItemsDays.length + indeks;
        }
      });
    }
  }

  void loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    String data = prefs!.getString('appsLists') ?? '';
    itemsApp = json.decode(data);
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

  void calculateTotalScreenTime(List<AppUsageInfo> infoList) {
    int jam = 0;
    int menit = 0;
    int detik = 0;
    for(int i = 0; i < infoList.length; i++) {
      var dt = infoList[i].usage.toString().split(".")[0];
      var dataUsage = dt.split(":");
      jam = jam + int.parse(dataUsage[0]);
      menit = menit + int.parse(dataUsage[1]);
      detik = detik + int.parse(dataUsage[2]);
    }
    var tmpMenit = detik / 60;
    menit = menit + tmpMenit.toInt();
    var tmpJam = menit / 60;
    jam = jam + tmpJam.toInt();

    var dataDetik = (jam * 3600) + ((menit % 60) * 60);
    var tmpAvgDetik = dataDetik / 4;
    int avgResultHour = tmpAvgDetik.toInt() ~/ 3600;
    int avgResultMeniute = tmpAvgDetik.toInt() % 60;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      totalScreenTime = "${jam}h ${menit % 60}m";
      avgTime = "${avgResultHour}h ${avgResultMeniute}m";
    });
    // totalScreenTime = "${jam}h ${menit % 60}m";
    // avgTime = "${avgResultHour}h ${avgResultMeniute}m";
    // setState(() {});
  }

  Future<List<AppUsageInfo>> getUsageStats() async {
    try {
     /* appsListData = await getListApps();
      DateTime endDate = findLastDateOfTheWeek(DateTime.now());
      // DateTime startDate = endDate.subtract(Duration(hours: 1));
      DateTime startDate = findFirstDateOfTheWeek(DateTime.now());
      List<AppUsageInfo> infoList = await AppUsage.getAppUsage(startDate, endDate);

      infoList.sort((a,b) {
        var aUsage = a.usage; //before -> var adate = a.expiry;
        var bUsage = b.usage; //before -> var bdate = b.expiry;
        return bUsage.compareTo(aUsage); //to get the order other way just switch `adate & bdate`
      });
      tempInfos = infoList;
      calculateTotalScreenTime(tempInfos);*/
      // return infoList;
      return [];
    } on AppUsageException catch (exception) {
      print(exception);
      return [];
    }
  }

  Future<List<AppUsageInfo>> getUsageStatsDailyTemp() async {
    try {
      // prefs = await SharedPreferences.getInstance();
      // var outputFormat = DateFormat('yyyy-MM-dd');
      // var outputDate = outputFormat.format(DateTime.now());
      // List<dynamic> tmpReturn = [];
      // Response response = await MediaRepository().fetchAppUsageFilter(widget.email, outputDate);
      // if(response.statusCode == 200) {
      //   print('isi response filter app usage : ${response.body}');
      //   var json = jsonDecode(response.body);
      //   if (json['resultCode'] == "OK") {
      //     var jsonDataResult = json['appUsages'] as List;
      //     if(jsonDataResult.length == 0) {
      //       return [];
      //     } else {
      //       tmpReturn = jsonDataResult[jsonDataResult.length - 1]['appUsages'] as List;
      //       tmpReturn.sort((a, b) {
      //         var aUsage = a['duration']; //before -> var adate = a.expiry;
      //         var bUsage = b['duration']; //before -> var bdate = b.expiry;
      //         return bUsage.compareTo(
      //             aUsage); //to get the order other way just switch `adate & bdate`
      //       });
      //     }
      //   }
      // } else {
      //   print('isi response filter app usage : ${response.statusCode}');
      // }
      // return tmpReturn;
      return [];
    } on AppUsageException catch (exception) {
      print(exception);
      return [];
    }
  }

  Future<List<dynamic>> getUsageStatsDaily() async {
    try {
      prefs = await SharedPreferences.getInstance();
      var outputFormat = DateFormat('yyyy-MM-dd');
      var outputDate = outputFormat.format(DateTime.now());
      List<dynamic> tmpReturn = [];
      List<dynamic> dataList = [];
      Response response = await MediaRepository().fetchAppUsageFilter(widget.email, outputDate);
      if(response.statusCode == 200) {
        print('isi response filter app usage : ${response.body}');
        var json = jsonDecode(response.body);
        if (json['resultCode'] == "OK") {
          var jsonDataResult = json['appUsages'] as List;
          if(jsonDataResult.length == 0) {
            return [];
          } else {
            tmpReturn = jsonDataResult[jsonDataResult.length - 1]['appUsages'] as List;
            tmpReturn.sort((a, b) {
              var aUsage = a['duration']; //before -> var adate = a.expiry;
              var bUsage = b['duration']; //before -> var bdate = b.expiry;
              return bUsage.compareTo(
                  aUsage); //to get the order other way just switch `adate & bdate`
            });

            if(prefs!.getString('rkListAppIcons') != null) {
              var respList = jsonDecode(prefs!.getString('rkListAppIcons')!);
              var listIcons = respList['appIcons'];
              List<AppIconList> dataListIconApps = List<AppIconList>.from(
                  listIcons.map((model) => AppIconList.fromJson(model)));
              var imageUrl = "${prefs!.getString('rkBaseUrlAppIcon')}";
              bool flagX = false;
              int indeksX = 0;
              for(int i = 0; i < tmpReturn.length; i++) {
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
                      "icon": "${imageUrl +
                          dataListIconApps[indeksX].appIcon.toString()}"
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
            }
            else {
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

  Future<List<Application>> getListApps() async {
    try {
      /*List<Application> appData = await DeviceApps.getInstalledApplications(
          includeAppIcons: true,
          includeSystemApps: true,
          onlyAppsWithLaunchIntent: true
      );

      itemsApp = appData;*/

      // return appData;
      return [];
    } catch (exception) {
      print(exception);
      return [];
    }
  }

  String getNameAppsFromList(String package) {
    String name = "";
    for (int i = 0; i < itemsApp.length; i++) {
      if(itemsApp[i].packageName == package) {
        name = itemsApp[i].appName;
      }
    }
    return name;
  }

  Application? getIconAppsFromList(String package) {
    for (int i = 0; i < itemsApp.length; i++) {
      if(itemsApp[i].packageName == package) {
        return itemsApp[i];
      }
    }
    return null;
  }

  Future<int> getUsageStatistik() async {
    prefs = await SharedPreferences.getInstance();
    int seconds = 0;
    var outputFormat = DateFormat('yyyy-MM-dd');
    var startDate = outputFormat.format(findFirstDateOfTheWeek(DateTime.now()));
    var endDate = outputFormat.format(findLastDateOfTheWeek(DateTime.now()));
    Response response = await MediaRepository().fetchAppUsageFilterRange(widget.email, startDate, endDate);
    if(response.statusCode == 200) {
      print('isi response filter app usage : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonDataResult = json['appUsages'] as List;
        await prefs!.setString("childAppUsage", jsonEncode(jsonDataResult));
        if(jsonDataResult.length == 0) {
          await prefs!.setInt("dataMinggu${widget.email}", 0);
        } else {
          countUsage = jsonDataResult.length;
          for(int j = 0; j < jsonDataResult.length; j++) {
            var data = jsonDataResult[j]['appUsages'] as List;
            for (int i = 0; i < data.length; i++) {
              var jsonDt = data[i];
              int sec = jsonDt['duration'];
              seconds = seconds + sec;
            }
          }
          await prefs!.setInt("dataMinggu${widget.email}", seconds);
        }
      }
    } else {
      print('isi response filter app usage : ${response.statusCode}');
      await prefs!.setInt("dataMinggu${widget.email}", 0);
    }
    return seconds;
  }

  Future<List<dynamic>> getDataUsageStatistik() async {
    prefs = await SharedPreferences.getInstance();
    var outputFormat = DateFormat('yyyy-MM-dd');
    var startDate = outputFormat.format(findFirstDateOfTheWeek(DateTime.now()));
    var endDate = outputFormat.format(findLastDateOfTheWeek(DateTime.now()));
    List<dynamic> tmpReturn = [];
    List<dynamic> tmpFilterReturn = [];
    List<dynamic> tmpxData = [];
    List<dynamic> dataList = [];
    Response response = await MediaRepository().fetchAppUsageFilterRange(widget.email, startDate, endDate);
    if(response.statusCode == 200) {
      print('isi response filter app usage : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonDataResult = json['appUsages'] as List;
        if(jsonDataResult.length == 0) {
          return [];
        } else {
          tmpFilterReturn = jsonDataResult[0]['appUsages'] as List;
          List<dynamic> refData = [];
          for(int y = 1; y < jsonDataResult.length; y++) {
            List<dynamic> filterTmp = jsonDataResult[y]['appUsages'] as List;
            tmpxData = tmpFilterReturn;
            tmpFilterReturn = [];
            for(int w = 0; w < tmpxData.length; w++) {
              bool flag = false;
              for(int z = 0; z < filterTmp.length; z++) {
                if(tmpxData[w]['packageId'] == filterTmp[z]['packageId']) {
                  int durasi = int.parse(tmpxData[w]['duration'].toString()) + int.parse(filterTmp[z]['duration'].toString());
                  bool flagData = false;
                  for(int i = 0; i < tmpFilterReturn.length; i++) {
                    if(filterTmp[z]['packageId'] == tmpFilterReturn[i]['packageId']) {
                      flagData = true;
                      tmpFilterReturn.removeAt(i);
                      tmpFilterReturn.add({
                        "count": 0,
                        "appName": "${tmpxData[w]['appName']}",
                        "packageId": "${tmpxData[w]['packageId']}",
                        "duration": durasi,
                        "icon": ""
                      });
                      break;
                    }
                  }
                  if(!flagData) {
                    tmpFilterReturn.add({
                      "count": 0,
                      "appName": "${tmpxData[w]['appName']}",
                      "packageId": "${tmpxData[w]['packageId']}",
                      "duration": durasi,
                      "icon": ""
                    });
                  }
                  flag = true;
                }
                else {
                  bool flagData = false;
                  for(int i = 0; i < tmpFilterReturn.length; i++) {
                    if(filterTmp[z]['packageId'] == tmpFilterReturn[i]['packageId']) {
                      flagData = true;
                      break;
                    }
                  }
                  if(!flagData) {
                    tmpFilterReturn.add({
                      "count": 0,
                      "appName": "${filterTmp[z]['appName']}",
                      "packageId": "${filterTmp[z]['packageId']}",
                      "duration": filterTmp[z]['duration'],
                      "icon": ""
                    });
                  }
                }
              }

              if(!flag) {
                bool flagData = false;
                for(int i = 0; i < tmpFilterReturn.length; i++) {
                  if(tmpxData[w]['packageId'] == tmpFilterReturn[i]['packageId']) {
                    flagData = true;
                    break;
                  }
                }
                if(!flagData) {
                  tmpFilterReturn.add({
                    "count": 0,
                    "appName": "${tmpxData[w]['appName']}",
                    "packageId": "${tmpxData[w]['packageId']}",
                    "duration": tmpxData[w]['duration'],
                    "icon": ""
                  });
                }
              }
            }
          }
          // tmpReturn = jsonDataResult[jsonDataResult.length - 1]['appUsages'] as List;
          // for(int i = 0; i < jsonDataResult.length; i++) {
          //   tmpFilterReturn = jsonDataResult[i];
          //   tmpFilterReturn.sort((a, b) {
          //     var aUsage = a['duration']; //before -> var adate = a.expiry;
          //     var bUsage = b['duration']; //before -> var bdate = b.expiry;
          //     return bUsage.compareTo(
          //         aUsage); //to get the order other way just switch `adate & bdate`
          //   });
          //   tmpReturn.add(tmpFilterReturn);
          // }
          // tmpReturn = jsonDataResult[jsonDataResult.length - 1]['appUsages'] as List;
          tmpFilterReturn.sort((a, b) {
            var aUsage = a['duration']; //before -> var adate = a.expiry;
            var bUsage = b['duration']; //before -> var bdate = b.expiry;
            return bUsage.compareTo(
                aUsage); //to get the order other way just switch `adate & bdate`
          });

          print('fix data $tmpFilterReturn');
          /*if(prefs!.getString('rkListAppIcons') != null) {
            var respList = jsonDecode(prefs!.getString('rkListAppIcons')!);
            var listIcons = respList['appIcons'];
            List<AppIconList> dataListIconApps = List<AppIconList>.from(
                listIcons.map((model) => AppIconList.fromJson(model)));
            var imageUrl = "${prefs!.getString('rkBaseUrlAppIcon')}";
            bool flagX = false;
            int indeksX = 0;
            for(int i = 0; i < tmpReturn.length; i++) {
              if (dataListIconApps.length > 0) {
                for (int x = 0; x < tmpReturn.length; x++) {
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
                    "icon": "${imageUrl +
                        dataListIconApps[indeksX].appIcon.toString()}"
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
          }
          else {
            dataList = tmpReturn;
          }*/
        }
        /*var data = jsonDataResult[1]['appUsages'] as List;
        int seconds = 0;
        for(int i = 0; i < data.length; i++) {
          var jsonDt = data[i];
          int sec = jsonDt['duration'];
          seconds = seconds + sec;
        }
        await prefs!.setInt("dataMinggu", seconds ~/ 3600);
        usageDatas = seconds ~/ 3600;
        int secs = usageDatas * 3600;
        int tmpAvg = secs ~/ 7;
        int hour = tmpAvg ~/ 3600;
        avgTime = '${hour}h ${tmpAvg % 60}m';
        onLoadBar();
        setState(() {});*/
      }
    } else {
      print('isi response filter app usage : ${response.statusCode}');
    }
    // return dataList;
    return tmpFilterReturn;
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

    dtx = [usageFirst,usageSecond,usageThird,usageFour,usageFive,usageSix,usageLast];
    setState(() {});
  }

  Future<int> getDailyUsageStatistik(String tanggal) async {
    prefs = await SharedPreferences.getInstance();
    int seconds = 0;
    Response response = await MediaRepository().fetchAppUsageFilter(widget.email, tanggal);
    if(response.statusCode == 200) {
      print('isi response filter app usage : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonDataResult = json['appUsages'] as List;
        await prefs!.setString("childAppUsage", jsonEncode(jsonDataResult));
        if(jsonDataResult.length == 0) {
          await prefs!.setInt("dataMinggu${widget.email}", 0);
        } else {
          var data = jsonDataResult[jsonDataResult.length - 1]['appUsages'] as List;
          for (int i = 0; i < data.length; i++) {
            var jsonDt = data[i];
            int sec = jsonDt['duration'];
            seconds = seconds + sec;
          }
          await prefs!.setInt("dataMinggu${widget.email}", seconds);
        }
      }
    } else {
      print('isi response filter app usage : ${response.statusCode}');
      await prefs!.setInt("dataMinggu${widget.email}", 0);
    }
    return seconds;
  }

  String setDayName(String name) {
    String days = 'Minggu';
    if(name == 'Sunday') {
      days = 'Minggu';
    } else if(name == 'Monday') {
      days = 'Senin';
    } else if(name == 'Tuesday') {
      days = 'Selasa';
    } else if(name == 'Wednesday') {
      days = 'Rabu';
    } else if(name == 'Thursday') {
      days = 'Kamis';
    } else if(name == 'Friday') {
      days = 'Jum\'at';
    } else if(name == 'Saturday') {
      days = 'Sabtu';
    }

    return days;
  }

  void calculateDayliScreen() async {
    var dateFormat = DateFormat("yyyy-MM-dd");
    int seconds = await getDailyUsageStatistik(dateFormat.format(DateTime.now()));
    int sec = seconds;
    int totalHour = 0;
    if(sec >= 3600) {
      totalHour = seconds ~/ 3600;
      sec = sec - (totalHour * 3600);
    }
    int totalMenit = 0;
    if(sec >= 60) {
      totalMenit = sec ~/ 60;
      sec = sec - (totalMenit * 60);
    }
    if(totalHour == 0) {
      if(totalMenit == 0) {
        avgTimeDaily = '${sec}s';
      } else {
        avgTimeDaily = '${totalMenit}m ${sec}s';
      }
    } else {
      avgTimeDaily = '${totalHour}h ${totalMenit}m';
    }
    // setState(() {});
  }

  void setBindingData() async {
    prefs = await SharedPreferences.getInstance();
    var outputFormat = DateFormat('HH.mm');
    var outputDate = outputFormat.format(DateTime.now());
    dateToday = outputDate;

    calculateDayliScreen();
    usageDatas = await getUsageStatistik();
    usageDataBar = usageDatas;
    usageDatas = usageDataBar ~/ 3600;
    int secs = usageDataBar;
    if(secs > 0) {
      int tmpAvg = secs ~/ countUsage;
      int totalHour = 0;
      if(tmpAvg >= 3600) {
        totalHour = tmpAvg ~/ 3600;
        tmpAvg = tmpAvg - (totalHour * 3600);
      }
      int totalMenit = 0;
      if(tmpAvg >= 60) {
        totalMenit = tmpAvg ~/ 60;
        tmpAvg = tmpAvg - (totalMenit * 60);
      }
      if(totalHour == 0) {
        if(totalMenit == 0) {
          avgTime = '${tmpAvg}s';
        } else {
          avgTime = '${totalMenit}m ${tmpAvg}s';
        }
      } else {
        avgTime = '${totalHour}h ${totalMenit}m';
      }
    } else {
      avgTime = '0s';
    }

    await prefs!.setString("averageTime${widget.email}", avgTime);

    int sec = secs;
    int totalHour = 0;
    if(sec >= 3600) {
      totalHour = secs ~/ 3600;
      sec = sec - (totalHour * 3600);
    }
    int totalMenit = 0;
    if(sec >= 60) {
      totalMenit = sec ~/ 60;
      sec = sec - (totalMenit * 60);
    }
    if(totalHour == 0) {
      if(totalMenit == 0) {
        totalScreenTime = '${sec}s';
      } else {
        totalScreenTime = '${totalMenit}m ${sec}s';
      }
    } else {
      totalScreenTime = '${totalHour}h ${totalMenit}m';
    }
    onGetUsageDataWeekly();
    onLoadBar();
    // setState(() {});
  }

  @override
  void initState() {
    super.initState();
    seriesList = _createRandomData();
    setBindingData();
  }

  barChart() {
    return charts.BarChart(
      _createRandomData(),
      animate: true,
      vertical: true,
    );
  }

  barChartDaily() {
    // calculateDayliScreen();
    var outputFormat = DateFormat('EEEE');
    String dayName = setDayName(outputFormat.format(DateTime.now()));
    if(dayName == "Senin") {
      dtxDaily = [dtx[0],0,0,0,0,0,0];
    } else if (dayName == "Selasa") {
      dtxDaily = [0,dtx[1],0,0,0,0,0];
    } else if (dayName == "Rabu") {
      dtxDaily = [0,0,dtx[2],0,0,0,0];
    } else if (dayName == "Kamis") {
      dtxDaily = [0,0,0,dtx[3],0,0,0];
    } else if (dayName == "Jumat") {
      dtxDaily = [0,0,0,0,dtx[4],0,0];
    } else if (dayName == "Sabtu") {
      dtxDaily = [0,0,0,0,0,dtx[5],0];
    } else {
      dtxDaily = [0,0,0,0,0,0,dtx[6]];
    }
    return charts.BarChart(
      _createRandomDataDaily(),
      animate: true,
      vertical: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detil Waktu Layar', style: TextStyle(color: Colors.darkGrey)),
        backgroundColor: Colors.whiteLight,
        iconTheme: IconThemeData(color: Colors.darkGrey),
      ),
      backgroundColor: Colors.white,
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
                        margin: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0, bottom: 10.0),
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              child: AnimatedContainer(
                                margin: EdgeInsets.only(left: 2.0),
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.443,
                                decoration: BoxDecoration(
                                    color: activeColor,
                                    borderRadius: BorderRadius.circular(10.0)
                                ),
                                duration: const Duration(seconds: 0),
                                curve: Curves.easeInOutCirc,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Mingguan',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              onTap: () => {
                                setState(() {
                                  activeColor = Colors.grey[400];
                                  inactiveColor = Colors.grey[700];
                                  types = 'week';
                                })
                              },
                            ),
                            GestureDetector(
                              child: AnimatedContainer(
                                margin: EdgeInsets.only(right: 2.0),
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.443,
                                decoration: BoxDecoration(
                                    color: inactiveColor,
                                    borderRadius: BorderRadius.circular(10.0)
                                ),
                                duration: const Duration(seconds: 0),
                                curve: Curves.easeInOutCirc,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Harian',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              onTap: () => {
                                setState(() {
                                  inactiveColor = Colors.grey[400];
                                  activeColor = Colors.grey[700];
                                  types = 'day';
                                })
                              },
                            ),
                          ],
                        ),
                      ),
                      onShowLastData(types),
                      onBodyPage(types),
                      Container(
                        margin: EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0, bottom: 5.0),
                        child: Text('Update today $dateToday',
                            style: TextStyle(fontSize: 14)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 5.0),
                            child: Text('MOST USED',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          /*Container(
                            margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 5.0),
                            child: Text('LIHAT KATEGORI',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent)
                              ),
                          )*/
                        ],
                      ),
                      onLoadMostUsage(types)
                    ],
                  ),
                )
              ),
            )
          ]
        )
      )
    );
  }

  Widget onShowLastData(String type) {
    if(type == 'week') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 5.0),
            child: Text(widget.name,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Container(
            margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 5.0),
            child: Text('$lineWeekStatus',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffFF018786))),
          )
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 5.0),
            child: Text(widget.name,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Container(
            margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 5.0),
            child: Text('$lineWeekStatus',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffFF018786))),
          )
        ],
      );
    }
  }

  Widget onLoadMostUsage(String type) {
    if (type == 'week') {
      return Container(
        height: 400,
        margin: EdgeInsets.only(bottom: 10.0),
        width: MediaQuery
            .of(context)
            .size
            .width,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 3.0,
            ),
          ],
        ),
        child: onMostWeekData(),
      );
    }
    else {
      return Container(
        height: 400,
        margin: EdgeInsets.only(bottom: 10.0),
        width: MediaQuery
            .of(context)
            .size
            .width,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 3.0,
            ),
          ],
        ),
        child: onMostDay(),
      );
    }
  }

  Widget createListView(BuildContext context, List<AppUsageInfo> snapshot) {
    List<AppUsageInfo> values = snapshot;
    if (types == 'week') {
      if (values.length >= _infos.length) {
        return new ListView.builder(
          itemCount: values.length,
          itemBuilder: (BuildContext context, int index) {
            AppUsageInfo app = values[index];
            Application? tmpApp = getIconAppsFromList(app.packageName);
            var dt = app.usage.toString().split(".")[0];
            var dataUsage = dt.split(":");
            int jam = 0;
            int menit = 0;
            int detik = 0;
            jam = int.parse(dataUsage[0]);
            menit = int.parse(dataUsage[1]);
            detik = int.parse(dataUsage[2]);
            String usageData = "0s";
            if (jam == 0) {
              if (menit == 0) {
                usageData = "${detik.toString()}s";
              } else {
                usageData = "${menit.toString()}m ${detik.toString()}s";
              }
            } else {
              usageData = "${jam.toString()}h ${menit.toString()}m";
            }

            return (index >= values.length) ?
            Container(
              color: Colors.greenAccent,
              child: FlatButton(
                child: Text("Load More"),
                onPressed: () {},
              ),
            )
                :
            Column(
              children: <Widget>[
                ListTile(
                  leading: tmpApp is ApplicationWithIcon
                      ? CircleAvatar(
                    backgroundImage: MemoryImage(tmpApp.icon),
                    backgroundColor: Colors.white,
                  )
                      : Icon(
                    Icons.android_outlined,
                    color: Colors.green,
                  ),
                  title: Text('${tmpApp?.appName ?? app.appName}'),
                  // title: Text('${app.appName}'),
                  subtitle: Text(usageData),
                ),
                const Divider(
                  height: 1.0,
                )
              ],
            );
          },
        );
      }
      else {
        return new ListView.builder(
          itemCount: values.length + 1,
          itemBuilder: (BuildContext context, int index) {
            AppUsageInfo app = values[0];
            Application? tmpApp;
            String usageData = "0s";
            if (index == values.length) {

            } else {
              app = values[index];
              tmpApp = getIconAppsFromList(app.packageName);
              var dt = app.usage.toString().split(".")[0];
              var dataUsage = dt.split(":");
              int jam = 0;
              int menit = 0;
              int detik = 0;
              jam = int.parse(dataUsage[0]);
              menit = int.parse(dataUsage[1]);
              detik = int.parse(dataUsage[2]);
              if (jam == 0) {
                if (menit == 0) {
                  usageData = "${detik.toString()}s";
                } else {
                  usageData = "${menit.toString()}m ${detik.toString()}s";
                }
              } else {
                usageData = "${jam.toString()}h ${menit.toString()}m";
              }
            }

            return (index == values.length) ?
            GestureDetector(
              child: Container(
                margin: EdgeInsets.all(20.0),
                child: Text(
                  'Show More',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              onTap: () =>
              {
                showMoredata(types)
              },
            )
                :
            Column(
              children: <Widget>[
                ListTile(
                  leading: tmpApp is ApplicationWithIcon
                      ? CircleAvatar(
                    backgroundImage: MemoryImage(tmpApp.icon),
                    backgroundColor: Colors.white,
                  )
                      : Icon(
                    Icons.android_outlined,
                    color: Colors.green,
                  ),
                  // onTap: () => onAppClicked(context, app),
                  // title: Text('${app.appName} (${app.packageName})'),
                  title: Text('${tmpApp?.appName ?? app.appName}'),
                  subtitle: Text(usageData),
                ),
                const Divider(
                  height: 1.0,
                )
              ],
            );
          },
        );
      }
    }
    else {
      if (values.length >= _infosDays.length) {
        return new ListView.builder(
          itemCount: values.length,
          itemBuilder: (BuildContext context, int index) {
            AppUsageInfo app = values[index];
            Application? tmpApp = getIconAppsFromList(app.packageName);
            var dt = app.usage.toString().split(".")[0];
            var dataUsage = dt.split(":");
            int jam = 0;
            int menit = 0;
            int detik = 0;
            jam = int.parse(dataUsage[0]);
            menit = int.parse(dataUsage[1]);
            detik = int.parse(dataUsage[2]);
            String usageData = "0s";
            if (jam == 0) {
              if (menit == 0) {
                usageData = "${detik.toString()}s";
              } else {
                usageData = "${menit.toString()}m ${detik.toString()}s";
              }
            } else {
              usageData = "${jam.toString()}h ${menit.toString()}m";
            }

            return (index >= values.length) ?
            Container(
              color: Colors.greenAccent,
              child: FlatButton(
                child: Text("Load More"),
                onPressed: () {},
              ),
            )
                :
            Column(
              children: <Widget>[
                ListTile(
                  leading: tmpApp is ApplicationWithIcon
                      ? CircleAvatar(
                    backgroundImage: MemoryImage(tmpApp.icon),
                    backgroundColor: Colors.white,
                  )
                      : Icon(
                    Icons.android_outlined,
                    color: Colors.green,
                  ),
                  title: Text('${tmpApp?.appName ?? app.appName}'),
                  // title: Text('${app.appName}'),
                  subtitle: Text(usageData),
                ),
                const Divider(
                  height: 1.0,
                )
              ],
            );
          },
        );
      }
      else {
        return new ListView.builder(
          itemCount: values.length + 1,
          itemBuilder: (BuildContext context, int index) {
            AppUsageInfo app = values[0];
            Application? tmpApp;
            String usageData = "0s";
            if (index == values.length) {

            } else {
              app = values[index];
              tmpApp = getIconAppsFromList(app.packageName);
              var dt = app.usage.toString().split(".")[0];
              var dataUsage = dt.split(":");
              int jam = 0;
              int menit = 0;
              int detik = 0;
              jam = int.parse(dataUsage[0]);
              menit = int.parse(dataUsage[1]);
              detik = int.parse(dataUsage[2]);
              if (jam == 0) {
                if (menit == 0) {
                  usageData = "${detik.toString()}s";
                } else {
                  usageData = "${menit.toString()}m ${detik.toString()}s";
                }
              } else {
                usageData = "${jam.toString()}h ${menit.toString()}m";
              }
            }

            return (index == values.length) ?
            GestureDetector(
              child: Container(
                margin: EdgeInsets.all(20.0),
                child: Text(
                  'Show More',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              onTap: () =>
              {
                showMoredata(types)
              },
            )
                :
            Column(
              children: <Widget>[
                ListTile(
                  leading: tmpApp is ApplicationWithIcon
                      ? CircleAvatar(
                    backgroundImage: MemoryImage(tmpApp.icon),
                    backgroundColor: Colors.white,
                  )
                      : Icon(
                    Icons.android_outlined,
                    color: Colors.green,
                  ),
                  // onTap: () => onAppClicked(context, app),
                  // title: Text('${app.appName} (${app.packageName})'),
                  title: Text('${tmpApp?.appName ?? app.appName}'),
                  subtitle: Text(usageData),
                ),
                const Divider(
                  height: 1.0,
                )
              ],
            );
          },
        );
      }
    }
  }
  Widget createListViewTemp(BuildContext context, List<dynamic> snapshot) {
    List<dynamic> values = snapshot;
    if (types == 'week') {
      if (values.length >= _infos.length) {
        return new ListView.builder(
          itemCount: values.length,
          itemBuilder: (BuildContext context, int index) {
            var app = values[index];
            Application? tmpApp = getIconAppsFromList(app['packageId']);
            var secs = app['duration'];
            int jam = 0;
            if(secs >= 3600) {
              jam = secs ~/ 3600;
              secs = secs - (jam * 3600);
            }
            int menit = 0;
            if(secs >= 60) {
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

            if(app['icon'] == '' || app['icon'] == null) {
              if(app['duration'] > 480) {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.android_outlined,
                        color: Colors.green,
                      ),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: (app['duration'] / values[0]['duration']) * 200,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              } else {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.android_outlined,
                        color: Colors.green,
                      ),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              }
            }
            else {
              if(app['duration'] > 480) {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Image.network('${app['icon']}'),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: (app['duration'] / values[0]['duration']) * 200,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              } else {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Image.network('${app['icon']}'),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              }
            }
          },
        );
      }
      else {
        return new ListView.builder(
          itemCount: values.length + 1,
          itemBuilder: (BuildContext context, int index) {
            var app = values[0];
            // Application? tmpApp;
            String usageData = "0s";
            if (index == values.length) {

            }
            else {
              app = values[index];
              // tmpApp = getIconAppsFromList(app['packageId']);
              var secs = app['duration'];
              int jam = 0;
              int sec = secs;
              if(secs >= 3600) {
                jam = secs ~/ 3600;
                sec = sec - (jam * 3600);
              }
              int menit = 0;
              if(sec >= 60) {
                menit = sec ~/ 60;
                sec = sec - (menit * 60);
              }
              int secData = sec;
              if (jam == 0) {
                if (menit == 0) {
                  usageData = "${secData.toString()}s";
                } else {
                  usageData = "${menit.toString()}m ${secData.toString()}s";
                }
              } else {
                usageData = "${jam.toString()}h ${menit.toString()}m";
              }
            }

            if(app['icon'] == '' || app['icon'] == null) {
              if(app['duration'] > 480) {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.android_outlined,
                        color: Colors.green,
                      ),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: (app['duration'] / values[0]['duration']) * 200,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              } else {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.android_outlined,
                        color: Colors.green,
                      ),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              }
            }
            else {
              if(app['duration'] > 480) {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Image.network('${app['icon']}'),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: (app['duration'] / values[0]['duration']) * 200,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              } else {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Image.network('${app['icon']}'),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              }
            }
          },
        );
      }
    }
    else {
      if (values.length >= _ListDays.length) {
        return new ListView.builder(
          itemCount: values.length,
          itemBuilder: (BuildContext context, int index) {
            var app = values[index];
            Application? tmpApp = getIconAppsFromList(app['packageId']);
            var secs = app['duration'];
            int jam = 0;
            if(secs >= 3600) {
              jam = secs ~/ 3600;
              secs = secs - (jam * 3600);
            }
            int menit = 0;
            if(secs >= 60) {
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

            if(app['icon'] == '' || app['icon'] == null) {
              if(app['duration'] > 480) {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.android_outlined,
                        color: Colors.green,
                      ),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: (app['duration'] / values[0]['duration']) * 200,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              } else {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.android_outlined,
                        color: Colors.green,
                      ),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              }
            }
            else {
              if(app['duration'] > 480) {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Image.network('${app['icon']}'),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: (app['duration'] / values[0]['duration']) * 200,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              } else {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Image.network('${app['icon']}'),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              }
            }
          },
        );
      }
      else {
        return new ListView.builder(
          itemCount: values.length + 1,
          itemBuilder: (BuildContext context, int index) {
            var app = values[0];
            // Application? tmpApp;
            String usageData = "0s";
            if (index == values.length) {

            }
            else {
              app = values[index];
              // tmpApp = getIconAppsFromList(app['packageId']);
              var secs = app['duration'];
              int jam = 0;
              int sec = secs;
              if(secs >= 3600) {
                jam = secs ~/ 3600;
                sec = sec - (jam * 3600);
              }
              int menit = 0;
              if(sec >= 60) {
                menit = sec ~/ 60;
                sec = sec - (menit * 60);
              }
              int secData = sec;
              if (jam == 0) {
                if (menit == 0) {
                  usageData = "${secData.toString()}s";
                } else {
                  usageData = "${menit.toString()}m ${secData.toString()}s";
                }
              } else {
                usageData = "${jam.toString()}h ${menit.toString()}m";
              }
            }

            if(app['icon'] == '' || app['icon'] == null) {
              if(app['duration'] > 480) {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.android_outlined,
                        color: Colors.green,
                      ),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: (app['duration'] / values[0]['duration']) * 200,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              } else {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.android_outlined,
                        color: Colors.green,
                      ),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              }
            }
            else {
              if(app['duration'] > 480) {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Image.network('${app['icon']}'),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: (app['duration'] / values[0]['duration']) * 200,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              } else {
                return (index >= values.length) ?
                Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    child: Text("Load More"),
                    onPressed: () {},
                  ),
                )
                    :
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Image.network('${app['icon']}'),
                      title: Text('${app['appName']}'),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 5,
                            margin: EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffFF018786)
                            ),
                          ),
                          Text(usageData)
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1.0,
                    )
                  ],
                );
              }
            }
          },
        );
      }
    }
  }

  Widget onBodyPage(String type) {
    if (type == 'week') {
      return Container(
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
                    avgTime,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.only(right: 10.0),
                //   child: Row(
                //     children: [
                //       Container(
                //         margin: EdgeInsets.only(right: 10.0),
                //         child: Icon(
                //           Icons.arrow_circle_down,
                //           color: Colors.darkGrey,
                //         ),
                //       ),
                //       Text(
                //         '30% from last week',
                //         style: TextStyle(fontSize: 16),
                //       )
                //     ],
                //   ),
                // )
              ],
            ),
            onLoadBar(),
            /*Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0),
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 5.0),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 6.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Entertainment',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 2.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              '1h 21m'
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 5.0),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 6.0),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              'Travel',
                              style: TextStyle(color: Colors.lightBlueAccent),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 2.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                                '40m'
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 5.0),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 6.0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              'Social',
                              style: TextStyle(color: Colors.orangeAccent),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 2.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                                '40m'
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),*/
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 0.2, color: Colors.grey)),
            ),
            GestureDetector(
              child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Waktu Layar',
                        style: TextStyle(fontSize: 16),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(
                          totalScreenTime,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  )),
              onTap: () => {
                // Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                //     DetailChildActivityPage()))
              },
            )
          ],
        ),
      );
    }
    else {
      return Container(
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
              child: Text(
                'Hari ini',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10.0),
                  child: Text(
                    '$avgTimeDaily',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              height: 200,
              child: barChartDaily(),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 0.2, color: Colors.grey)),
            ),
            // GestureDetector(
            //   child: Container(
            //       margin: EdgeInsets.all(10.0),
            //       child: Row(
            //         mainAxisAlignment:
            //         MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text(
            //             'Lihat Semua Aktifitas',
            //             style: TextStyle(fontSize: 16),
            //           ),
            //           Icon(
            //             Icons.keyboard_arrow_right,
            //             color: Colors.darkGrey,
            //           )
            //         ],
            //       )),
            //   onTap: () => {
            //     // Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
            //     //     DetailChildActivityPage()))
            //   },
            // )
          ],
        ),
      );
    }
  }

  Widget onLoadBar() {
    return Container(
      margin: EdgeInsets.all(10.0),
      height: 200,
      child: barChart(),
    );
  }

  Widget onMostWeekDataTemp() {
    return FutureBuilder<List<AppUsageInfo>>(
      future: getUsageStats(),
      builder: (BuildContext context,
          AsyncSnapshot<List<AppUsageInfo>> data) {
        if (data.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        else {
          _infos = data.data!;
          if (items.length >= (present + perPage)) {
            return createListView(context, items);
          } else {
            // int tmp = _infos.length - (present + perPage);
            int tmp = _infos.length - items.length;
            int limit = 0;
            if (items.length == 0 && _infos.length > perPage) {
              limit = present + perPage;
            } else if (items.length == 0) {
              limit = items.length + _infos.length;
            } else if (tmp < perPage) {
              limit = items.length + tmp;
            } else {
              limit = items.length + perPage;
            }
            for (int i = items.length; i <
                limit; i++) {
              items.add(_infos[i]);
            }
            return createListView(context, items);
          }
          // for (int i = present; i < (present + perPage); i++) {
          //   items.add(apps[i]);
          // }
          // present = present + perPage;

          /*return ListView.builder(
                                  // itemCount: (present <= apps.length) ? items.length + 1 : items.length,
                                  itemCount: apps.length,
                                  itemBuilder: (BuildContext context, int position) {
                                    Application app = apps[position];

                                    return Column(
                                      children: <Widget>[
                                        ListTile(
                                          leading: app is ApplicationWithIcon
                                              ? CircleAvatar(
                                            backgroundImage: MemoryImage(app.icon),
                                            backgroundColor: Colors.white,
                                          )
                                              : null,
                                          // onTap: () => onAppClicked(context, app),
                                          // title: Text('${app.appName} (${app.packageName})'),
                                          title: Text('${app.appName}'),
                                        ),
                                        const Divider(
                                          height: 1.0,
                                        )
                                      ],
                                    );
                                    */
          /*return (position == items.length ) ?
                                    Container(
                                      color: Colors.greenAccent,
                                      child: FlatButton(
                                        child: Text("Load More"),
                                        onPressed: () {},
                                      ),
                                    )
                                        :
                                    ListTile(
                                      title: Text('${items[position]}'),
                                    );*/
          /*
                                  },
                              );*/
        }
      },
    );
  }
  Widget onMostWeekData() {
    return FutureBuilder<List<dynamic>>(
      future: getDataUsageStatistik(),
      builder: (BuildContext context,
          AsyncSnapshot<List<dynamic>> data) {
        if (data.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        else {
          _infos = data.data!;
          if(_infos.length == 0) {
            return Center(
              child: Text(
                'Tidak ada data.',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            if (itemsTmp.length >= (present + perPage)) {
              return createListViewTemp(context, itemsTmp);
            }
            else {
              // int tmp = _infos.length - (present + perPage);
              int tmp = _infos.length - itemsTmp.length;
              int limit = 0;
              if (itemsTmp.length == 0 && _infos.length > perPage) {
                limit = present + perPage;
              } else if (itemsTmp.length == 0) {
                limit = itemsTmp.length + _infos.length;
              } else if (tmp < perPage) {
                limit = itemsTmp.length + tmp;
              } else {
                limit = itemsTmp.length + perPage;
              }
              for (int i = itemsTmp.length; i <
                  limit; i++) {
                itemsTmp.add(_infos[i]);
              }
              return createListViewTemp(context, itemsTmp);
            }
          }
        }
      },
    );
  }

  Widget onMostDayTemp() {
    return FutureBuilder<List<AppUsageInfo>>(
      future: getUsageStatsDailyTemp(),
      builder: (BuildContext context,
          AsyncSnapshot<List<AppUsageInfo>> data) {
        if (data.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        else {
          _infosDays = data.data!;
          if (itemsDays.length >= (present + perPage)) {
            return createListView(context, itemsDays);
          } else {
            int tmp = _infosDays.length - itemsDays.length;
            int limit = 0;
            if (itemsDays.length == 0 && _infosDays.length > perPage) {
              limit = present + perPage;
            } else if (itemsDays.length == 0) {
              limit = itemsDays.length + _infosDays.length;
            } else if (tmp < perPage) {
              limit = itemsDays.length + tmp;
            } else {
              limit = itemsDays.length + perPage;
            }
            for (int i = itemsDays.length; i <
                limit; i++) {
              itemsDays.add(_infosDays[i]);
            }
            return createListView(context, itemsDays);
          }
        }
      },
    );
  }
  Widget onMostDay() {
    return FutureBuilder<List<dynamic>>(
      future: getUsageStatsDaily(),
      builder: (BuildContext context,
          AsyncSnapshot<List<dynamic>> data) {
        if (data.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        else {
          _ListDays = data.data!;
          if(_ListDays.length == 0) {
            return Center(
              child: Text(
                'Tidak ada data.',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            if (_ItemsDays.length >= (present + perPage)) {
              return createListViewTemp(context, _ItemsDays);
            } else {
              int tmp = _ListDays.length - _ItemsDays.length;
              int limit = 0;
              if (_ItemsDays.length == 0 && _ListDays.length > perPage) {
                limit = present + perPage;
              } else if (_ItemsDays.length == 0) {
                limit = _ItemsDays.length + _ListDays.length;
              } else if (tmp < perPage) {
                limit = _ItemsDays.length + tmp;
              } else {
                limit = _ItemsDays.length + perPage;
              }
              for (int i = _ItemsDays.length; i <
                  limit; i++) {
                _ItemsDays.add(_ListDays[i]);
              }
              return createListViewTemp(context, _ItemsDays);
            }
          }
        }
      },
    );
  }
}

/// Sample sales data type.
class Sales {
  final String year;
  final int sales;

  Sales(this.year, this.sales);
}