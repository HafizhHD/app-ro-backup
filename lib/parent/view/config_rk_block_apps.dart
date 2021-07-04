import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:ruangkeluarga/model/rk_child_apps.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

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

  Future<List<ApplicationInstalled>> fetchAppList() async {
    Response response = await MediaRepository().fetchAppList(widget.email);
    if(response.statusCode == 200) {
      print('isi response fetch appList : ${response.body}');
      var json = jsonDecode(response.body);
      if(json['resultCode'] == 'OK') {
        if(json['appdevices'].length > 0) {
          var appDevices = json['appdevices'][0];
          List<ApplicationInstalled> data = List<ApplicationInstalled>.from(
              appDevices['appdevices'].map((model) =>
                  ApplicationInstalled.fromJson(model)));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blok Aplikasi/Games', style: TextStyle(color: Colors.darkGrey)),
        backgroundColor: Colors.whiteLight,
        iconTheme: IconThemeData(color: Colors.darkGrey),
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
              child: FutureBuilder<List<ApplicationInstalled>>(
                future: fetchAppList(),
                builder: (BuildContext context, AsyncSnapshot<List<ApplicationInstalled>> data) {
                  if (data.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    List<ApplicationInstalled> apps = data.data!;
                    apps.sort((a,b) {
                      var aName = a.appName;
                      var bName = b.appName;
                      return aName!.compareTo(bName!);
                    });
                    for (int i = 0; i < apps.length; i++) {
                      ApplicationInstalled dt = apps[i];
                      listSwitchValue.add(dt.blacklist!);
                    }

                    if(apps.length == 0) {
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
                              ApplicationInstalled app = apps[position];
                              return Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(
                                      Icons.android_outlined,
                                      color: Colors.green,
                                    ),
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