import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../parent/view/feed/feed_comment.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

class RKWebViewDialog extends StatefulWidget {
  final String url;
  final String title;
  final String contents;
  final String image;
  final String description;
  final String source;
  final String contentId;
  final String emailUser;
  final Map<String, dynamic>? response;

  RKWebViewDialog(
      {required this.url,
      required this.title,
      this.contents = '',
      this.image = '',
      this.description = '',
      this.source = '',
      this.contentId = '',
      this.emailUser = '',
      this.response});

  @override
  _RKWebViewDialogState createState() => _RKWebViewDialogState();
}

class _RKWebViewDialogState extends State<RKWebViewDialog> {
  late WebViewController _webViewController;
  String selectedResponse = '';
  List<DropdownMenuItem<String>> choice = [];
  final api = MediaRepository();
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    print(widget.contentId);
    print(widget.response);
    if (widget.response != null)
      widget.response!.keys.forEach((e) {
        choice.add(DropdownMenuItem(child: Text(e), value: e));
        if (selectedResponse == '') selectedResponse = e;
      });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: cTopBg,
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: widget.response == null || widget.response!.keys.length <= 1
            ? WebView(
                initialUrl: widget.url,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _webViewController = webViewController;
                  loadAsset();
                },
                navigationDelegate: (NavigationRequest request) async {
                  if ((request.url
                          .startsWith('https://api.whatsapp.com/send/')) ||
                      (request.url.startsWith('whatsapp://send/?phone'))) {
                    //https://api.whatsapp.com/send/?phone=628119004410&text&app_absent=0
                    print('blocking navigation to $request}');
                    List<String> urlSplitted = request.url.split("text=");

                    String phone = "628119004410";
                    String message = '';
                    // String message = urlSplitted.last.toString().replaceAll("%20", " ");
                    await _launchURL(
                        "https://wa.me/$phone/?text=${Uri.parse(message)}");
                    return NavigationDecision.prevent;
                  }

                  print('allowing navigation to $request');
                  return NavigationDecision.navigate;
                },
              )
            : Column(children: [
                Expanded(
                    child: WebView(
                  initialUrl: widget.url,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _webViewController = webViewController;
                    loadAsset();
                  },
                  navigationDelegate: (NavigationRequest request) async {
                    if ((request.url
                            .startsWith('https://api.whatsapp.com/send/')) ||
                        (request.url.startsWith('whatsapp://send/?phone'))) {
                      //https://api.whatsapp.com/send/?phone=628119004410&text&app_absent=0
                      print('blocking navigation to $request}');
                      List<String> urlSplitted = request.url.split("text=");

                      String phone = "628119004410";
                      String message = '';
                      // String message = urlSplitted.last.toString().replaceAll("%20", " ");
                      await _launchURL(
                          "https://wa.me/$phone/?text=${Uri.parse(message)}");
                      return NavigationDecision.prevent;
                    }

                    print('allowing navigation to $request');
                    return NavigationDecision.navigate;
                  },
                )),
                Container(
                    // height: MediaQuery.of(context).size.height * 0.1,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      DropdownButton(
                          value: selectedResponse,
                          items: choice,
                          onChanged: (String? e) {
                            setState(() {
                              selectedResponse = e!;
                            });
                          }),
                      FlatButton(
                          child: Text('Pilih Respon'),
                          onPressed: () async {
                            showLoadingOverlay();
                            final response = await api.addContentResponse(
                                widget.contentId,
                                widget.emailUser,
                                selectedResponse);
                            if (response.statusCode == 200) {
                              showToastSuccess(
                                  ctx: context,
                                  successText: 'Respon berhasil terkirim!');
                              closeOverlay();
                            } else {
                              closeOverlay();
                              showToastFailed(
                                  ctx: context,
                                  failedText:
                                      'Gagal mengirim respon. Coba beberapa saat lagi.');
                            }
                          },
                          textColor: Colors.white,
                          color: cAsiaBlue)
                    ]))
              ]),
        floatingActionButton: widget.contentId != ''
            ? widget.response != null && widget.response!.keys.contains('like')
                ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    FloatingActionButton(
                        elevation: 0,
                        focusElevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        backgroundColor: cAsiaBlue.withOpacity(0.8),
                        child: Icon(Icons.thumb_up, color: cOrtuWhite),
                        onPressed: () async {
                          showLoadingOverlay();
                          final response = await api.addContentResponse(
                              widget.contentId, widget.emailUser, 'like');
                          if (response.statusCode == 200) {
                            // showToastSuccess(
                            //     ctx: context,
                            //     successText: 'Respon berhasil terkirim!');
                            closeOverlay();
                          } else {
                            closeOverlay();
                            // showToastFailed(
                            //     ctx: context,
                            //     failedText:
                            //         'Gagal mengirim respon. Coba beberapa saat lagi.');
                          }
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    FloatingActionButton(
                        elevation: 0,
                        focusElevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        backgroundColor: cAsiaBlue.withOpacity(0.8),
                        child: Icon(Icons.forum_sharp, color: cOrtuWhite),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => FeedComment(
                                  emailUser: widget.emailUser,
                                  contentId: widget.contentId,
                                  contentName: widget.title)));
                        })
                  ])
                : FloatingActionButton(
                    elevation: 0,
                    focusElevation: 0,
                    hoverElevation: 0,
                    highlightElevation: 0,
                    backgroundColor: cAsiaBlue.withOpacity(0.8),
                    child: Icon(Icons.forum_sharp, color: cOrtuWhite),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FeedComment(
                              emailUser: widget.emailUser,
                              contentId: widget.contentId,
                              contentName: widget.title)));
                    })
            : null);
  }

  loadAsset() async {
    if (widget.contents != '') {
      String fileHtmlContents = '';
      String header =
          '<head> <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no"> </head>';
      if (widget.image != '')
        fileHtmlContents = "<!DOCTYPE html> <html>" +
            header +
            "<body> "
                '<img src="' +
            widget.image +
            '" alt="Red dot" width="100%"/> </p>' +
            "<h2>" +
            widget.title +
            "</h2>" +
            widget.contents +
            "<h4>Source: " +
            widget.source +
            "</h4>" +
            "</body></html>";
      else
        fileHtmlContents = "<!DOCTYPE html> <html>" +
            header +
            "<body>" +
            "<h2>" +
            widget.title +
            "</h2>" +
            widget.contents +
            "<br/>" +
            widget.description +
            "<h4>Source: " +
            widget.source +
            "</h4>" +
            "</body></html>";
      _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
              mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
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

void showContent(context, String emailUser, String contentId, String contents,
    title, image, desc, source, response) {
  Get.dialog(
    RKWebViewDialog(
        url: "",
        title: title,
        contents: contents,
        image: image,
        description: desc,
        source: source,
        contentId: contentId,
        emailUser: emailUser,
        response: response),
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
