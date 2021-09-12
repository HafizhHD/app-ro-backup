import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RKWebViewDialog extends StatefulWidget {
  final String url;
  final String title;

  RKWebViewDialog({required this.url, required this.title});

  @override
  _RKWebViewDialogState createState() => _RKWebViewDialogState();
}

class _RKWebViewDialogState extends State<RKWebViewDialog> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cPrimaryBg,
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: WebView(
        initialUrl: widget.url,
      ),
    );
  }
}

void showPrivacyPolicy() {
  Get.dialog(
    RKWebViewDialog(
      url: urlPP,
      title: 'Privacy Policy',
    ),
    transitionCurve: Curves.decelerate,
  );
}

void showTermCondition() {
  Get.dialog(
    RKWebViewDialog(
      url: urlTOC,
      title: 'Syarat dan Ketentuan',
    ),
    transitionCurve: Curves.decelerate,
  );
}
