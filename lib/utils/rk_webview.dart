import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class RKWebViewDialog extends StatefulWidget {
  final String url;
  final String title;
  final String contents;


  RKWebViewDialog({required this.url, required this.title, this.contents = ''});

  @override
  _RKWebViewDialogState createState() => _RKWebViewDialogState();
}

class _RKWebViewDialogState extends State<RKWebViewDialog> {
  late WebViewController _webViewController;
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
        javascriptMode: JavascriptMode.unrestricted,

        onWebViewCreated: (WebViewController webViewController){
          _webViewController=webViewController;
          loadAsset();
        },
      ),
    );
  }

  loadAsset() async {
    if (widget.contents != '') {
      String fileHtmlContents = "<!DOCTYPE html> <html> <body> " + widget.contents + "</body></html>";
      _webViewController.loadUrl(Uri.dataFromString(
          fileHtmlContents, mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'))
          .toString());
    }
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

void showFAQ() {
  Get.dialog(
    RKWebViewDialog(
      url: urlFAQ,
      title: 'FAQ',
    ),
    transitionCurve: Curves.decelerate,
  );
}

void showContent(String contents, title) {
  Get.dialog(
    RKWebViewDialog(
      url: "",
      title: title,
      contents: contents,
    ),
    transitionCurve: Curves.decelerate,
  );
}

void showUrl(String url, title) {
  Get.dialog(
    RKWebViewDialog(
      url: url,
      title: title,
      contents: "",
    ),
    transitionCurve: Curves.decelerate,
  );
}

