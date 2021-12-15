import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:ruangkeluarga/child/child_model.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/global/global_formatter.dart';
import 'package:ruangkeluarga/main.dart';
import 'package:ruangkeluarga/model/content_aplikasi_data_usage.dart';
import 'package:ruangkeluarga/model/rk_child_app_icon_list.dart';
// import 'package:ruangkeluarga/model/rk_callLog_model.dart';
import 'package:ruangkeluarga/model/rk_child_apps.dart';
import 'package:ruangkeluarga/model/rk_child_contact.dart';
import 'package:ruangkeluarga/model/rk_schedule_model.dart';
import 'package:ruangkeluarga/parent/view/main/parent_model.dart';
import 'package:ruangkeluarga/plugin_device_app.dart';
import 'package:ruangkeluarga/utils/app_usage.dart';
import 'package:ruangkeluarga/utils/database/aplikasiDb.dart';
import 'package:ruangkeluarga/utils/database/databasehelper.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as a;

late List<CameraDescription> cameras;

class ChildController extends GetxController {
  var _bottomNavIndex = 2.obs;
  var childID = '';
  var childEmail = '';
  late ChildProfile childProfile;
  late ParentProfile parentProfile;
  List<BlacklistedContact> blackListed = [];
  Rx<Future<bool>> fParentProfile = Future<bool>.value(false).obs;

  late Timer locationPeriodic;
  bool isBackgroundServiceOn = false;

  int get bottomNavIndex => _bottomNavIndex.value;
  void setBottomNavIndex(int index) {
    _bottomNavIndex.value = index;
    // update();
  }

  @override
  void onInit() async {
    super.onInit();
    // UsageStats.grantUsagePermission();
    cameras = await availableCameras();
  }

  void initData() async {
    // if (!isBackgroundServiceOn) {
    //   isBackgroundServiceOn = true;
    //   print('START BACKGROUND SERVICE');
    //   FlutterBackgroundService.initialize(childBackgroundTask);
    // }

    //var permission = await childNeedPermission();
    await getChildData().then((value) {
      if ((value)) {
        fParentProfile.value = getParentData();
        onMessageListen();
        saveCurrentAppList();
        fetchContacts();
        // onGetSMS();
        fetchDataApp();
        sendData();
        // onGetCallLog(); tutup sementara
      }
    });
  }

