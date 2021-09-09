import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_child_app_icon_list.dart';
import 'package:ruangkeluarga/plugin_device_app.dart';
import 'package:ruangkeluarga/utils/app_usage.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  int perPage = 7;
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
  var dtx = [0, 0, 0, 0, 0, 0, 0];
  var dty = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  var dtxDaily = [0, 0, 0, 0, 0, 0, 0];
  var dtyDaily = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];
  int countUsage = 1;

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
    } else {
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
    for (int i = 0; i < infoList.length; i++) {
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
      if (itemsApp[i].packageName == package) {
        name = itemsApp[i].appName;
      }
    }
    return name;
  }

  Application? getIconAppsFromList(String package) {
    for (int i = 0; i < itemsApp.length; i++) {
      if (itemsApp[i].packageName == package) {
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
    if (response.statusCode == 200) {
      print('isi response filter app usage : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonDataResult = json['appUsages'] as List;
        await prefs!.setString("childAppUsage", jsonEncode(jsonDataResult));
        if (jsonDataResult.length == 0) {
          await prefs!.setInt("dataMinggu${widget.email}", 0);
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
    if (response.statusCode == 200) {
      print('isi response filter app usage : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonDataResult = json['appUsages'] as List;
        if (jsonDataResult.length == 0) {
          return [];
        } else {
          tmpFilterReturn = jsonDataResult[0]['appUsages'] as List;
          List<dynamic> refData = [];
          for (int y = 1; y < jsonDataResult.length; y++) {
            List<dynamic> filterTmp = jsonDataResult[y]['appUsages'] as List;
            tmpxData = tmpFilterReturn;
            tmpFilterReturn = [];
            for (int w = 0; w < tmpxData.length; w++) {
              bool flag = false;
              for (int z = 0; z < filterTmp.length; z++) {
                if (tmpxData[w]['packageId'] == filterTmp[z]['packageId']) {
                  int durasi = int.parse(tmpxData[w]['duration'].toString()) + int.parse(filterTmp[z]['duration'].toString());
                  bool flagData = false;
                  for (int i = 0; i < tmpFilterReturn.length; i++) {
                    if (filterTmp[z]['packageId'] == tmpFilterReturn[i]['packageId']) {
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
                  if (!flagData) {
                    tmpFilterReturn.add({
                      "count": 0,
                      "appName": "${tmpxData[w]['appName']}",
                      "packageId": "${tmpxData[w]['packageId']}",
                      "duration": durasi,
                      "icon": ""
                    });
                  }
                  flag = true;
                } else {
                  bool flagData = false;
                  for (int i = 0; i < tmpFilterReturn.length; i++) {
                    if (filterTmp[z]['packageId'] == tmpFilterReturn[i]['packageId']) {
                      flagData = true;
                      break;
                    }
                  }
                  if (!flagData) {
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

              if (!flag) {
                bool flagData = false;
                for (int i = 0; i < tmpFilterReturn.length; i++) {
                  if (tmpxData[w]['packageId'] == tmpFilterReturn[i]['packageId']) {
                    flagData = true;
                    break;
                  }
                }
                if (!flagData) {
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
            return bUsage.compareTo(aUsage); //to get the order other way just switch `adate & bdate`
          });

          print('fix data $tmpFilterReturn');
          /*if(prefs!.getString(rkListAppIcons) != null) {
            var respList = jsonDecode(prefs!.getString(rkListAppIcons)!);
            var listIcons = respList['appIcons'];
            List<AppIconList> dataListIconApps = List<AppIconList>.from(
                listIcons.map((model) => AppIconList.fromJson(model)));
            var imageUrl = "${prefs!.getString(rkBaseUrlAppIcon)}";
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

    dtx = [usageFirst, usageSecond, usageThird, usageFour, usageFive, usageSix, usageLast];
    setState(() {});
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
        await prefs!.setString("childAppUsage", jsonEncode(jsonDataResult));
        if (jsonDataResult.length == 0) {
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
    if (name == 'Sunday') {
      days = 'Minggu';
    } else if (name == 'Monday') {
      days = 'Senin';
    } else if (name == 'Tuesday') {
      days = 'Selasa';
    } else if (name == 'Wednesday') {
      days = 'Rabu';
    } else if (name == 'Thursday') {
      days = 'Kamis';
    } else if (name == 'Friday') {
      days = 'Jum\'at';
    } else if (name == 'Saturday') {
      days = 'Sabtu';
    }

    return days;
  }

  void calculateDayliScreen() async {
    var dateFormat = DateFormat("yyyy-MM-dd");
    int seconds = await getDailyUsageStatistik(dateFormat.format(DateTime.now()));
    int sec = seconds;
    int totalHour = 0;
    if (sec >= 3600) {
      totalHour = seconds ~/ 3600;
      sec = sec - (totalHour * 3600);
    }
    int totalMenit = 0;
    if (sec >= 60) {
      totalMenit = sec ~/ 60;
      sec = sec - (totalMenit * 60);
    }
    if (totalHour == 0) {
      if (totalMenit == 0) {
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
    if (sec >= 3600) {
      totalHour = secs ~/ 3600;
      sec = sec - (totalHour * 3600);
    }
    int totalMenit = 0;
    if (sec >= 60) {
      totalMenit = sec ~/ 60;
      sec = sec - (totalMenit * 60);
    }
    if (totalHour == 0) {
      if (totalMenit == 0) {
        totalScreenTime = '${sec}s';
      } else {
        totalScreenTime = '${totalMenit}m ${sec}s';
      }
    } else {
      totalScreenTime = '${totalHour}h ${totalMenit}m';
    }
    onGetUsageDataWeekly();
    // setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // seriesList = _createRandomData();
    setBindingData();
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

            return (index >= values.length)
                ? Container(
                    color: Colors.greenAccent,
                    child: FlatButton(
                      child: Text("Load More"),
                      onPressed: () {},
                    ),
                  )
                : Column(
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
      } else {
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

            return (index == values.length)
                ? GestureDetector(
                    child: Container(
                      margin: EdgeInsets.all(20.0),
                      child: Text(
                        'Show More',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    onTap: () => {showMoredata(types)},
                  )
                : Column(
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
    } else {
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

            return (index >= values.length)
                ? Container(
                    color: Colors.greenAccent,
                    child: FlatButton(
                      child: Text("Load More"),
                      onPressed: () {},
                    ),
                  )
                : Column(
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
      } else {
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

            return (index == values.length)
                ? GestureDetector(
                    child: Container(
                      margin: EdgeInsets.all(20.0),
                      child: Text(
                        'Show More',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    onTap: () => {showMoredata(types)},
                  )
                : Column(
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

            if (app['icon'] == '' || app['icon'] == null) {
              return (index >= values.length)
                  ? Container(
                      color: Colors.greenAccent,
                      child: FlatButton(
                        child: Text("Load More"),
                        onPressed: () {},
                      ),
                    )
                  : Column(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(
                            Icons.android_outlined,
                            color: Colors.green,
                          ),
                          title: Text('${app['appName']}', style: TextStyle(color: cOrtuWhite)),
                          subtitle: Row(
                            children: <Widget>[
                              Container(
                                width: (app['duration'] / values[0]['duration']) * 200,
                                height: 5,
                                margin: EdgeInsets.only(right: 10.0),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
                              ),
                              Text(usageData, style: TextStyle(color: cOrtuWhite))
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1.0,
                        )
                      ],
                    );
            } else {
              return (index >= values.length)
                  ? Container(
                      color: Colors.greenAccent,
                      child: FlatButton(
                        child: Text("Load More"),
                        onPressed: () {},
                      ),
                    )
                  : Column(
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
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
          },
        );
      } else {
        return new ListView.builder(
          itemCount: values.length + 1,
          itemBuilder: (BuildContext context, int index) {
            var app = values[0];
            // Application? tmpApp;
            String usageData = "0s";
            if (index == values.length) {
            } else {
              app = values[index];
              // tmpApp = getIconAppsFromList(app['packageId']);
              var secs = app['duration'];
              int jam = 0;
              int sec = secs;
              if (secs >= 3600) {
                jam = secs ~/ 3600;
                sec = sec - (jam * 3600);
              }
              int menit = 0;
              if (sec >= 60) {
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

            if (app['icon'] == '' || app['icon'] == null) {
              if (app['duration'] > 480) {
                return (index >= values.length)
                    ? Container(
                        color: Colors.greenAccent,
                        child: FlatButton(
                          child: Text("Load More"),
                          onPressed: () {},
                        ),
                      )
                    : Column(
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
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
                return (index >= values.length)
                    ? Container(
                        color: Colors.greenAccent,
                        child: FlatButton(
                          child: Text("Load More"),
                          onPressed: () {},
                        ),
                      )
                    : Column(
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
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
            } else {
              if (app['duration'] > 480) {
                return (index >= values.length)
                    ? Container(
                        color: Colors.greenAccent,
                        child: FlatButton(
                          child: Text("Load More"),
                          onPressed: () {},
                        ),
                      )
                    : Column(
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
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
                return (index >= values.length)
                    ? Container(
                        color: Colors.greenAccent,
                        child: FlatButton(
                          child: Text("Load More"),
                          onPressed: () {},
                        ),
                      )
                    : Column(
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
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
    } else {
      if (values.length >= _ListDays.length) {
        return new ListView.builder(
          itemCount: values.length,
          itemBuilder: (BuildContext context, int index) {
            var app = values[index];
            Application? tmpApp = getIconAppsFromList(app['packageId']);
            var secs = app['duration'];
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

            if (app['icon'] == '' || app['icon'] == null) {
              if (app['duration'] > 480) {
                return (index >= values.length)
                    ? Container(
                        color: Colors.greenAccent,
                        child: FlatButton(
                          child: Text("Load More"),
                          onPressed: () {},
                        ),
                      )
                    : Column(
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
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
                return (index >= values.length)
                    ? Container(
                        color: Colors.greenAccent,
                        child: FlatButton(
                          child: Text("Load More"),
                          onPressed: () {},
                        ),
                      )
                    : Column(
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
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
            } else {
              if (app['duration'] > 480) {
                return (index >= values.length)
                    ? Container(
                        color: Colors.greenAccent,
                        child: FlatButton(
                          child: Text("Load More"),
                          onPressed: () {},
                        ),
                      )
                    : Column(
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
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
                return (index >= values.length)
                    ? Container(
                        color: Colors.greenAccent,
                        child: FlatButton(
                          child: Text("Load More"),
                          onPressed: () {},
                        ),
                      )
                    : Column(
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
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
      } else {
        return new ListView.builder(
          itemCount: values.length + 1,
          itemBuilder: (BuildContext context, int index) {
            var app = values[0];
            // Application? tmpApp;
            String usageData = "0s";
            if (index == values.length) {
            } else {
              app = values[index];
              // tmpApp = getIconAppsFromList(app['packageId']);
              var secs = app['duration'];
              int jam = 0;
              int sec = secs;
              if (secs >= 3600) {
                jam = secs ~/ 3600;
                sec = sec - (jam * 3600);
              }
              int menit = 0;
              if (sec >= 60) {
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

            if (app['icon'] == '' || app['icon'] == null) {
              if (app['duration'] > 480) {
                return (index >= values.length)
                    ? Container(
                        color: Colors.greenAccent,
                        child: FlatButton(
                          child: Text("Load More"),
                          onPressed: () {},
                        ),
                      )
                    : Column(
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
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
                return (index >= values.length)
                    ? Container(
                        color: Colors.greenAccent,
                        child: FlatButton(
                          child: Text("Load More"),
                          onPressed: () {},
                        ),
                      )
                    : Column(
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
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
            } else {
              if (app['duration'] > 480) {
                return (index >= values.length)
                    ? Container(
                        color: Colors.greenAccent,
                        child: FlatButton(
                          child: Text("Load More"),
                          onPressed: () {},
                        ),
                      )
                    : Column(
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
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
                return (index >= values.length)
                    ? Container(
                        color: Colors.greenAccent,
                        child: FlatButton(
                          child: Text("Load More"),
                          onPressed: () {},
                        ),
                      )
                    : Column(
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
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Color(0xffFF018786)),
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
              type == 'week' ? avgTime : avgTimeDaily,
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
            child: type == 'week' ? _chartWeeklyAverage() : _chartDailyAverage(),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, left: 15),
            child: Align(alignment: Alignment.centerLeft, child: Text('Update today $dateToday', style: TextStyle(fontSize: 14, color: cOrtuWhite))),
          ),
        ],
      ),
    );
  }

  Widget _chartWeeklyAverage() {
    final desktopSalesData = [
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

  Widget _chartDailyAverage() {
    final desktopSalesData = [
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
    return FutureBuilder<List<dynamic>>(
      future: getDataUsageStatistik(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> data) {
        if (data.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          _infos = data.data!;
          if (_infos.length == 0) {
            return Center(
              child: Text(
                'Tidak ada data.',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            if (itemsTmp.length >= (present + perPage)) {
              return createListViewTemp(context, itemsTmp);
            } else {
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
              for (int i = itemsTmp.length; i < limit; i++) {
                itemsTmp.add(_infos[i]);
              }
              return createListViewTemp(context, itemsTmp);
            }
          }
        }
      },
    );
  }

  Widget onMostDay() {
    return FutureBuilder<List<dynamic>>(
      future: getUsageStatsDaily(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> data) {
        if (data.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          _ListDays = data.data!;
          if (_ListDays.length == 0) {
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
              for (int i = _ItemsDays.length; i < limit; i++) {
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

class DailyAverage {
  final String day;
  final int average;

  DailyAverage(this.day, this.average);
}
