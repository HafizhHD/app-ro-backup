import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';

class InboxPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: cPrimaryBg,
        appBar: AppBar(
          backgroundColor: cPrimaryBg,
          centerTitle: true,
          title: Text('Inbox'),
          elevation: 0,
        ),
        body: Center(
          child: Text('Inbox Kosong', style: TextStyle(color: cOrtuWhite)),
        ),
      ),
    );
  }
}
