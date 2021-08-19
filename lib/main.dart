import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:ruangkeluarga/child/home_child.dart';
import 'package:ruangkeluarga/login/splash_info.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/home_parent.dart';
import 'package:ruangkeluarga/parent/view_model/vm_content_rk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global/global.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Color(0xff05745F), statusBarIconBrightness: Brightness.dark));

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.low,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
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
        theme: ThemeData(
          primaryColor: cOrtuBlue,
        ),
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Add Your Code here.
      Future.delayed(Duration(seconds: 2), () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final prevLogin = prefs.getBool(isPrefLogin);
        final roUserType = prefs.getString(rkUserType);
        if (prevLogin != null && roUserType != null && roUserType != '') {
          if (roUserType == "child") {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) =>
                    HomeChildPage(title: 'ruang keluarga', email: prefs.getString(rkEmailUser)!, name: prefs.getString(rkUserName)!)));
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeParentPage()));
          }
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SplashInfo()));
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
              Flexible(child: Hero(tag: 'ruangortuIcon', child: Image.asset('assets/images/ruangortu-icon_x4.png'))),
              wProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
