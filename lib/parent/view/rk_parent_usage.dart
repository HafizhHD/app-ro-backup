import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';

class ParentUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}

class ParentUsagePage extends StatefulWidget {
  final String name;
  final String email;

  @override
  _ParentUsagePageState createState() => _ParentUsagePageState();

  ParentUsagePage({Key? key, required this.name, required this.email})
      : super(key: key);
}

class _ParentUsagePageState extends State<ParentUsagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text('Penggunaan Aplikasi', style: TextStyle(color: cOrtuWhite)),
          backgroundColor: cTopBg,
          iconTheme: IconThemeData(color: Colors.grey.shade700),
        ),
        backgroundColor: Colors.grey[300],
        body: Container());
  }
}
