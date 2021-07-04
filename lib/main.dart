import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:provider/provider.dart';
import 'package:ruangkeluarga/child/home_child.dart';
import 'package:ruangkeluarga/confirm_privacy_policy.dart';
import 'package:ruangkeluarga/parent/view/home_parent.dart';
import 'package:ruangkeluarga/parent/view_model/vm_content_rk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/constant.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set the background messaging handler early on, as a named top-level function
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: MediaViewModel()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.green,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_){

      // Add Your Code here.
      Future.delayed(Duration(seconds: 5), ()
      async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if(prefs.getBool(isPrefLogin) != null) {
          if(prefs.getBool(isPrefLogin)!) {
            if(prefs.getString(rkUserType) != null) {
              if(prefs.getString(rkUserType) == "child") {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) =>
                        HomeChildPage(title: 'ruang keluarga', email: prefs.getString(rkEmailUser)!,
                        name: prefs.getString(rkUserName)!)));
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) =>
                        HomeParentPage(title: 'ruang keluarga')));
              }
            } else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ConfirmPrivacyPolicyPage(title: 'Confirm Privacy Policy')));
            }
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => ConfirmPrivacyPolicyPage(title: 'Confirm Privacy Policy')));
          }
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => ConfirmPrivacyPolicyPage(title: 'Confirm Privacy Policy')));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    FlutterStatusbarcolor.setStatusBarColor(Color(0xff05745F));
    return Material(
      child: Container(
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                //mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    "ruang",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 40),
                  ),
                  Text(
                    " keluarga",
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffFF018786), fontSize: 40),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
