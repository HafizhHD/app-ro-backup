import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_app_list_with_icon.dart';
import 'package:ruangkeluarga/model/rk_child_app_icon_list.dart';
import 'package:ruangkeluarga/model/rk_child_apps.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RKConfigBlockApps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}

class RKConfigBlockAppsPage extends StatefulWidget {
  @override
  _RKConfigBlockAppsPageState createState() => _RKConfigBlockAppsPageState();

  final String email;
  final String nama;
  RKConfigBlockAppsPage({Key? key, required this.email, required this.nama})
      : super(key: key);
}

class _RKConfigBlockAppsPageState extends State<RKConfigBlockAppsPage> {
  List<bool> listSwitchValue = [];
  late SharedPreferences prefs;

  late Future<List<AppListWithIcons>> fAppList;
  List<AppListWithIcons> appList = [];
  List<AppListWithIcons> appListSearch = [];

  Future<List<AppListWithIcons>> fetchAppList() async {
    prefs = await SharedPreferences.getInstance();

    Response response = await MediaRepository().fetchAppList(widget.email);
    if (response.statusCode == 200) {
      // print('isi response fetch appList 200: ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        if (json['appdevices'].length > 0) {
          try {
            var appDevices = json['appdevices'][0];
            List<dynamic> tmpData = appDevices['appName'];
            List<dynamic> dataList = [];

            List<ApplicationInstalled> dataAppsInstalled =
                List<ApplicationInstalled>.from(tmpData
                    .map((model) => ApplicationInstalled.fromJson(model)));
            var imageUrl = "${prefs.getString(rkBaseUrlAppIcon)}";

            List<AppIconList> dataListIconApps = [];
            if (prefs.getString(rkListAppIcons) != null) {
              var respList = jsonDecode(prefs.getString(rkListAppIcons)!);
              print('respList $respList');
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
            data.sort((a, b) {
              if (b.blacklist!) {
                if (a.blacklist! == b.blacklist!) {
                  return a.appName!.compareTo(b.appName!);
                } else
                  return 1;
              } else
                return -1;
            });
            print('SetData');
            appList = data;
            appListSearch = data;
            print('id : ' + appDevices['_id']);
            setState(() {});
            return data;
          } catch (e, s) {
            print(e);
            print(s);
            return [];
          }
        } else {
          print('isi response fetch appList kosong datanya');
          return [];
        }
      } else {
        print('isi response fetch appList NOK');
        return [];
      }
    } else {
      print('isi response fetch appList error');
      return [];
    }
  }

  Future<Response> blockApp(String appID, String appCategory) async {
    Response response = await MediaRepository().addLimitUsageAndBlockApp(
        widget.email, appID, appCategory, 0, 'blacklist');
    return response;
  }

  Future<Response> unBlockApp(String appID, String appCategory) async {
    Response response = await MediaRepository()
        .addLimitUsageAndBlockApp(widget.email, appID, appCategory, 0, '');
    return response;
  }

  void setBinding() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    // TODO: implement initState
    setBinding();
    super.initState();
    fAppList = fetchAppList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cPrimaryBg,
      appBar: AppBar(
        centerTitle: true,
        title:
            Text('Blok Aplikasi / Games', style: TextStyle(color: cOrtuWhite)),
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
                appListSearch = appList
                    .where((e) =>
                        e.appName!.toLowerCase().contains(v.toLowerCase()) ==
                        true)
                    .toList();
                setState(() {});
              },
            ),
            //dropDown
            SizedBox(height: 5),
            Flexible(
              child: FutureBuilder<List<AppListWithIcons>>(
                  future: fAppList,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return wProgressIndicator();

                    final listApps = snapshot.data ?? [];
                    if (listApps.length <= 0)
                      return Center(
                          child: Text('List aplikasi kosong',
                              style: TextStyle(color: cOrtuWhite)));
                    return ListView.builder(
                        itemCount: appListSearch.length,
                        itemBuilder: (ctx, index) {
                          final app = appListSearch[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  app.appIcons != null && app.appIcons != ''
                                      ? Container(
                                          margin: EdgeInsets.all(5)
                                              .copyWith(right: 10),
                                          child: Image.network(
                                            app.appIcons ?? '',
                                            height: 50,
                                            fit: BoxFit.contain,
                                          ))
                                      : Container(
                                          margin: EdgeInsets.all(5)
                                              .copyWith(right: 10),
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    app.blacklist ?? false ? 'ON' : 'OFF',
                                    style: TextStyle(
                                        color: app.blacklist ?? false
                                            ? cOrtuBlue
                                            : cOrtuWhite),
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        showLoadingOverlay();
                                        final response;
                                        if (app.blacklist == false)
                                          response = await blockApp(
                                              app.packageId!, app.appCategory);
                                        else
                                          response = await unBlockApp(
                                              app.packageId!, app.appCategory);
                                        if (response.statusCode == 200) {
                                          fAppList = fetchAppList();
                                          setState(() {});
                                          closeOverlay();
                                          showToastSuccess(
                                              ctx: context,
                                              successText:
                                                  "Berhasil memblokir aplikasi ${app.appName}");
                                        } else {
                                          closeOverlay();
                                          showToastFailed(
                                              ctx: context,
                                              failedText:
                                                  "Gagal memblokir aplikasi ${app.appName}. Terjadi kesalahan server");
                                        }
                                      },
                                      icon: Icon(
                                        Icons.app_blocking,
                                        color: app.blacklist ?? false
                                            ? cOrtuBlue
                                            : cOrtuWhite,
                                      ))
                                ],
                              ),
                            ],
                          );
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  /*_readData(){
    dbPref.once().then((value){
      print(value.value["dataAplikasi"+widget.nama.replaceAll(' ', '')].toString());
    });
  }*/
}
