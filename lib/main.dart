import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ruangkeluarga/child/child_controller.dart';
import 'package:ruangkeluarga/child/child_main.dart';
import 'package:ruangkeluarga/child/setup_permission_child.dart';
import 'package:ruangkeluarga/login/login.dart';
import 'package:ruangkeluarga/login/setup_permissions.dart';
import 'package:ruangkeluarga/login/splash_info.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_controller.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/parent/view/main/parent_main.dart';
import 'package:ruangkeluarga/parent/view_model/vm_content_rk.dart';
import 'package:ruangkeluarga/utils/background_service_new.dart';
import 'package:ruangkeluarga/utils/base_service/service_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usage_stats/usage_stats.dart';
import 'global/global.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  ChildController controller1 = new ChildController();
  if (message.data != null && message.data['body'] != null) {
    String strMessage = message.data['body'].toString().toLowerCase();
    int posBlock = strMessage.indexOf('sedang dibatasi');
    int posModeAsuh = strMessage.indexOf('mode asuh');
    int poslockScreen = strMessage.indexOf('kunci layar');
    if ((message.data['body'].toString().toLowerCase() ==
            'update data block app') ||
        (posBlock >= 0)) {
      if (message.data['content'] != null) {
        controller1.fetchAppList(message.data['content']);
      }
    } else if ((message.data['body'].toString().toLowerCase() == 'mode asuh') ||
        (posModeAsuh >= 0)) {
      if (message.data['content'] != null) {
        controller1.featAppModeAsuh(message.data['content']);
      }
    } else if ((message.data['body'].toString().toLowerCase() ==
            'update lock screen') ||
        (poslockScreen >= 0)) {
      if ((message.data['content'] != null) &&
          (message.data['content'] != "")) {
        try {
          var dataNotif = jsonDecode(message.data['content']);
          if (dataNotif['lockstatus'] != null) {
            //jika lock membahayakan aktifkan source dibawah ini dan hidden source dibawahnya
            /*if(dataNotif['lockstatus'].toString() == 'true'){
          new MethodChannel('com.ruangkeluargamobile/android_service_background', JSONMethodCodec()).invokeMethod('lockDeviceChils', {'data':'data'});
        }*/
            controller1
                .featStatusLockScreen(dataNotif['lockstatus'].toString());
          }
        } catch (e) {
          print("Error Notif" + e.toString());
        }
      } else {
        controller1.featLockScreen();
      }
    }
  }
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void startServicePlatform() async {
  await BackgroundServiceNew.oneShot(
      const Duration(milliseconds: 5000), 12304, callbackBackgroundService,
      wakeup: true,
      exact: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true);
}

Future<Map<String, int>> getDurationAppForeground() async {
  final DateTime endDate = new DateTime.now();
  final DateTime startDate = endDate.subtract(Duration(
      hours: DateTime.now().hour,
      minutes: DateTime.now().minute,
      seconds: DateTime.now().second));
  final List<EventUsageInfo> infoList =
      await UsageStats.queryEvents(startDate, endDate);
  Map<String, List<List<int>>> infoList3 = {};
  String packageName = "";
  infoList.forEach((e) {
    int eventType = int.parse(e.eventType!);
    int eventTime = int.parse(e.timeStamp!);
    if (eventType == 1) packageName = e.packageName!;
    var array = [eventType, eventTime];
    if (infoList3.containsKey(e.packageName)) {
      infoList3[e.packageName]!.add(array);
    } else {
      List<List<int>> eventPair = [];
      eventPair.add(array);
      infoList3[e.packageName!] = eventPair;
    }
  });
  int duration = 0;
  int startTime = -1;
  int lastType = -1;
  infoList3.forEach((app, e) {
    // print(app);
    if (app == packageName) {
      e.asMap().forEach((i, val) {
        if (val[0] == 1 || val[0] == 2) {
          if ((val[0] == 2) && (lastType != 2)) {
            if (i == 0) {
              duration += val[1] - startDate.millisecondsSinceEpoch as int;
              startTime = -1;
            } else if (lastType == 1) {
              duration += val[1] - startTime as int;
              startTime = -1;
            }

            lastType = val[0];
          } else if (val[0] == 1 && lastType != 1) {
            if (i == e.length - 1) {
              duration += DateTime.now().millisecondsSinceEpoch - val[1] as int;
              startTime = -1;
              lastType = 2;
            } else {
              startTime = val[1];
              lastType = val[0];
            }
          }
        }
      });
    }
  });
  Map<String, int> data = {};
  data[packageName] = duration;
  return (data);
}

