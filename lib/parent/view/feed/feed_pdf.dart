import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:native_pdf_view/native_pdf_view.dart';
// import 'package:internet_file/internet_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_comment.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_controller.dart';
import 'package:html/parser.dart' show parse;
import 'dart:core';

class FeedPdf extends StatefulWidget {
  final String emailUser;
  final ContentModel contentModel;

  @override
  _FeedPdfState createState() => _FeedPdfState();

  FeedPdf({Key? key, required this.emailUser, required this.contentModel})
      : super(key: key);
}

class _FeedPdfState extends State<FeedPdf> {
  bool _isLoading = true;
  late PdfController pdfController;
  late Uint8List toBeDownloaded;
  static const int _initialPage = 1;
  int _actualPageNumber = _initialPage, _allPagesCount = 0;

  @override
  void initState() {
    loadDocument();
    super.initState();
  }

  @override
  void dispose() {
    pdfController.dispose();
    super.dispose();
  }

  loadDocument() async {
    var document = parse(widget.contentModel.contents);
    List contentData = document.getElementsByTagName('iframe');
    var urlData = '';
    if (contentData.length > 0) {
      urlData = contentData[0].attributes['src']!;
      if (urlData.substring(0, 4) == 'data') {
        urlData = urlData.split(';base64,')[1];
        Uint8List bytes = base64.decode(urlData);
        toBeDownloaded = bytes;
      } else {
        Uri uriUri = Uri.parse(urlData);
        if (uriUri.queryParameters['url'] != null)
          urlData = uriUri.queryParameters['url']!;
        http.Response responseData = await http.get(Uri.parse(urlData));
        toBeDownloaded = responseData.bodyBytes;
      }

      pdfController = PdfController(
        document: PdfDocument.openData(toBeDownloaded),
      );
      setState(() => _isLoading = false);
    } else {
      // contentData = document.getElementsByTagName('object');
      // print('panjang contentData: ${contentData.length}');
      // urlData = contentData[0].attributes['src']!;
      // urlData = urlData.split(';base64,')[1];
      // Uint8List bytes = base64.decode(urlData);
      // pdfPinchController =
      //     PdfControllerPinch(document: PdfDocument.openData(bytes));
      http.Response responseData = await http
          .get(Uri.parse('http://www.africau.edu/images/default/sample.pdf'));
      pdfController =
          PdfController(document: PdfDocument.openData(responseData.bodyBytes));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: cTopBg,
          title: Text(widget.contentModel.contentName,
              style: TextStyle(color: cOrtuWhite)),
          actions: <Widget>[
            FlatButton(
                color: Colors.transparent,
                child: Icon(Icons.navigate_before, color: cOrtuWhite),
                onPressed: () {
                  pdfController.previousPage(
                      duration: Duration(milliseconds: 100),
                      curve: Curves.ease);
                }),
            Container(
              alignment: Alignment.center,
              child: Text(
                '$_actualPageNumber/$_allPagesCount',
                style: const TextStyle(fontSize: 22),
              ),
            ),
            FlatButton(
                color: Colors.transparent,
                child: Icon(Icons.navigate_next, color: cOrtuWhite),
                onPressed: () {
                  pdfController.nextPage(
                      duration: Duration(milliseconds: 100),
                      curve: Curves.ease);
                }),
            // FlatButton(
            //     color: Colors.transparent,
            //     child: Icon(Icons.download, color: cOrtuWhite),
            //     onPressed: () async {
            //       var storage = await Permission.storage.status;
            //       if (!storage.isGranted) {
            //         await Permission.storage.request();
            //       }
            //       Directory? directory = await getExternalStorageDirectory();
            //       if (directory != null) {
            //         File fileDef = File('${directory.path}/download.pdf');
            //         await fileDef.create(recursive: true);
            //         Uint8List bytes1 = toBeDownloaded;
            //         await fileDef.writeAsBytes(bytes1);
            //         Fluttertoast.showToast(
            //             msg:
            //                 'PDF ini berhasil diunduh ke folder ${directory.path}',
            //             toastLength: Toast.LENGTH_LONG,
            //             gravity: ToastGravity.BOTTOM,
            //             timeInSecForIosWeb: 5,
            //             backgroundColor: Colors.green,
            //             textColor: Colors.white,
            //             fontSize: 16.0);
            //       } else {
            //         Fluttertoast.showToast(
            //             msg: 'PDF ini gagal diunduh.',
            //             toastLength: Toast.LENGTH_LONG,
            //             gravity: ToastGravity.BOTTOM,
            //             timeInSecForIosWeb: 5,
            //             backgroundColor: Colors.red,
            //             textColor: Colors.white,
            //             fontSize: 16.0);
            //       }
            //     }),
          ]),
      body: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PdfView(
                  controller: pdfController,
                  onDocumentLoaded: (document) {
                    setState(() {
                      _allPagesCount = document.pagesCount;
                    });
                  },
                  onPageChanged: (page) {
                    setState(() {
                      _actualPageNumber = page;
                    });
                  },
                )),
      floatingActionButton: FloatingActionButton(
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
                    contentId: widget.contentModel.id,
                    contentName: widget.contentModel.contentName)));
          }),
    );
  }
}
