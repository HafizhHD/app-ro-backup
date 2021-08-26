import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ruangkeluarga/global/global.dart';
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
  late Future<List<Contact>> fContactList;
  List<bool> listSwitchValue = [];

  Future<List<Contact>> fetchContact() async {
    Response response = await MediaRepository().fetchContact(widget.email);
    if (response.statusCode == 200) {
      print('isi response fetch contact : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        if (json['contacts'].length > 0) {
          var contacts = json['contacts'][0];
          List<Contact> data = List<Contact>.from(contacts['contacts'].map((model) => Contact.fromJson(model)));
          List<Contact> fixDt = [];
          for (int i = 0; i < data.length; i++) {
            if (data[i].name == '' || data[i].phone == null || data[i].phone!.length <= 0) {
            } else {
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

  @override
  void initState() {
    // TODO: implement initState
    fContactList = fetchContact();
  }

  void onBlacklistContact(String name, String phone) async {
    Response response = await MediaRepository().blackListContactAdd(widget.email, name, phone, "");
    if (response.statusCode == 200) {
      print('response blacklist contact ${response.body}');
    } else {
      print('error response ${response.statusCode}');
    }
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
              fOnChanged: (v) {},
            ),
            //dropDown
            Flexible(
              child: FutureBuilder(
                  future: fContactList,
                  builder: (context, AsyncSnapshot<List<Contact>> snapshot) {
                    if (!snapshot.hasData) return wProgressIndicator();

                    final contacts = snapshot.data ?? [];
                    if (contacts.length <= 0) return Center(child: Text('Data kontak kosong', style: TextStyle(color: cOrtuWhite)));
                    contacts.sort((a, b) {
                      var aName = a.name;
                      var bName = b.name;
                      return aName!.compareTo(bName!);
                    });
                    return ListView.builder(
                        itemCount: contacts.length,
                        itemBuilder: (ctx, index) {
                          final dataContact = contacts[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(dataContact.name ?? '', style: TextStyle(color: cOrtuWhite)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    color: cOrtuWhite,
                                    icon: Icon(Icons.notifications_active_outlined),
                                    onPressed: () {
                                      setState(() {});
                                    },
                                  ),
                                  IconButton(
                                    color: cOrtuWhite,
                                    icon: Icon(
                                      Icons.block_rounded,
                                      color: dataContact.blacklist ?? false ? cOrtuBlue : cOrtuWhite,
                                    ),
                                    onPressed: () {},
                                  ),
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
}
