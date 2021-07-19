import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ruangkeluarga/model/rk_child_contact.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

class ConfigRKContact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}

class ConfigRKContactPage extends StatefulWidget {
  // List<charts.Series> seriesList;
  @override
  _ConfigRKContactPageState createState() => _ConfigRKContactPageState();
  final String title;
  final String name;
  final String email;

  ConfigRKContactPage({Key? key, required this.title, required this.name, required this.email}) : super(key: key);
}

class _ConfigRKContactPageState extends State<ConfigRKContactPage> {
  late List<Contact> contactList;
  List<bool> listSwitchValue = [];
  Future<List<Contact>> fetchContact() async {
    Response response = await MediaRepository().fetchContact(widget.email);
    if(response.statusCode == 200) {
      print('isi response fetch contact : ${response.body}');
      var json = jsonDecode(response.body);
      if(json['resultCode'] == 'OK') {
        if(json['contacts'].length > 0) {
          var contacts = json['contacts'][0];
          List<Contact> data = List<Contact>.from(
              contacts['contacts'].map((model) => Contact.fromJson(model)));
          List<Contact> fixDt = [];
          for(int i = 0; i < data.length; i++) {
            if(data[i].name == '' || data[i].phone == null || data[i].phone!.length <= 0) {} else {
              fixDt.add(data[i]);
            }
          }
          return data;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } else {
      print('isi response fetch contact : ${response.statusCode}');
      return [];
    }
  }

  void onBlacklistContact(String name, String phone) async {
    Response response = await MediaRepository().blackListContactAdd(widget.email, name, phone, "");
    if(response.statusCode == 200) {
      print('response blacklist contact ${response.body}');
    } else {
      print('error response ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.darkGrey)),
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
                        'Nama Kontak',
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
              child: FutureBuilder<List<Contact>>(
                future: fetchContact(),
                builder: (BuildContext context, AsyncSnapshot<List<Contact>> data) {
                  if (data.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    List<Contact> apps = data.data!;
                    apps.sort((a,b) {
                      var aName = a.name;
                      var bName = b.name;
                      return aName!.compareTo(bName!);
                    });
                    for (int i = 0; i < apps.length; i++) {
                      Contact dt = apps[i];
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
                              Contact app = apps[position];
                              var phones = "";
                              if(app.phone != null && app.phone!.length > 0) {
                                phones = app.phone![0];
                              }

                              if(phones == "") {
                                return Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(
                                        Icons.android_outlined,
                                        color: Colors.green,
                                      ),
                                      title: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${app.name}', style: TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.bold
                                          )),
                                        ],
                                      ),
                                      // title: Text('${app.name}'),
                                      trailing: CupertinoSwitch(
                                        value: listSwitchValue[position],
                                        onChanged: (bool value) {
                                          onBlacklistContact(app.name.toString(), app.phone![0].toString());
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
                              else {
                                return Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(
                                        Icons.android_outlined,
                                        color: Colors.green,
                                      ),
                                      title: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${app.name}', style: TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text('$phones', style: TextStyle(
                                              fontSize: 12
                                          ))
                                        ],
                                      ),
                                      // title: Text('${app.name}'),
                                      trailing: CupertinoSwitch(
                                        value: listSwitchValue[position],
                                        onChanged: (bool value) {
                                          onBlacklistContact(app.name.toString(), app.phone![0].toString());
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