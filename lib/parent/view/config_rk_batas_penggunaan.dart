import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ruangkeluarga/global/global.dart';
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
    mapUsageDataApp.clear();
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
          List<ApplicationInstalled> dataAppsInstalled =
              List<ApplicationInstalled>.from(tmpData.map((model) => ApplicationInstalled.fromJson(model)));
          var imageUrl = "${prefs.getString(rkBaseUrlAppIcon)}";

          List<AppIconList> dataListIconApps = [];
          if (prefs.getString(rkListAppIcons) != null) {
            var respList = jsonDecode(prefs.getString(rkListAppIcons)!);
            var listIcons = respList['appIcons'];
            dataListIconApps = List<AppIconList>.from(listIcons.map((model) => AppIconList.fromJson(model)));
          }

          for (int i = 0; i < dataAppsInstalled.length; i++) {
            final appIcon = dataListIconApps.where((e) => e.appId == dataAppsInstalled[i].packageId).toList();
            dataList.add({
              "appName": "${dataAppsInstalled[i].appName}",
              "packageId": "${dataAppsInstalled[i].packageId}",
              "blacklist": dataAppsInstalled[i].blacklist,
              "appCategory": dataAppsInstalled[i].appCategory,
              "limit": (dataAppsInstalled[i].limit != null)?dataAppsInstalled[i].limit.toString():'0',
              "appIcons": appIcon.length > 0 ? "${imageUrl + appIcon.first.appIcon.toString()}" : '',
            });
          }
          List<AppListWithIcons> data = List<AppListWithIcons>.from(dataList.map((model) => AppListWithIcons.fromJson(model)));
          data.sort((a, b) => a.appName!.compareTo(b.appName!));
          print('SetData');
          appList = data;
          appListSearch = data;
          _createDataToDb(data, appDevices['_id']);
          setState(() {});

          return data;
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
    return await MediaRepository().addLimitUsageAndBlockApp(widget.email, appId, category, limit, limit > 0 ? 'Aktif' : '');
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
                          if (timeLimit >= 60) {
                            limitHour = timeLimit ~/ 60;
                          }
                          int limitMinute = timeLimit % 60;
                          if (limitHour > 0) {
                            if (limitMinute > 0) {
                              limitTime = "${limitHour}hrs ${limitMinute}min\nSetiap Hari";
                            } else {
                              limitTime = "${limitHour}hrs\nSetiap Hari";
                            }
                          } else {
                            limitTime = "${limitMinute}min\nSetiap Hari";
                          }

                          return Container(
                            padding: EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Row(
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
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (timeLimit > 0)
                                        Flexible(
                                          child: Text(
                                            limitTime,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(color: cOrtuBlue),
                                          ),
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
                                    final response = await addAppUsageLimit(app.appCategory, app.packageId ?? '', 0);
                                    if (response.statusCode == 200) {
                                      final body = jsonDecode(response.body);
                                      if (body['resultCode'] == "OK") {
                                        flistUsage = getData();
                                        fListApps = fetchAppList();
                                        closeOverlay();
                                        showToastSuccess(ctx: context, successText: 'Berhasil Reset Batas Penggunaan!');
                                      } else {
                                        closeOverlay();
                                        showToastFailed(ctx: context, failedText: 'Gagal Reset Batas Penggunaan!');
                                      }
                                    } else {
                                      closeOverlay();
                                      showToastFailed(ctx: context, failedText: 'Gagal Reset Batas Penggunaan!');
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
                              final body = jsonDecode(response.body);
                              if (body['resultCode'] == "OK") {
                                flistUsage = getData();
                                fListApps = fetchAppList();
                                closeOverlay();
                                showToastSuccess(ctx: context, successText: 'Berhasil Ubah Batas Penggunaan!');
                              } else {
                                closeOverlay();
                                showToastFailed(ctx: context, failedText: 'Gagal Ubah Batas Penggunaan!');
                              }
                            } else {
                              closeOverlay();
                              showToastFailed(ctx: context, failedText: 'Gagal Ubah Batas Penggunaan!');
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

  _createDataToDb(List<AppListWithIcons> appListSearch, String idUsageChild){
    DatabaseReference dbPref = FirebaseDatabase.instance.reference();
    List<Map<String, dynamic>> data = [];
    if(appListSearch.length>0){
      for(var i=0; i<appListSearch.length; i++){
        Map<String, dynamic> detail = new Map();
        detail['packageId'] = appListSearch[i].packageId.toString();
        detail['blacklist'] = appListSearch[i].blacklist.toString();
        detail['appCategory'] = appListSearch[i].appCategory.toString();
        detail['appName'] = appListSearch[i].appName.toString();
        detail['limit'] = (appListSearch[i].limit != null)?appListSearch[i].limit.toString():'0';
        data.add(detail);
      }
    }
    dbPref.child("dataAplikasi"+idUsageChild).set(
        data);
  }
}
