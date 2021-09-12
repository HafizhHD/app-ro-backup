import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_child_contact.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

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
  late List<Contact> contactList;
  late List<Contact> searchContactList;
  List<bool> listSwitchValue = [];

  Future<List<Contact>> fetchContact() async {
    Response response = await MediaRepository().fetchContact(widget.email);
    if (response.statusCode == 200) {
      print('isi response fetch contact : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        List tempContact = json['contacts'][0]['contacts'];
        if (tempContact.length > 0) {
          List<Contact> data = tempContact.map((model) => Contact.fromJson(model)).toList();
          data.sort((a, b) {
            var aName = a.name;
            var bName = b.name;
            return aName.compareTo(bName);
          });
          contactList = searchContactList = data;
          setState(() {});
          return data;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } else {
      print('isi failed fetch contact : ${response.statusCode}');
      return [];
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fContactList = fetchContact();
  }

  Future onBlacklistContact(String name, String phone) async {
    Response response = await MediaRepository().blackListContactAdd(widget.email, name, phone, "");
    return response;
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
                searchContactList = contactList.where((e) => e.name.toLowerCase().contains(v.toLowerCase()) == true).toList();
                setState(() {});
              },
            ),
            //dropDown
            Flexible(
              child: FutureBuilder(
                  future: fContactList,
                  builder: (context, AsyncSnapshot<List<Contact>> snapshot) {
                    if (!snapshot.hasData) return wProgressIndicator();
                    if ((snapshot.data ?? []).length <= 0) return Center(child: Text('Data kontak kosong', style: TextStyle(color: cOrtuWhite)));

                    return ListView.builder(
                        itemCount: searchContactList.length,
                        itemBuilder: (ctx, index) {
                          final dataContact = searchContactList[index];
                          return Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(dataContact.name, style: TextStyle(color: cOrtuWhite, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 10),
                                      Text(dataContact.phone, style: TextStyle(color: cOrtuWhite)),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // IconButton(
                                    //   color: cOrtuWhite,
                                    //   icon: Icon(Icons.notifications_active_outlined),
                                    //   onPressed: () {
                                    //     setState(() {});
                                    //   },
                                    // ),
                                    Text(dataContact.blacklist ? 'Terblokir' : ''),
                                    IconButton(
                                      color: cOrtuWhite,
                                      icon: Icon(
                                        dataContact.blacklist ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                                        color: dataContact.blacklist ? cOrtuBlue : cOrtuWhite,
                                      ),
                                      onPressed: () async {
                                        showLoadingOverlay();
                                        final response = await onBlacklistContact(dataContact.name, dataContact.phone);
                                        if (response.statusCode == 200) {
                                          await fetchContact();
                                          showSnackbar('Berhasil memblokir kontak ${dataContact.name}');
                                        } else {
                                          showSnackbar('Gagal memblokir kontak ${dataContact.name}. Silahkan coba lagi.');
                                        }
                                        closeOverlay();
                                      },
                                    ),
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
}
