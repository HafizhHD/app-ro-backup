import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/global/global_snackbar.dart';
import 'package:ruangkeluarga/model/rk_app_list_with_icon.dart';
import 'package:ruangkeluarga/model/rk_child_app_icon_list.dart';
import 'package:ruangkeluarga/model/rk_child_apps.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RKConfigBatasPenggunaan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}

class RKConfigBatasPenggunaanPage extends StatefulWidget {
  // List<charts.Series> seriesList;
  @override
  _RKConfigBatasPenggunaanPageState createState() => _RKConfigBatasPenggunaanPageState();
  final String title;
  final String name;
  final String email;

  RKConfigBatasPenggunaanPage({Key? key, required this.title, required this.name, required this.email}) : super(key: key);
}

class _RKConfigBatasPenggunaanPageState extends State<RKConfigBatasPenggunaanPage> {
  bool checkSocial = false;
  bool checkGames = false;
  bool checkProductivity = false;
  bool checkOther = false;

  late SharedPreferences prefs;
  late Future<List<AppUsageData>> flistUsage;
  late Future<List<AppListWithIcons>> fListApps;
  Map<String, int> mapUsageDataApp = {};
  Map<String, int> mapUsageDataCategory = {};
  List<AppListWithIcons> appList = [];
  List<AppListWithIcons> appListSearch = [];

  Future<List<AppUsageData>> getData() async {
    Response response = await MediaRepository().fetchLimitUsageFilter(widget.email);
    print('isi response filter app usage : ${response.body}');
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        List usageData = json['appUsageLimit'] as List;
        final appUsageLimit = usageData.map((e) => AppUsageData.fromJson(e)).toList();
        appUsageLimit.forEach((e) {
          if (e.appId != null && e.appId != '')
            mapUsageDataApp[e.appId] = e.limit;
          else if (e.appCategory != null && e.appCategory != '') mapUsageDataCategory[e.appCategory] = e.limit;
        });
        setState(() {});
        return appUsageLimit;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<AppListWithIcons>> fetchAppList() async {
    prefs = await SharedPreferences.getInstance();
    Response response = await MediaRepository().fetchAppList(widget.email);
    if (response.statusCode == 200) {
      print('isi response fetch appList : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        if (json['appdevices'].length > 0) {
          var appDevices = json['appdevices'][0];
          List<dynamic> tmpData = appDevices['appName'];
          List<dynamic> dataList = [];
          bool flag = false;
          List<ApplicationInstalled> dataIconApps = List<ApplicationInstalled>.from(tmpData.map((model) => ApplicationInstalled.fromJson(model)));
          for (int i = 0; i < dataIconApps.length; i++) {
            if (prefs.getString('rkListAppIcons') != null) {
              flag = true;
              var respList = jsonDecode(prefs.getString('rkListAppIcons')!);
              var listIcons = respList['appIcons'];
              List<AppIconList> dataListIconApps = List<AppIconList>.from(listIcons.map((model) => AppIconList.fromJson(model)));
              var imageUrl = "${prefs.getString('rkBaseUrlAppIcon')}";
              bool flagX = false;
              int indeksX = 0;
              if (dataListIconApps.length > 0) {
                for (int x = 0; x < dataListIconApps.length; x++) {
                  if (dataIconApps[i].packageId == dataListIconApps[x].appId) {
                    indeksX = x;
                    flagX = true;
                    break;
                  }
                }
                if (flagX) {
                  dataList.add({
                    "appName": "${dataIconApps[i].appName}",
                    "packageId": "${dataIconApps[i].packageId}",
                    "blacklist": dataIconApps[i].blacklist,
                    "appCategory": dataIconApps[i].appCategory,
                    "appIcons": "${imageUrl + dataListIconApps[indeksX].appIcon.toString()}"
                  });
                } else {
                  dataList.add({
                    "appName": "${dataIconApps[i].appName}",
                    "packageId": "${dataIconApps[i].packageId}",
                    "blacklist": dataIconApps[i].blacklist,
                    "appCategory": dataIconApps[i].appCategory,
                    "appIcons": ""
                  });
                }
              } else {
                flag = false;
                break;
              }
            } else {
              break;
            }
          }
          if (flag) {
            List<AppListWithIcons> data = List<AppListWithIcons>.from(dataList.map((model) => AppListWithIcons.fromJson(model)));
            data.sort((a, b) => a.appName!.compareTo(b.appName!));
            appList = data;
            appListSearch = data;
            setState(() {});

            return data;
          } else {
            for (int i = 0; i < dataIconApps.length; i++) {
              dataList.add({
                "appName": "${dataIconApps[i].appName}",
                "packageId": "${dataIconApps[i].packageId}",
                "blacklist": dataIconApps[i].blacklist,
                "appCategory": dataIconApps[i].appCategory,
                "appIcons": ""
              });
            }
            List<AppListWithIcons> data = List<AppListWithIcons>.from(dataList.map((model) => AppListWithIcons.fromJson(model)));
            data.sort((a, b) => a.appName!.compareTo(b.appName!));
            print('SetData');
            appList = data;
            appListSearch = data;
            setState(() {});

            return data;
          }
        } else {
          return [];
        }
      } else {
        return [];
      }
    } else {
      print('isi response fetch appList : ${response.statusCode}');
      return [];
    }
  }