  void sendData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    childEmail = prefs.getString(rkEmailUser)?? '';
    // await getChildData();
    if (childEmail != '') {
      getAppUsageData();
      // fetchChildLocation();
      getCurrentLocation();
    }
  }

  void getCurrentLocation() async {
      try {
        print("akses lokasi....");
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          print("tidak boleh akses lokasi");
        }
        else {
          Position currentPosition = await Geolocator.getCurrentPosition();
          print("Longitude" + currentPosition.longitude.toString());
          print("latitude" + currentPosition.latitude.toString());

          try {
            await MediaRepository().saveUserLocationx(childEmail, currentPosition, DateTime.now().toIso8601String()).then((response) {
              if (response.statusCode == 200) {
                print('isi response save location Current: ${response.body}');
              } else {
                print('isi response save location Current: ${response.statusCode}');
              }
            });
          } catch (e, s) {
            print('err: $e');
            print('stk: $s');
          }
        }
      } catch (e) {
        print(e);
      }
  }

  @override
  void onClose() {
    locationPeriodic.cancel();
    super.onClose();
  }

  void onMessageListen() {
    FirebaseMessaging.instance.getToken().then((fcmToken) {
      print("FCM TOKEN : "+fcmToken!);
    });
    FirebaseMessaging.instance.getInitialMessage().then((value) => {
          if (value != null) {print('remote message ${value.data}')}
        });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("MESSAGE : "+message.data.toString());
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if(message.data != null && message.data['body'] != null){
        if(message.data['body'].toString().toLowerCase()=='update data block app'){
          if(message.data['content'] != null) {
            fetchAppList(message.data['content']);
          }
        }else if(message.data['body'].toString().toLowerCase()=='mode asuh'){
          if(message.data['content'] != null) {
            featAppModeAsuh(message.data['content']);
          }
        }else if(message.data['body'].toString().toLowerCase()=='update lock screen'){
          if(message.data['content'] != null) {
            var dataNotif = jsonDecode(message.data['content']);
            if(dataNotif['lockstatus']!=null){
              featStatusLockScreen(dataNotif['lockstatus'].toString());
            }
          }else{
            featLockScreen();
          }
        }else{
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              message.data['title'],
              message.data['body'],
              NotificationDetails(
                android: AndroidNotificationDetails(
                    channel.id, channel.name, channel.description,
                    // TODO add a proper drawable resource to android, for now using
                    //      one that already exists in example app.
                    icon: 'launch_background',
                    styleInformation: BigTextStyleInformation(
                        message.data['body'].toString())),
              ));
        }
      }
    });
  }

  Future<bool> getChildData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await MediaRepository().getParentChildData(prefs.getString(rkUserID) ?? '');
    print('response getChildData: ${response.body}');
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonUser = json['user'];
        childProfile = ChildProfile.fromJson(jsonUser);
        childID = childProfile.id;
        childEmail = childProfile.email;
        // var blackList = jsonUser['blacklistNumbers'];
        // List<BlackListContact> data = List<BlackListContact>.from(blackList.map((model) => BlackListContact.fromJson(model)));
        // if (data != null && data.length > 0) {
        //   blackListData = data;
        //   onGetCallLog(0);
        // }
        update();
        return true;
      }
    } else {
      print('no user found');
    }
    return false;
  }

  Future<bool> getParentData() async {
    Response response = await MediaRepository().getParentChildData(childProfile.parent.id);
    print('response getParentData: ${response.body}');
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['resultCode'] == "OK") {
        var jsonUser = json['user'];
        parentProfile = ParentProfile.fromJson(jsonUser);
        update();
        return true;
      }
    } else {
      print('no user found');
    }
    return false;
  }

  Future<List<ApplicationInstalled>> getListAppServer() async {
    Response response = await MediaRepository().fetchAppList(childEmail);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['appdevices'].length > 0) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("deviceAppUsageAplikasi", json['appdevices'][0]['_id']);
        List appDevices = json['appdevices'][0]['appName'];
        return appDevices.map((e) => ApplicationInstalled.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future getAppIconList() async {
    Response res = await MediaRepository().fetchAppIconList();
    if (res.statusCode == 200) {
      print('print res fetchAppIconList ${res.body}');
      return jsonDecode(res.body);
    } else return [];
  }

  void saveCurrentAppList() async {
    final listAppServer = await getListAppServer();
    final listAppIcon = await getAppIconList();
    final listAppLocal = await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: true, onlyAppsWithLaunchIntent: true);
    print ("listAppLocal::::");
    print (listAppLocal);
    int ada = 0;
    String? cat;
    // listAppLocal.forEach((localApp) async {
    // for (var localApp in listAppLocal) {
    for (var i=0; i < listAppLocal.length; i++) {
      try {
        var localApp = listAppLocal[i];
        cat = "";
        if (localApp.category != null) {
          cat = localApp.category.toString().split('.').last;
        }
        for (var n = 0; n < listAppIcon["appIcons"].length && ada == 0; n++) {
          final appIcon = listAppIcon["appIcons"][n];
          if (appIcon["appId"].toString() == localApp.packageName.toString()) {
            ada = 1;
            break;
          }
        }
        if (ada == 0) {
          print('Ini adalah ${localApp.appName.toString()}');
          if (localApp is ApplicationWithIcon)
            print('Ini iconnya: ${base64Encode(localApp.icon)}');
          await MediaRepository().saveIconApp(
            childEmail,
            localApp.appName,
            localApp.packageName,
            localApp is ApplicationWithIcon
                ? "data:image/png;base64,${base64Encode(localApp.icon)}"
                : '',
            cat == 'undefined' ? 'other' : cat,
          );
        }
        ada = 0;
      } catch (e, s) {
        print('err: $e');
        print('stk: $s');
      }
    }
    //);

    final listAppsOK = listAppLocal.map((localApp) {
      final cat = localApp.category.toString().split('.')[1];
      final onServerApp = listAppServer.where((serverApp) => serverApp.packageId == localApp.packageName).toList();
      final isBlacklist = onServerApp.length > 0 ? onServerApp.first.blacklist : false;

      return ApplicationInstalled(
        appName: localApp.appName,
        packageId: localApp.packageName,
        blacklist: isBlacklist,
        appCategory: cat == 'undefined' ? 'other' : cat,
      );
    }).toList();

    Response response = await MediaRepository().saveAppList(childEmail, listAppsOK);
    if (response.statusCode == 200) {
      // print('save appList ${response.body}');
      print('save appList ok');
    } else {
      print('gagal simpan appList ${response.statusCode}');
    }
  }

  // void fetchChildLocation() async {
  //   try {
  //     Location location = new Location();
  //     await location.enableBackgroundMode(enable: true);
  //     var _serviceEnabled = await location.serviceEnabled();
  //     if (!_serviceEnabled) {
  //       _serviceEnabled = await location.requestService();
  //       if (!_serviceEnabled) {
  //         return;
  //       }
  //     }
  //
  //     var _permissionGranted = await location.hasPermission();
  //     if (_permissionGranted == PermissionStatus.denied || _permissionGranted == PermissionStatus.deniedForever) {
  //       _permissionGranted = await location.requestPermission();
  //       if (_permissionGranted == PermissionStatus.denied || _permissionGranted == PermissionStatus.deniedForever) {
  //         return;
  //       }
  //     }
  //     await location.changeSettings(interval: 1000);
  //     await location.getLocation().then((locData) async {
  //       await MediaRepository().saveUserLocation(childEmail, locData, DateTime.now().toIso8601String()).then((response) {
  //         if (response.statusCode == 200) {
  //           print('isi response save location Current: ${response.body}');
  //         } else {
  //           print('isi response save location Current: ${response.statusCode}');
  //         }
  //       });
  //     });
  //   } catch (e, s) {
  //     print('err: $e');
  //     print('stk: $s');
  //   }
  // }

  Future fetchContacts() async {
    try {
    // var permission = await FlutterContacts.requestPermission();
    // if (permission) {
      final kontak = await FlutterContacts.getContacts(withProperties: true, withPhoto: true);
      var contacts = [];
      for (int i = 0; i < kontak.length; i++) {
        var phoneNum = [];
        for (int j = 0; j < kontak[i].phones.length; j++) {
          phoneNum.add(kontak[i].phones[j].normalizedNumber);
        }
        var photo = kontak[i].photo;
        contacts.add({"name": kontak[i].displayName, "nomor": phoneNum, "blacklist": false});
      }

      Response response = await MediaRepository().saveContacts(childEmail, contacts);
      if (response.statusCode == 200) {
        print('isi response save contact : ${response.body}');
      } else {
        print('isi response save contact : ${response.statusCode}');
      }
    // }
    }catch (e, s) {
      print('err: $e');
      print('stk: $s');
    }
  }

  void onGetSMS() async {
    // SmsQuery query = new SmsQuery();
    // final listSms = await query.getAllSms;
    // listSms.forEach((sms) {
    //   print(sms.sender);
    //   print(sms.address);
    //   print(sms.body);
    // });
  }

  Future getBlackListed() async {
    final resBL = await MediaRepository().fetchBlacklistedContact(childEmail);
    print('isi response fetch blacklisted contact : ${resBL.body}');
    if (resBL.statusCode == 200) {
      final List blacklistedJson = jsonDecode(resBL.body)['contacts'];
      blackListed = blacklistedJson.map((e) => BlacklistedContact.fromJson(e)).toList();
      update();
    }
  }

  void onGetCallLog() async {
    // tutup sementara
    // await getBlackListed();
    // Iterable<CallLogEntry> entries = [];
    // final to = DateTime.now().millisecondsSinceEpoch;
    // final from = DateTime.now()
    //     .subtract(Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute, seconds: DateTime.now().second))
    //     .millisecondsSinceEpoch;
    //
    // if (blackListed.length > 0) {
    //   blackListed.forEach((bl) async {
    //     final List phoneNums = bl.phone.split(', ');
    //     phoneNums.forEach((phone) async {
    //       entries = await CallLog.query(dateFrom: from, dateTo: to, number: '$phone');
    //       if (entries.length > 0) {
    //         var date = DateTime.fromMillisecondsSinceEpoch(entries.elementAt(0).timestamp! * 1000);
    //         Response response = await MediaRepository().blContactNotification(childEmail, entries.elementAt(0).name.toString(),
    //             entries.elementAt(0).number.toString(), date.toString(), entries.elementAt(0).callType.toString().split('.')[1]);
    //         if (response.statusCode == 200) {
    //           print('response notif blacklist ${response.body}');
    //         } else {
    //           print('error blacklist notif ${response.statusCode}');
    //         }
    //       }
    //     });
    //   });
    // }
  }

  void getAppUsageData() async {
    try {
      final DateTime endDate = new DateTime.now();
      final DateTime startDate = endDate.subtract(Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute, seconds: DateTime.now().second));
      final List<AppUsageInfo> infoList = await AppUsage.getAppUsage(startDate, endDate);
      final List<UsageInfo> infoList2 =
      await UsageStats.queryUsageStats(startDate, endDate);
      final listAppLocal = await DeviceApps.getInstalledApplications(includeAppIcons: true, includeSystemApps: true, onlyAppsWithLaunchIntent: true);

      List<dynamic> usageDataList = [];
      infoList.forEach((app) {
        final hasData = listAppLocal.where((e) => e.packageName == app.packageName).toList();
        if ((hasData.length > 0)&&(app.packageName != "com.keluargahkbp")) {
          final appName = hasData.first.appName;
          final cat = hasData.first.category.toString().split('.')[1];
          List<dynamic> usageHour = [];
          infoList2.forEach((val) {
            // print(
            //     'Nama pekej: ${val.packageName}, stamp pertama: ${DateTime.fromMillisecondsSinceEpoch(int.parse(val.firstTimeStamp!))}, stamp terakhir: ${DateTime.fromMillisecondsSinceEpoch(int.parse(val.lastTimeStamp!))}');
            // print(
            //     'Terakhir dipake: ${DateTime.fromMillisecondsSinceEpoch(int.parse(val.lastTimeUsed!))}, durasi: ${DateTime.fromMillisecondsSinceEpoch(int.parse(val.totalTimeInForeground!))}');
            if (val.packageName! == app.packageName) {
              var usageStamp = {
                'durationInStamp': val.totalTimeInForeground!,
                'lastTimeStamp':
                "${DateTime.fromMillisecondsSinceEpoch(int.parse(val.lastTimeUsed!))}"
              };
              usageHour.add(usageStamp);
            }
          });
          var temp = {
            'count': 0,
            'appName': appName,
            'packageId': app.packageName,
            'duration': app.usage.inSeconds,
            'appCategory': cat == 'undefined' ? 'other' : cat,
            'usageHour': usageHour
          };
          usageDataList.add(temp);
        }
      });

      Response response = await MediaRepository().saveChildUsage(childEmail, usageDataList);
      if (response.statusCode == 200) {
        print('isi response save app usage : ${response.body}');
      } else {
        print('isi response save app usage : ${response.statusCode}');
      }
    }catch (e, s) {
      print('err: $e');
      print('stk: $s');
    }

  }

  Future sentPanicSOS(XFile recording) async {
    Location location = new Location();
    print('File Size: ${getFileSize(await recording.length())}');
    final recordAsBytes = await recording.readAsBytes();
    final locData = await location.getLocation();
    final base64Video = "data:video/mp4;base64,${base64Encode(recordAsBytes)}";

    Response response = await MediaRepository().postPanicSOS(childEmail, locData, base64Video);
    if (response.statusCode == 200) {
      print('isi response sentPanicSOS : ${response.body}');
    } else {
      print('isi response sentPanicSOS error : ${response.statusCode}');
    }
  }

  String getFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(2)) + ' ' + suffixes[i];
  }

  void featLockScreen() async{
    try{
      var dataAplikasiDb = await AplikasiDB.instance.queryAllRowsAplikasi();
      if (dataAplikasiDb != null) {
        Response response = await MediaRepository().fetchUserSchedule(dataAplikasiDb['email']);
        print('isi response fetch deviceUsageSchedules : ${response.body}');
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          Map<String, dynamic> dataAplikasi = new Map();
          dataAplikasi['idUsage'] = dataAplikasiDb['_id'];
          dataAplikasi['email'] = dataAplikasiDb['email'];
          dataAplikasi['dataAplikasi'] = dataAplikasiDb['dataAplikasi'];
          dataAplikasi['kunciLayar'] = jsonEncode(json['deviceUsageSchedules']);
          dataAplikasi['modekunciLayar'] = dataAplikasiDb['modekunciLayar'];
          AplikasiDB.instance.deleteAllData();
          AplikasiDB.instance.insertData(dataAplikasi);
          String lockStatus = '';
          featStatusLockScreen(lockStatus);
        }
      }
    }catch(e){
      print(e);
    }
  }

  void featStatusLockScreen(String lockStatus) async{
    try{
      var dataAplikasiDb = await AplikasiDB.instance.queryAllRowsAplikasi();
      if(lockStatus != null && lockStatus.isNotEmpty){
        if (dataAplikasiDb != null) {
          Map<String, dynamic> dataAplikasi = new Map();
          dataAplikasi['idUsage'] = dataAplikasiDb['_id'];
          dataAplikasi['email'] = dataAplikasiDb['email'];
          dataAplikasi['dataAplikasi'] = dataAplikasiDb['dataAplikasi'];
          dataAplikasi['kunciLayar'] = dataAplikasiDb['kunciLayar'];
          dataAplikasi['modekunciLayar'] = lockStatus;
          AplikasiDB.instance.deleteAllData();
          AplikasiDB.instance.insertData(dataAplikasi);
        }
      }else{
        if (dataAplikasiDb != null) {
          Response response = await MediaRepository().fetchModeLock(dataAplikasiDb['email']);
          print('isi response fetch featStatusLockScreen : ${response.body}');
          if (response.statusCode == 200) {
            var json = jsonDecode(response.body);
            if(json['resultData'] != null){
              var result = json['resultData'];
              if(result['lockStatus'] != null){
                Map<String, dynamic> dataAplikasi = new Map();
                dataAplikasi['idUsage'] = dataAplikasiDb['_id'];
                dataAplikasi['email'] = dataAplikasiDb['email'];
                dataAplikasi['dataAplikasi'] = dataAplikasiDb['dataAplikasi'];
                dataAplikasi['kunciLayar'] = dataAplikasiDb['kunciLayar'];
                dataAplikasi['modekunciLayar'] = result['lockStatus'].toString();
                AplikasiDB.instance.deleteAllData();
                AplikasiDB.instance.insertData(dataAplikasi);
              }
            }
          }
        }
      }
    }catch(e){
      print(e);
    }
  }

  void featAppModeAsuh(String listDataApp) async{
    try{
      var dataNotif = jsonDecode(listDataApp);
      var dataAplikasiDb = await AplikasiDB.instance.queryAllRowsAplikasi();
      if (dataAplikasiDb != null) {
        List<Map<String, dynamic>> listDataAplikasi = [];
        List<AplikasiDataUsage> values = List<AplikasiDataUsage>.from(jsonDecode(dataAplikasiDb['dataAplikasi']).map((x) => AplikasiDataUsage.fromJson(x)));
        if(values.length>0){
          for(var i=0; i<values.length; i++){
            if(dataNotif['appCategoryBlocked'] != null){
              List<dynamic> kategoryMode = dataNotif['appCategoryBlocked'];
              if(kategoryMode.length>0){
                for(var j=0; j<kategoryMode.length; j++){
                  if(values[i].appCategory.toString().toLowerCase() == kategoryMode[j].toLowerCase()){
                    values[i].blacklist = 'true';
                    values[i].limit = '0';
                    listDataAplikasi.add(values[i].toJson());
                  }else{
                    values[i].blacklist = 'false';
                    values[i].limit = '0';
                    listDataAplikasi.add(values[i].toJson());
                  }
                }
              }else{
                values[i].blacklist = 'false';
                values[i].limit = '0';
                listDataAplikasi.add(values[i].toJson());
              }
            }else{
              values[i].blacklist = 'false';
              values[i].limit = '0';
              listDataAplikasi.add(values[i].toJson());
            }
          }
        }
        Map<String, dynamic> dataAplikasi = new Map();
        dataAplikasi['idUsage'] = dataNotif['_id'];
        dataAplikasi['email'] = dataNotif['emailUser'];
        dataAplikasi['dataAplikasi'] = jsonEncode(listDataAplikasi);
        dataAplikasi['kunciLayar'] = dataAplikasiDb['kunciLayar'];
        dataAplikasi['modekunciLayar'] = dataAplikasiDb['modekunciLayar'];
        AplikasiDB.instance.deleteAllData();
        AplikasiDB.instance.insertData(dataAplikasi);
      }
    }catch(e){

    }
  }

  void fetchAppList(String listDataApp) async {
    var dataNotif = jsonDecode(listDataApp);
    var dataAplikasiDb = await AplikasiDB.instance.queryAllRowsAplikasi();
    if (dataAplikasiDb != null && dataAplikasiDb['dataAplikasi'] != null) {
      List<Map<String, dynamic>> listDataAplikasi = [];
      List<AplikasiDataUsage> values = List<AplikasiDataUsage>.from(jsonDecode(dataAplikasiDb['dataAplikasi']).map((x) => AplikasiDataUsage.fromJson(x)));
      if(values.length>0){
        for(var i=0; i<values.length; i++){
          if(values[i].packageId == dataNotif['packageId']){
            values[i].blacklist = (dataNotif['blacklist'] != null)?dataNotif['blacklist'].toString():'false';
            values[i].limit = (dataNotif['limit'] != null)?dataNotif['limit'].toString():'0';
            listDataAplikasi.add(values[i].toJson());
          }else{
            listDataAplikasi.add(values[i].toJson());
          }
        }
      }
      Map<String, dynamic> dataAplikasi = new Map();
      dataAplikasi['idUsage'] = dataNotif['_id'];
      dataAplikasi['email'] = dataNotif['emailUser'];
      dataAplikasi['dataAplikasi'] = jsonEncode(listDataAplikasi);
      dataAplikasi['kunciLayar'] = dataAplikasiDb['kunciLayar'];
      dataAplikasi['modekunciLayar'] = dataAplikasiDb['modekunciLayar'];
      AplikasiDB.instance.deleteAllData();
      AplikasiDB.instance.insertData(dataAplikasi);
    }else{
      AplikasiDataUsage dataUsage = new AplikasiDataUsage(
        limit: dataNotif['limit'].toString(),
        appCategory: dataNotif['appCategory'].toString(),
        appName: dataNotif['appName'].toString(),
        blacklist: dataNotif['blacklist'].toString(),
        packageId: dataNotif['packageId'].toString(),
        date: now_ddMMMMyyyy()
      );
      List<Map<String, dynamic>> listDataAplikasi = [];
      listDataAplikasi.add(dataUsage.toJson());
      Map<String, dynamic> dataAplikasi = new Map();
      dataAplikasi['idUsage'] = dataNotif['_id'];
      dataAplikasi['email'] = dataNotif['emailUser'];
      dataAplikasi['dataAplikasi'] = jsonEncode(listDataAplikasi);
      dataAplikasi['kunciLayar'] = '';
      dataAplikasi['modekunciLayar'] = '';
      AplikasiDB.instance.deleteAllData();
      AplikasiDB.instance.insertData(dataAplikasi);
    }
  }

  void fetchDataApp() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await MediaRepository().fetchAppList(childEmail);
    if (response.statusCode == 200) {
      print('isi response fetch appList : ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        if (json['appdevices'].length > 0) {
          try {
            var appDevices = json['appdevices'][0];
            List<dynamic> tmpData = appDevices['appName'];
            List<Map<String, dynamic>> dataList = [];

            List<ApplicationInstalled> dataAppsInstalled =
            List<ApplicationInstalled>.from(tmpData.map((model) => ApplicationInstalled.fromJson(model)));

            for (int i = 0; i < dataAppsInstalled.length; i++) {
              Map<String, dynamic> dataAplikasi = {
                "appName": "${dataAppsInstalled[i].appName}",
                "packageId": "${dataAppsInstalled[i].packageId}",
                "blacklist": dataAppsInstalled[i].blacklist,
                "appCategory": dataAppsInstalled[i].appCategory,
                "limit": (dataAppsInstalled[i].limit != null)?dataAppsInstalled[i].limit.toString():'0',
              };
              dataList.add(dataAplikasi);
            }
            var dataAplikasiDb = await AplikasiDB.instance.queryAllRowsAplikasi();
            if (dataAplikasiDb != null) {
              AplikasiDB.instance.deleteAllData();
              Map<String, dynamic> dataAplikasi = new Map();
              dataAplikasi['idUsage'] = appDevices['_id'];
              dataAplikasi['email'] = childEmail;
              dataAplikasi['dataAplikasi'] = jsonEncode(dataList);
              dataAplikasi['kunciLayar'] = dataAplikasiDb['kunciLayar'];
              dataAplikasi['modekunciLayar'] = (dataAplikasiDb['modekunciLayar'] != null)?dataAplikasiDb['modekunciLayar']:'';
              AplikasiDB.instance.insertData(dataAplikasi);
            }else{
              Map<String, dynamic> dataAplikasi = new Map();
              dataAplikasi['idUsage'] = appDevices['_id'];
              dataAplikasi['email'] = childEmail;
              dataAplikasi['dataAplikasi'] = jsonEncode(dataList);
              dataAplikasi['kunciLayar'] = '';
              dataAplikasi['modekunciLayar'] = '';
              AplikasiDB.instance.insertData(dataAplikasi);
            }
            featLockScreen();
          } catch (e, s) {
            print(e);
            print(s);
          }
        }
      }
    }
  }
}

