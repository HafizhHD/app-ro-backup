import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/cobrand_program_content_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../parent/view/feed/feed_comment.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_iframe/flutter_html_iframe.dart';

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
  final String userType;
  final String contentType;
  final String answerKey;

  RKWebViewDialog(
      {required this.url,
      required this.title,
      this.contents = '',
      this.image = '',
      this.description = '',
      this.source = '',
      this.contentId = '',
      this.emailUser = '',
      this.response,
      this.userType = '',
      this.contentType = '',
      this.answerKey = ''});

  @override
  _RKWebViewDialogState createState() => _RKWebViewDialogState();
}

class _RKWebViewDialogState extends State<RKWebViewDialog> {
  late WebViewController _webViewController;
  late List<ContentResponseModel> listLike;
  String fileHtmlContentReal = '';
  String selectedResponse = '';
  int totalLike = 0;
  String responId = '';
  bool liked = false;
  List<DropdownMenuItem<String>> choice = [];
  final api = MediaRepository();
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    loadContent();
    print('Isi file html: ' + fileHtmlContentReal);
    print(widget.contentId);
    print(widget.response);
    print('ContentType ' + widget.contentType);
    if (widget.response != null) {
      widget.response!.keys.forEach((e) {
        choice.add(DropdownMenuItem(child: Text(e), value: e));
        if (selectedResponse == '') selectedResponse = e;
      });
      if (widget.response!.keys.contains('like')) {
        getContentResponse();
      }
    }
  }

  void getContentResponse() async {
    final res2 = await api.fetchContentResponseAll(widget.contentId);
    if (res2.statusCode == 200) {
      // print('Print res fetchCoBrand: ${res2.body}');
      final json = jsonDecode(res2.body);
      if (json['resultCode'] == "OK") {
        List contentResponse = json['resultData'];
        listLike = contentResponse
            .map((e) => ContentResponseModel.fromJson(e))
            .toList();
        for (int i = 0; i < listLike.length; i++) {
          if (listLike[i].emailUser == widget.emailUser) {
            liked = true;
            break;
          }
        }
        setState(() {
          totalLike = listLike.length;
        });
      }
    }
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
    return WillPopScope(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: cTopBg,
            centerTitle: true,
            title: Text(widget.title),
          ),
          body: widget.response == null || widget.response!.keys.length <= 1
              ? widget.contentType == 'SOS'
                  ? SingleChildScrollView(
                      child: Html(data: fileHtmlContentReal, customRenders: {
                      iframeMatcher(): iframeRender()
                    }, style: {
                      'iframe': Style(
                          height: MediaQuery.of(context).size.height / 2,
                          width: MediaQuery.of(context).size.width)
                    }))
                  : SingleChildScrollView(
                      child: Html(data: fileHtmlContentReal, customRenders: {
                      iframeMatcher(): iframeRender()
                    }, style: {
                      'iframe': Style(alignment: Alignment.center)
                    }))
              : Column(children: [
                  Expanded(
                      child: SingleChildScrollView(
                          child: Html(
                              data: fileHtmlContentReal,
                              customRenders: {
                        iframeMatcher(): iframeRender()
                      },
                              style: {
                        'iframe': Style(alignment: Alignment.center)
                      }))),
                  Container(
                      // height: MediaQuery.of(context).size.height * 0.1,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 40),
                            child: DropdownButton(
                                isExpanded: true,
                                value: selectedResponse,
                                items: choice,
                                onChanged: (String? e) {
                                  setState(() {
                                    selectedResponse = e!;
                                  });
                                })),
                        widget.userType != 'parent'
                            ? FlatButton(
                                child: Text('Pilih Respon'),
                                onPressed: () async {
                                  showLoadingOverlay();
                                  final response = await api.addContentResponse(
                                      widget.contentId,
                                      widget.emailUser,
                                      selectedResponse,
                                      point:
                                          selectedResponse == widget.answerKey
                                              ? 1
                                              : 0);
                                  if (response.statusCode == 200) {
                                    showToastSuccess(
                                        ctx: context,
                                        successText:
                                            'Respon berhasil terkirim!');
                                    liked = true;
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
                            : Container()
                      ]))
                ]),
          floatingActionButton: widget.contentId != ''
              ? widget.response != null &&
                      widget.response!.keys.contains('like')
                  ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      FloatingActionButton(
                          elevation: 0,
                          focusElevation: 0,
                          hoverElevation: 0,
                          highlightElevation: 0,
                          backgroundColor: cAsiaBlue.withOpacity(0.8),
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Icon(Icons.thumb_up,
                                  color: liked ? cOrtuOrange : cOrtuWhite),
                              Text(
                                "$totalLike",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            showLoadingOverlay();
                            if (!liked) {
                              final response = await api.addContentResponse(
                                  widget.contentId, widget.emailUser, 'like');
                              if (response.statusCode == 200) {
                                // showToastSuccess(
                                //     ctx: context,
                                //     successText: 'Respon berhasil terkirim!');
                                final json = jsonDecode(response.body);
                                print(json);
                                // if (json['resultCode'] == "OK") {
                                //   ContentResponseModel contentResponse =
                                //       json['resultData'];
                                //   responId = contentResponse.id;
                                // }
                                setState(() {
                                  liked = true;
                                  totalLike++;
                                });
                                closeOverlay();
                              } else {
                                closeOverlay();
                                // showToastFailed(
                                //     ctx: context,
                                //     failedText:
                                //         'Gagal mengirim respon. Coba beberapa saat lagi.');
                              }
                            } else {
                              final response = await api.deleteContentResponse(
                                  widget.emailUser, widget.contentId);
                              if (response.statusCode == 200) {
                                // showToastSuccess(
                                //     ctx: context,
                                //     successText: 'Respon berhasil terkirim!');
                                setState(() {
                                  liked = false;
                                  totalLike--;
                                });
                                closeOverlay();
                              } else {
                                closeOverlay();
                                // showToastFailed(
                                //     ctx: context,
                                //     failedText:
                                //         'Gagal mengirim respon. Coba beberapa saat lagi.');
                              }
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
                  : widget.contentType == 'ujian' ||
                          widget.contentType == 'Ujian'
                      ? null
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
              : null),
      onWillPop: () async {
        Get.back(result: liked ? 'answered' : '');
        return false;
      },
    );
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
      else if (widget.source != '')
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
            "</body></html>";
      _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
              mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
          .toString());
    }
  }

  loadContent() {
    if (widget.contents != '' && widget.contentId != '') {
      String header =
          '<head> <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no"> </head>';
      if (widget.image != '')
        fileHtmlContentReal = "<!DOCTYPE html> <html>" +
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
      else if (widget.source != '')
        fileHtmlContentReal = "<!DOCTYPE html> <html>" +
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
      else
        fileHtmlContentReal = "<!DOCTYPE html> <html>" +
            header +
            "<body>" +
            "<h2>" +
            widget.title +
            "</h2>" +
            widget.contents +
            "<br/>" +
            widget.description +
            "</body></html>";
    } else {
      fileHtmlContentReal = widget.contents;
    }
  }
}