  Future<Response> onRemoveData(String category, String appId) async {
    Response response = await MediaRepository().removeAppLimit(widget.email, category);
    // Response response = await MediaRepository().removeAppLimit(widget.email, appId);
    return response;
  }

  Future<Response> addAppUsageLimit(String category, String appId, int limit) async {
    return await MediaRepository().addLimitUsageAndBlockApp(widget.email, appId, category, limit, 'Aktif');
  }

  @override
  void initState() {
    super.initState();
    flistUsage = getData();
    fListApps = fetchAppList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cPrimaryBg,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.name, style: TextStyle(color: cOrtuWhite)),
        backgroundColor: cPrimaryBg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: cOrtuWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 15, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WSearchBar(
              fOnChanged: (v) {
                appListSearch = appList.where((e) => e.appName!.toLowerCase().contains(v.toLowerCase()) == true).toList();
                setState(() {});
              },
            ),
            //dropDown
            Flexible(
              child: FutureBuilder<List<AppListWithIcons>>(
                  future: fListApps,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return wProgressIndicator();

                    print('mapUsageData $mapUsageDataApp');
                    final listApps = snapshot.data ?? [];
                    if (listApps.length <= 0)
                      return Center(
                        child: Text('List aplikasi kosong', style: TextStyle(color: cOrtuWhite)),
                      );
                    listApps.sort((a, b) => a.appName!.compareTo(b.appName!));

                    return ListView.builder(
                        itemCount: appListSearch.length,
                        itemBuilder: (ctx, index) {
                          final app = appListSearch[index];
                          final int timeLimit = mapUsageDataApp[app.packageId] ?? 0;
                          var limitTime = "0hrs";
                          int limitHour = 0;
                          if (timeLimit > 60) {
                            limitHour = timeLimit ~/ 60;
                          }
                          int limitMinute = timeLimit % 60;
                          if (limitHour > 0) {
                            if (limitMinute > 0) {
                              limitTime = "${limitHour}hrs${limitMinute}min, Setiap Hari";
                            } else {
                              limitTime = "${limitHour}hrs, Setiap Hari";
                            }
                          } else {
                            limitTime = "${limitMinute}min, Setiap Hari";
                          }

                          return Container(
                            padding: EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    app.appIcons != null && app.appIcons != ''
                                        ? Container(
                                            margin: EdgeInsets.all(5).copyWith(right: 10),
                                            child: Image.network(
                                              app.appIcons ?? '',
                                              height: 50,
                                              fit: BoxFit.contain,
                                            ))
                                        : Container(
                                            margin: EdgeInsets.all(5).copyWith(right: 10),
                                            color: cOrtuBlue,
                                            height: 50,
                                            child: Center(
                                              child: Icon(Icons.photo),
                                            ),
                                          ),
                                    Flexible(
                                      child: Text(
                                        app.appName ?? '',
                                        style: TextStyle(color: cOrtuWhite),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (timeLimit > 0)
                                      Text(
                                        limitTime,
                                        style: TextStyle(color: cOrtuWhite),
                                      ),
                                    IconButton(
                                        onPressed: () {
                                          addUsageLimitBottomSheet(app, timeLimit);
                                        },
                                        icon: Icon(
                                          Icons.access_time,
                                          color: timeLimit > 0 ? cOrtuBlue : cOrtuWhite,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          );
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void addUsageLimitBottomSheet(AppListWithIcons app, int timeLimit) {
    int newLimit = timeLimit;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              color: cOrtuGrey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    backgroundColor: cOrtuBlue,
                    centerTitle: true,
                    title: Text('Ubah Batas Penggunaan', style: TextStyle(color: cPrimaryBg)),
                    leading: SizedBox(),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.close, color: cPrimaryBg),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                  Theme(
                    data: ThemeData.light(),
                    child: CupertinoTimerPicker(
                      initialTimerDuration: Duration(minutes: timeLimit),
                      mode: CupertinoTimerPickerMode.hm,
                      onTimerDurationChanged: (duration) {
                        newLimit = duration.inMinutes;
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2 - 10,
                        padding: EdgeInsets.all(5),
                        child: roElevatedButton(
                            onPress: newLimit > 0
                                ? () async {
                                    showLoadingOverlay();
                                    final response = await onRemoveData(app.appCategory, app.packageId ?? '');
                                    if (response.statusCode == 200) {
                                      //reLoad data
                                      closeOverlay();
                                      closeOverlay();
                                      showSnackbar('Berhasil Reset Batas Penggunaan!');
                                    } else {
                                      showSnackbar('Gagal Reset Batas Penggunaan!');
                                    }
                                  }
                                : null,
                            text: Text('Reset', style: TextStyle(color: cPrimaryBg)),
                            cColor: cOrtuOrange),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2 - 10,
                        padding: EdgeInsets.all(5),
                        child: roElevatedButton(
                          onPress: () async {
                            showLoadingOverlay();
                            final response = await addAppUsageLimit(app.appCategory, app.packageId ?? '', newLimit);
                            if (response.statusCode == 200) {
                              await getData();
                              closeOverlay();
                              closeOverlay();
                              showSnackbar('Berhasil Ubah Batas Penggunaan!');
                            } else {
                              showSnackbar('Gagal Ubah Batas Penggunaan!');
                            }
                          },
                          text: Text('Simpan', style: TextStyle(color: cPrimaryBg)),
                        ),
                      ),
                    ],
                  )
                ],
              ));
        });
  }
}
