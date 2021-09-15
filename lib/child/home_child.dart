import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:ruangkeluarga/child/child_controller.dart';
import 'package:ruangkeluarga/child/sos_record_video.dart';
import 'package:ruangkeluarga/model/rk_child_blacklist_contact.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/main/parent_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomeChildPage(title: 'ruang keluarga', email: '', name: '');
  }
}

class HomeChildPage extends StatefulWidget {
  HomeChildPage({Key? key, required this.title, required this.email, required this.name}) : super(key: key);

  final String title;
  final String email;
  final String name;

  @override
  _HomeChildPageState createState() => _HomeChildPageState();
}

class _HomeChildPageState extends State<HomeChildPage> {
  late SharedPreferences prefs;
  Location location = new Location();
  List<BlackListContact> blackListData = [];

  final childController = Get.find<ChildController>();

  getFileSize(String filepath, int decimals) async {
    var file = File(filepath);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
  }

  void downloadTimeline() async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';
    try {
      myUrl = 'https://www.google.com/maps/timeline/kml?authuser=0&pb=!1m8!1m3!1i2021!2i4!3i1!2m3!1i2021!2i4!3i4';
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '/storage/emulated/0/Download/kml-timeline-01';
        file = File(filePath);
        await file.writeAsBytes(bytes);

        String kmlBase64 = base64Encode(File(file.path).readAsBytesSync());
        print('kml base 64 $kmlBase64');
      } else {
        filePath = 'Error code: ' + response.statusCode.toString();
      }
    } catch (ex) {
      filePath = 'Can not fetch url';
    }
  }

  @override
  void initState() {
    super.initState();
    childController.initData();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: screenSize.width - 20,
            constraints: BoxConstraints(maxHeight: 150),
            margin: const EdgeInsets.all(10.0), //Same as `blurRadius` i guess
            child: ListView.builder(
              padding: EdgeInsets.all(5.0),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) => Card(
                key: Key('HKBPContent#$index'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: GestureDetector(
                  child: Image.asset('assets/images/hkbpgo.png', fit: BoxFit.cover),
                  onTap: () => childController.setBottomNavIndex(1),
                ),
              ),
            ),
          ),
          Container(
              constraints: BoxConstraints(maxHeight: screenSize.height / 3, maxWidth: screenSize.width),
              child: Obx(
                () => FutureBuilder<bool>(
                    future: childController.fParentProfile.value,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!) return CardWithBottomSheet(parentData: childController.parentProfile);
                      return wProgressIndicator();
                    }),
              )),
        ],
      ),
    );
  }
}

class CardWithBottomSheet extends StatelessWidget {
  final ParentProfile parentData;
  CardWithBottomSheet({required this.parentData});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double paddingValue = 8;
    final bool hasPhoto = parentData.imgPhoto != null && parentData.imgPhoto != '';

    return Container(
      margin: EdgeInsets.all(paddingValue),
      width: screenSize.width - paddingValue * 2,
      decoration: BoxDecoration(
        color: cOrtuBlue,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Stack(
        children: [
          hasPhoto
              ? Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      parentData.imgPhoto!,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: cOrtuOrange,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Icon(
                      Icons.person,
                      size: 200,
                      color: cPrimaryBg,
                    ),
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.2,
              minChildSize: 0.2,
              maxChildSize: 0.60,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  width: screenSize.width,
                  child: NotificationListener(
                    onNotification: (OverscrollIndicatorNotification overscroll) {
                      overscroll.disallowGlow();
                      return true;
                    },
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(top: 5),
                              width: screenSize.width / 6,
                              height: 5,
                              decoration: BoxDecoration(color: cOrtuGrey, borderRadius: BorderRadius.all(Radius.circular(15))),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10.0, right: 10),
                            child: Text(
                              '${parentData.name}',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            height: 60,
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            child: Container(
                              height: 40,
                              margin: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Align(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Icon(
                                          Icons.add_ic_call,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 10.0),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            'SOS',
                                            style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SOSRecordVideoPage()));
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
