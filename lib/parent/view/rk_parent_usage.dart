import 'package:flutter/material.dart';

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

  ParentUsagePage({Key? key, required this.name, required this.email}) : super(key: key);

}

class _ParentUsagePageState extends State<ParentUsagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penggunaan Aplikasi', style: TextStyle(color: Colors.darkGrey)),
        backgroundColor: Colors.whiteLight,
        iconTheme: IconThemeData(color: Colors.darkGrey),
      ),
      backgroundColor: Colors.grey[300],
      body: Container(

      )
    );
  }

}