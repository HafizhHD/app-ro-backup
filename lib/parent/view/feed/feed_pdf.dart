import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:internet_file/internet_file.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_controller.dart';
import 'package:html/parser.dart' show parse;
import 'dart:core';

class FeedPdf extends StatefulWidget {
  final ContentModel contentModel;

  @override
  _FeedPdfState createState() => _FeedPdfState();

  FeedPdf({Key? key, required this.contentModel}) : super(key: key);
}

class _FeedPdfState extends State<FeedPdf> {
  bool _isLoading = true;
  late PdfControllerPinch pdfPinchController;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() {
    var document = parse(widget.contentModel.contents);
    List contentData = document.getElementsByTagName('iframe');
    var urlData = '';
    if (contentData.length > 0) {
      urlData = contentData[0].attributes['src']!;
      if (urlData.substring(0, 4) == 'data') {
        urlData = urlData.split(';base64,')[1];
        Uint8List bytes = base64.decode(urlData);
        pdfPinchController =
            PdfControllerPinch(document: PdfDocument.openData(bytes));
      } else {
        Uri uriUri = Uri.parse(urlData);
        if (uriUri.queryParameters['url'] != null)
          urlData = uriUri.queryParameters['url']!;
        pdfPinchController = PdfControllerPinch(
          document: PdfDocument.openData(InternetFile.get(urlData)),
        );
      }
    } else {
      // contentData = document.getElementsByTagName('object');
      // print('panjang contentData: ${contentData.length}');
      // urlData = contentData[0].attributes['src']!;
      // urlData = urlData.split(';base64,')[1];
      // Uint8List bytes = base64.decode(urlData);
      // pdfPinchController =
      //     PdfControllerPinch(document: PdfDocument.openData(bytes));
      pdfPinchController = PdfControllerPinch(
          document: PdfDocument.openData(InternetFile.get(
              'http://www.africau.edu/images/default/sample.pdf')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cOrtuBlue,
        title: Text(widget.contentModel.contentName),
      ),
      body: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : // Pdf view with re-render pdf texture on zoom (not loose quality on zoom)
// Not supported on windows
              PdfViewPinch(
                  controller: pdfPinchController,
                )
          //uncomment below line to preload all pages
          // lazyLoad: false,
          // uncomment below line to scroll vertically
          // scrollDirection: Axis.vertical,

          //uncomment below code to replace bottom navigation with your own
          /* navigationBuilder:
                          (context, page, totalPages, jumpToPage, animateToPage) {
                        return ButtonBar(
                          alignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.first_page),
                              onPressed: () {
                                jumpToPage()(page: 0);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                animateToPage(page: page - 2);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                animateToPage(page: page);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.last_page),
                              onPressed: () {
                                jumpToPage(page: totalPages - 1);
                              },
                            ),
                          ],
                        );
                      }, */

          ),
    );
  }
}
