import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_app_list_with_icon.dart';
import 'package:ruangkeluarga/model/rk_child_app_icon_list.dart';
import 'package:ruangkeluarga/model/rk_child_apps.dart';
import 'package:ruangkeluarga/parent/view/rk_tambah_batasan.dart';
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
  bool _isLimitActive = false;
  bool checkSocial = false;
  bool checkGames = false;
  bool checkProductivity = false;
  bool checkOther = false;

  late SharedPreferences prefs;
  late Future fDataLimit;
  late Future<List<AppListWithIcons>> fListApps;
  List<AppListWithIcons> appList = [];
  List<AppListWithIcons> appListSearch = [];

  Future<List<dynamic>> getData() async {
    Response response = await MediaRepository().fetchLimitUsageFilter(widget.email);
    print('isi response filter app usage : ${response.body}');
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        setState(() {
          _isLimitActive = true;
          // onShowActive(_isLimitActive);
        });
        return json['appUsageLimit'] as List;
      } else {
        print('isi response filter limit usage : ${response.body}');
        setState(() {
          _isLimitActive = false;
          // onShowActive(_isLimitActive);
        });
        return [];
      }
    } else {
      print('isi response filter limit usage : ${response.statusCode}');
      setState(() {
        _isLimitActive = false;
        // onShowActive(_isLimitActive);
      });
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
            data.sort((a, b) => a.appName!.compareTo(b.appName!));
            print('SetData');
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

  void onRemoveData(String category) async {
    Response response = await MediaRepository().removeAppLimit(widget.email, category);
    if (response.statusCode == 200) {
      print('isi response remove app usage : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
      } else {
        print('isi response filter limit usage : ${response.body}');
      }
    } else {
      print('isi response filter limit usage : ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fDataLimit = getData();
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
                                index < 1
                                    ? Text(
                                        '3h 30m',
                                        style: TextStyle(color: cOrtuWhite),
                                      )
                                    : IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.access_time,
                                          color: cOrtuWhite,
                                        )),
                              ],
                            ),
                          );
                        });
                  }),
              // child: FutureBuilder<List<Contact>>(
              //   future: fetchContact(),
              //   builder: (BuildContext context, AsyncSnapshot<List<Contact>> data) {
              //     if (data.data == null) {
              //       return const Center(child: CircularProgressIndicator());
              //     } else {
              //       List<Contact> apps = data.data!;
              //       apps.sort((a, b) {
              //         var aName = a.name;
              //         var bName = b.name;
              //         return aName!.compareTo(bName!);
              //       });
              //       for (int i = 0; i < apps.length; i++) {
              //         Contact dt = apps[i];
              //         listSwitchValue.add(dt.blacklist!);
              //       }
              //
              //       if (apps.length == 0) {
              //         return Align(
              //           child: Text(
              //             'Tidak ada data.',
              //             style: TextStyle(color: Colors.black, fontSize: 18),
              //           ),
              //         );
              //       } else {
              //         return Scrollbar(
              //           child: ListView.builder(
              //               itemBuilder: (BuildContext context, int position) {
              //                 Contact app = apps[position];
              //                 var phones = "";
              //                 if (app.phone != null && app.phone!.length > 0) {
              //                   phones = app.phone![0];
              //                 }
              //
              //                 if (phones == "") {
              //                   return Column(
              //                     children: <Widget>[
              //                       ListTile(
              //                         leading: Icon(
              //                           Icons.android_outlined,
              //                           color: Colors.green,
              //                         ),
              //                         title: Column(
              //                           mainAxisAlignment: MainAxisAlignment.start,
              //                           crossAxisAlignment: CrossAxisAlignment.start,
              //                           children: [
              //                             Text('${app.name}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              //                           ],
              //                         ),
              //                         // title: Text('${app.name}'),
              //                         trailing: CupertinoSwitch(
              //                           value: listSwitchValue[position],
              //                           onChanged: (bool value) {
              //                             onBlacklistContact(app.name.toString(), app.phone![0].toString());
              //                             setState(() {
              //                               listSwitchValue[position] = value;
              //                             });
              //                           },
              //                         ),
              //                       ),
              //                       const Divider(
              //                         height: 1.0,
              //                       )
              //                     ],
              //                   );
              //                 } else {
              //                   return Column(
              //                     children: <Widget>[
              //                       ListTile(
              //                         leading: Icon(
              //                           Icons.android_outlined,
              //                           color: Colors.green,
              //                         ),
              //                         title: Column(
              //                           mainAxisAlignment: MainAxisAlignment.start,
              //                           crossAxisAlignment: CrossAxisAlignment.start,
              //                           children: [
              //                             Text('${app.name}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              //                             SizedBox(
              //                               height: 5,
              //                             ),
              //                             Text('$phones', style: TextStyle(fontSize: 12))
              //                           ],
              //                         ),
              //                         // title: Text('${app.name}'),
              //                         trailing: CupertinoSwitch(
              //                           value: listSwitchValue[position],
              //                           onChanged: (bool value) {
              //                             onBlacklistContact(app.name.toString(), app.phone![0].toString());
              //                             setState(() {
              //                               listSwitchValue[position] = value;
              //                             });
              //                           },
              //                         ),
              //                       ),
              //                       const Divider(
              //                         height: 1.0,
              //                       )
              //                     ],
              //                   );
              //                 }
              //               },
              //               itemCount: apps.length),
              //         );
              //       }
              //     }
              //   },
              // ),
            ),
          ],
        ),
      ),
    );
  }

  Widget onShowActive(bool flag) {
    if (flag) {
      return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 20.0),
        height: 50,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                'Batas Penggunaan',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 10.0),
              child: CupertinoSwitch(
                value: _isLimitActive,
                onChanged: (value) {
                  setState(() {
                    _isLimitActive = value;
                    onShowActive(_isLimitActive);
                    onLoadDataActive(_isLimitActive);
                  });
                },
              ),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget onLoadDataActive(bool flag) {
    if (flag) {
      return Container(
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder<List<dynamic>>(
            future: getData(),
            builder: (BuildContext context, AsyncSnapshot<List<dynamic>> data) {
              if (data.data == null) {
                return Container();
              } else {
                List<dynamic> values = data.data!;
                if (values.length > 0) {
                  return new ListView.builder(
                      itemCount: values.length,
                      itemBuilder: (BuildContext context, int index) {
                        var app = values[index];
                        var limitTime = "0hrs";
                        int limitHour = 0;
                        if (app['limit'] > 60) {
                          limitHour = app['limit'] ~/ 60;
                        }
                        int limitMinute = app['limit'] % 60;
                        if (limitHour > 0) {
                          if (limitMinute > 0) {
                            limitTime = "${limitHour}hrs${limitMinute}min, Setiap Hari";
                          } else {
                            limitTime = "${limitHour}hrs, Setiap Hari";
                          }
                        } else {
                          limitTime = "${limitMinute}min, Setiap Hari";
                        }
                        return GestureDetector(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(bottom: 5.0),
                            height: 50,
                            color: Colors.white,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.only(left: 20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${app['appCategory']}',
                                        style: TextStyle(color: Color(0xffFF018786), fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '$limitTime',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                      height: 400,
                                      color: Colors.grey[300],
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(top: 20.0),
                                              width: MediaQuery.of(context).size.width,
                                              height: 50,
                                              color: Colors.grey,
                                              child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Container(
                                                    margin: EdgeInsets.only(left: 20.0),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Align(
                                                              alignment: Alignment.centerLeft,
                                                              child: Text(
                                                                'Time',
                                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets.only(right: 10),
                                                              child: Align(
                                                                alignment: Alignment.centerLeft,
                                                                child: Text(
                                                                  '$limitTime',
                                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                            Container(
                                              margin: EdgeInsets.all(10.0),
                                              width: MediaQuery.of(context).size.width,
                                              child:
                                                  Text('Batas penggunaan gadget akan di aktifkan ke semua device yang terhubung kedalam email ini'),
                                            ),
                                            Container(
                                              margin: EdgeInsets.all(10.0),
                                              width: MediaQuery.of(context).size.width,
                                              child: Text(
                                                'Kategori, Aplikasi dan Website',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: 50,
                                              color: Colors.grey,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  margin: EdgeInsets.only(left: 20.0),
                                                  child: Text(
                                                    '${app['appCategory']}',
                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              child: Container(
                                                margin: EdgeInsets.only(top: 50.0),
                                                width: MediaQuery.of(context).size.width,
                                                height: 50,
                                                color: Colors.grey,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    margin: EdgeInsets.only(left: 20.0),
                                                    child: Text(
                                                      'Hapus Batasan',
                                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                onRemoveData(app['appCategory']);
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        ),
                                      ));
                                });
                          },
                        );
                      });
                } else {
                  return Container();
                }
              }
            }),
      );
    } else {
      return Container();
    }
  }
}
