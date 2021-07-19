import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ruangkeluarga/model/rk_app_list_with_icon.dart';
import 'package:ruangkeluarga/model/rk_child_apps.dart';
import 'package:ruangkeluarga/parent/view/rk_tambah_batasan.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

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

  Future<List<dynamic>> getData() async {
    Response response = await MediaRepository().fetchLimitUsageFilter(widget.email);
    if(response.statusCode == 200) {
      print('isi response filter app usage : ${response.body}');
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
    // prefs = await SharedPreferences.getInstance();
    Response response = await MediaRepository().fetchAppList(widget.email);
    if(response.statusCode == 200) {
      print('isi response fetch appList : ${response.body}');
      var json = jsonDecode(response.body);
      if(json['resultCode'] == 'OK') {
        if(json['appdevices'].length > 0) {
          var appDevices = json['appdevices'][0];
          List<dynamic> tmpData = appDevices['appName'];
          List<dynamic> dataList = [];
          bool flag = false;
          List<ApplicationInstalled> dataIconApps = List<ApplicationInstalled>.from(
              tmpData.map((model) => ApplicationInstalled.fromJson(model)));
          /*for(int i = 0; i < dataIconApps.length; i++) {
            if(prefs.getString('rkListAppIcons') != null) {
              flag = true;
              var respList = jsonDecode(prefs.getString('rkListAppIcons')!);
              var listIcons = respList['appIcons'];
              List<AppIconList> dataListIconApps = List<AppIconList>.from(
                  listIcons.map((model) => AppIconList.fromJson(model)));
              var imageUrl = "${prefs.getString('rkBaseUrlAppIcon')}";
              bool flagX = false;
              int indeksX = 0;
              if(dataListIconApps.length > 0) {
                for(int x = 0; x < dataListIconApps.length; x++) {
                  if(dataIconApps[i].packageId == dataListIconApps[x].appId) {
                    indeksX = x;
                    flagX = true;
                    break;
                  }
                }
                if(flagX) {
                  dataList.add({
                    "appName": "${dataIconApps[i].appName}",
                    "packageId": "${dataIconApps[i].packageId}",
                    "blacklist": dataIconApps[i].blacklist,
                    "appIcons": "${imageUrl+dataListIconApps[indeksX].appIcon.toString()}"
                  });
                } else {
                  dataList.add({
                    "appName": "${dataIconApps[i].appName}",
                    "packageId": "${dataIconApps[i].packageId}",
                    "blacklist": dataIconApps[i].blacklist,
                    "appIcons": ""
                  });
                }
              }
              else {
                flag = false;
                break;
              }
            }
            else {
              break;
            }
          }*/
          if(flag) {
            List<AppListWithIcons> data = List<AppListWithIcons>.from(
                dataList.map((model) =>
                    AppListWithIcons.fromJson(model)));
            return data;
          }
          else {
            for(int i = 0; i < dataIconApps.length; i++) {
              dataList.add({
                "appName": "${dataIconApps[i].appName}",
                "packageId": "${dataIconApps[i].packageId}",
                "blacklist": dataIconApps[i].blacklist,
                "appIcons": ""
              });
            }
            List<AppListWithIcons> data = List<AppListWithIcons>.from(
                dataList.map((model) =>
                    AppListWithIcons.fromJson(model)));
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
    if(response.statusCode == 200) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.darkGrey)),
        backgroundColor: Colors.whiteLight,
        iconTheme: IconThemeData(color: Colors.darkGrey),
        actions: <Widget>[
          GestureDetector(
            child: Container(
              margin: EdgeInsets.only(right: 10.0),
              child: Align(
                child: Text(
                  'Tambah Batas',
                  style: TextStyle(color: Color(0xffFF018786), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  RKTambahBatasanPage(title: widget.title, name: widget.name, email: widget.email)));
            },
          ),
          /*IconButton(onPressed: () {}, icon: Icon(
            Icons.add,
            color: Colors.darkGrey,
          ),),*/
        ],
      ),
      backgroundColor: Colors.grey[300],
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
                        /*onShowActive(_isLimitActive),*/
                        Container(
                          margin: EdgeInsets.all(20.0),
                          child: Text(
                              'Atur batas penggunaan gadget anak anda berdasarkan kategori yang dipilih.'
                          ),
                        ),
                        onLoadDataActive(true),
                      ],
                    ),
                  ),
                )
            )
          ],
        ),
      ),
    );
  }

  Widget onShowActive(bool flag) {
    if(flag) {
      return Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        margin: EdgeInsets.only(top: 20.0),
        height: 50,
        color: Colors.white,
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
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
    if(flag) {
      return Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        child: FutureBuilder<List<dynamic>>(
            future: getData(),
            builder: (BuildContext context,
                AsyncSnapshot<List<dynamic>> data) {
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
                            limitTime =
                            "${limitHour}hrs${limitMinute}min, Setiap Hari";
                          } else {
                            limitTime = "${limitHour}hrs, Setiap Hari";
                          }
                        } else {
                          limitTime = "${limitMinute}min, Setiap Hari";
                        }
                        return GestureDetector(
                          child: Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
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
                                        style: TextStyle(
                                            color: Color(0xffFF018786),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
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
                                                                style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14),
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets.only(right: 10),
                                                              child: Align(
                                                                alignment: Alignment.centerLeft,
                                                                child: Text(
                                                                  '$limitTime',
                                                                  style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 14),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.all(10.0),
                                              width: MediaQuery.of(context).size.width,
                                              child: Text(
                                                'Batas penggunaan gadget akan di aktifkan ke semua device yang terhubung kedalam email ini'
                                              ),
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
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14),
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
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14),
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
                                      )
                                  );
                                }
                            );
                          },
                        );
                      }
                  );
                } else {
                  return Container();
                }
              }
            }
        ),
      );
    } else {
      return Container();
    }
  }

}