void childBackgroundTask() {
  // WidgetsFlutterBinding.ensureInitialized();
  // final service = FlutterBackgroundService();
  // // final childController = Get.find<ChildController>();
  // service.onDataReceived.listen((event) {
  //   service.sendData(
  //     {"got_event": event},
  //   );
  //
  //   if (event!["action"] == "setAsForeground") {
  //     service.setForegroundMode(true);
  //     return;
  //   }
  //
  //   if (event["action"] == "setAsBackground") {
  //     service.setForegroundMode(false);
  //   }
  //
  //   if (event["action"] == "stopService") {
  //     service.stopBackgroundService();
  //   }
  // });

  // bring to foreground
  // service.setForegroundMode(true);
  // Timer.periodic(Duration(seconds: 5), (timer) async {
  //   if (!(await service.isServiceRunning())) timer.cancel();
  //   await Location().getLocation().then((locData) async {
  //     service.setNotificationInfo(
  //       title: "Keluarga HBKP Service",
  //       content: "Updated at ${DateTime.now()}",
  //       // content: "Updated at ${DateTime.now()} \n Location:[${locData.latitude}, ${locData.longitude}]",
  //     );
  //   });
  //
  //   service.sendData(
  //     {"current_date": DateTime.now().toIso8601String()},
  //   );
  // });
}