void callbackBackgroundService() async {
  print("background service on: ${DateTime.now()}");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final result = await InternetAddress.lookup('ruangortu.id');
    var koneksiInternet = prefs.getBool('koneksiInternet');
    if (result.isNotEmpty &&
        result[0].rawAddress.isNotEmpty &&
        koneksiInternet != null &&
        !koneksiInternet) {
      print("Internet connected");
      ChildController controller = new ChildController();
      controller.fetchDataApp();
      await prefs.setBool("koneksiInternet", true);
    }
  } on SocketException catch (_) {
    print("Diskonnect internet SocketException");
    await prefs.setBool("koneksiInternet", false);
  } on Exception catch (_) {
    print("Diskonnect internet Exception");
    await prefs.setBool("koneksiInternet", false);
  } finally {
    var durationAppForeground = await getDurationAppForeground();
    // print("durasi = " + durationAppForeground.toString());
    await BackgroundServiceNew.cekAppLaunch(durationAppForeground);
    startServicePlatform();
  }
}

/*void callBackAlert(String tag) {
  print(tag);
  switch (tag) {
    case "simple_button":
    case "updated_simple_button":
      SystemAlertWindow.closeSystemWindow(prefMode: SystemWindowPrefMode.OVERLAY);
      break;
    case "focus_button":
      print("Focus button has been called");
      SystemAlertWindow.closeSystemWindow(prefMode: SystemWindowPrefMode.OVERLAY);
      break;
    default:
      print("OnClick event of $tag");
  }
}*/

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: cTopBg, statusBarIconBrightness: Brightness.light));

  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
  // WidgetsFlutterBinding.ensureInitialized();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // channel = const AndroidNotificationChannel(
  //   'high_importance_channel', // id
  //   'High Importance Notifications', // title
  //   'This channel is used for important notifications.', // description
  //   importance: Importance.low,
  // );

  channel = AndroidNotificationChannel(
      'high_importance_channel', 'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.low);

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  initializeDateFormatting('en_ID', null).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: MediaViewModel()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(primaryColor: cOrtuInkWell),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initGetXService() {
    Get.put(ChildController());
    Get.put(ParentController());
    Get.put(RKServiceController());
    Get.put(FeedController());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    initGetXService();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Add Your Code here.
      Future.delayed(Duration(seconds: 2), () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final prevLogin = prefs.getBool(isPrefLogin);
        final roUserType = prefs.getString(rkUserType);
        final roUserEmail = prefs.getString(rkEmailUser) ?? '';
        final roUserName = prefs.getString(rkUserName) ?? '';

        try {
          final result = await InternetAddress.lookup('ruangortu.id');
          if (result.isEmpty) {
            showSnackbar('Silahkan periksa koneksi internet anda',
                bgColor: Colors.red, pShowDuration: Duration(seconds: 10));
            print("Internet not connected");
          } else {
            if (prevLogin != null && roUserType != null && roUserType != '') {
              if (await childNeedPermission() || await parentNeedPermission()) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await signOutGoogle();
                // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
                Navigator.of(context).push(leftTransitionRoute(LoginPage()));
              } else {
                if (roUserType == "child") {
                  MethodChannel channel = new MethodChannel(
                      'com.ruangkeluargamobile/android_service_background',
                      JSONMethodCodec());
                  bool? response = await channel.invokeMethod<bool>(
                      'permissionLockApp', {'data': 'data'});
                  print('response : ' + response.toString());
                  if (response!) {
                    if (await childNeedPermission()) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => SetupPermissionChildPage(
                              email: roUserEmail, name: roUserName)));
                    } else {
                      Get.put(FeedController());
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => ChildMain(
                                childEmail: roUserEmail,
                                childName: roUserName)),
                        (Route<dynamic> route) => false,
                      );
                    }
                  }
                } else {
                  Get.put(FeedController());
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => ParentMain()),
                    (Route<dynamic> route) => false,
                  );
                }
              }
            } else {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SplashInfo()));
            }
          }
        } catch (e) {
          showToastFailed(
              failedText: 'Silahkan periksa koneksi internet anda',
              ctx: context);
          print("Error Cek Internet. " + e.toString());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: cPrimaryBg,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: Hero(
                      tag: 'ruangortuIcon',
                      child: Image.asset(currentAppIconPath))),
              wProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