void showPrivacyPolicy() {
  Get.dialog(
    RKWebViewDialog(url: urlPP, title: 'Privacy Policy', contents: ppHtml()),
    transitionCurve: Curves.decelerate,
  );
}

void showTermCondition() {
  Get.dialog(
    RKWebViewDialog(
        url: urlTOC, title: 'Syarat dan Ketentuan', contents: tocHtml()),
    transitionCurve: Curves.decelerate,
  );
}

void showFAQ() {
  Get.dialog(
    RKWebViewDialog(url: urlFAQ, title: 'FAQ', contents: faqHtml()),
    transitionCurve: Curves.decelerate,
  );
}

Future<bool> showContent(context, String emailUser, String contentId,
    String contents, title, image, desc, source, response,
    {String userType = '',
    String contentType = '',
    String answerKey = ''}) async {
  var data = await Get.dialog(
    RKWebViewDialog(
        url: "",
        title: title,
        contents: contents,
        image: image,
        description: desc,
        source: source,
        contentId: contentId,
        emailUser: emailUser,
        response: response,
        userType: userType,
        contentType: contentType,
        answerKey: answerKey),
    transitionCurve: Curves.decelerate,
  );
  if (data == 'answered')
    return true;
  else
    return false;
}

void showUrl(String url, title, contentType) {
  Get.dialog(
    RKWebViewDialog(
        url: url,
        title: title,
        contents: sosHtml(url),
        contentType: contentType),
    transitionCurve: Curves.decelerate,
  );
}
