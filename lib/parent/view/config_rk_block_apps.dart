import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
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
  RKConfigBlockAppsPage({Key? key, required this.email}) : super(key: key);
}

class _RKConfigBlockAppsPageState extends State<RKConfigBlockAppsPage> {
  List<bool> listSwitchValue = [];
  late SharedPreferences prefs;

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
                    "appIcons": "${imageUrl + dataListIconApps[indeksX].appIcon.toString()}"
                  });
                } else {
                  dataList.add({
                    "appName": "${dataIconApps[i].appName}",
                    "packageId": "${dataIconApps[i].packageId}",
                    "blacklist": dataIconApps[i].blacklist,
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
            return data;
          } else {
            for (int i = 0; i < dataIconApps.length; i++) {
              dataList.add({
                "appName": "${dataIconApps[i].appName}",
                "packageId": "${dataIconApps[i].packageId}",
                "blacklist": dataIconApps[i].blacklist,
                "appIcons": ""
              });
            }
            List<AppListWithIcons> data = List<AppListWithIcons>.from(dataList.map((model) => AppListWithIcons.fromJson(model)));
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

  void setBinding() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    // TODO: implement initState
    setBinding();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blok Aplikasi/Games', style: TextStyle(color: Colors.grey.shade700)),
        backgroundColor: Colors.white70,
        iconTheme: IconThemeData(color: Colors.grey.shade700),
      ),
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              margin: EdgeInsets.only(left: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Align(
                      child: Text(
                        'Aplikasi/Game',
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20.0),
                    child: Align(
                      child: Text(
                        'Blacklist',
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height - 130,
              child: FutureBuilder<List<AppListWithIcons>>(
                future: fetchAppList(),
                builder: (BuildContext context, AsyncSnapshot<List<AppListWithIcons>> data) {
                  if (data.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    List<AppListWithIcons> apps = data.data!;
                    apps.sort((a, b) {
                      var aName = a.appName;
                      var bName = b.appName;
                      return aName!.compareTo(bName!);
                    });
                    for (int i = 0; i < apps.length; i++) {
                      AppListWithIcons dt = apps[i];
                      listSwitchValue.add(dt.blacklist!);
                    }

                    if (apps.length == 0) {
                      return Align(
                        child: Text(
                          'Tidak ada data.',
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      );
                    } else {
                      return Scrollbar(
                        child: ListView.builder(
                            itemBuilder: (BuildContext context, int position) {
                              AppListWithIcons app = apps[position];
                              if (app.appIcons == '') {
                                return Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(
                                        Icons.android,
                                        color: Colors.green,
                                      ),
                                      // leading: Image.network('${app.appIcons}'),
                                      title: Text('${app.appName}'),
                                      trailing: CupertinoSwitch(
                                        value: listSwitchValue[position],
                                        onChanged: (bool value) {
                                          setState(() {
                                            listSwitchValue[position] = value;
                                          });
                                        },
                                      ),
                                    ),
                                    const Divider(
                                      height: 1.0,
                                    )
                                  ],
                                );
                              } else {
                                return Column(
                                  children: <Widget>[
                                    ListTile(
                                      // leading: Icon(
                                      //   Icons.android,
                                      //   color: Colors.green,
                                      // ),
                                      leading: Image.network('${app.appIcons}'),
                                      title: Text('${app.appName}'),
                                      trailing: CupertinoSwitch(
                                        value: listSwitchValue[position],
                                        onChanged: (bool value) {
                                          setState(() {
                                            listSwitchValue[position] = value;
                                          });
                                        },
                                      ),
                                    ),
                                    const Divider(
                                      height: 1.0,
                                    )
                                  ],
                                );
                              }
                            },
                            itemCount: apps.length),
                      );
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
