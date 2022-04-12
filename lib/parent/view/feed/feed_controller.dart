import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:ruangkeluarga/global/global.dart';

ContentType ContentTypeFromString(String input) {
  print('ini jenis contentnyaaaaa: ${input.trim().toLowerCase()}');
  if (input.trim().toLowerCase() == 'video') return ContentType.video;
  if (input.trim().toLowerCase() == 'image') return ContentType.image;
  if (input.trim().toLowerCase() == 'pdf') return ContentType.pdf;
  return ContentType.artikel;
}

class ContentModel {
  String id;
  String coBrandEmail;
  String programId;
  String contentName;
  String contentDescription;
  String contentSource;
  ContentType contentType;
  String contents;
  String? contentThumbnail;
  bool status;
  DateTime startDate;
  DateTime dateCreated;

  ContentModel({
    required this.id,
    required this.coBrandEmail,
    required this.programId,
    required this.contentName,
    required this.contentDescription,
    required this.contentSource,
    required this.contentType,
    required this.contents,
    this.contentThumbnail,
    required this.status,
    required this.startDate,
    required this.dateCreated,
  });
  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json["_id"],
      coBrandEmail: json["cobrandEmail"],
      programId: json["programId"],
      contentName: json["contentName"],
      contentDescription: json["contentDescription"],
      contentSource: json["contentSource"],
      contentType: ContentTypeFromString(json["contentType"]),
      contentThumbnail: json["contentThumbnail"],
      contents: json["contents"],
      startDate: DateTime.parse(json["startDate"]).toUtc().toLocal(),
      dateCreated: DateTime.parse(json["dateCreated"]).toUtc().toLocal(),
      status:
          json["status"].toString().toLowerCase() == 'active' ? true : false,
    );
  }
}

class CoBrandModel {
  String id;
  String email;
  String name;
  String? thumbnail;

  CoBrandModel(
      {required this.id,
      required this.email,
      required this.name,
      this.thumbnail});
  factory CoBrandModel.fromJson(Map<String, dynamic> json) {
    return CoBrandModel(
        id: json["_id"],
        email: json["email"],
        name: json["cobrandName"],
        thumbnail: json["thumbnail"]);
  }
}

class FeedController extends GetxController {
  late List<ContentModel> listContent;
  late List<ContentModel> listSearchContent;
  late List<CoBrandModel> listCoBrand;

  //-1 itu All, 0~... itu tergantung index pada list cobrand
  int selectedCoBrand = -1;
  String selectedCoBrandEmail = '';

  final api = MediaRepository();
  Future<bool>? fGetListContent, fGetListCoBrand;
  String lastUpdated = DateTime.now().toIso8601String();
  final ScrollController scrollController = new ScrollController();
  int offset = 0;
  final limit = 10;
  bool isThereMore = true;
  bool isWaiting = false;
  //bool stillSearching = false;
  String search = '';

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fGetListContent = getContents();
    fGetListCoBrand = getCoBrand();
  }

  void _scrollListener() {
    // print("Ini anu: ${scrollController.position.extentAfter}");
    if (scrollController.position.extentAfter < 100 &&
        isThereMore &&
        !isWaiting) {
      isWaiting = true;
      offset = offset + limit;
      fGetListContent = getContents();
    }
  }

  Future<bool> getContents({bool refresh = false, String cobrand = ''}) async {
    if (refresh == true) {
      lastUpdated = DateTime.now().toIso8601String();
      offset = 0;
      isThereMore = true;
    }
    if (cobrand == 'all')
      selectedCoBrandEmail = '';
    else if (cobrand != '') selectedCoBrandEmail = cobrand;
    final res = await api.fetchCoBrandContents(lastUpdated, limit, offset,
        key: search, email: selectedCoBrandEmail);
    if (res.statusCode == 200) {
      // print('print res fetchCoBrandContents ${res.body}');
      final json = jsonDecode(res.body);
      if (json['resultCode'] == "OK") {
        List contents = json['contents'];
        if (offset == 0)
          listContent = contents.map((e) => ContentModel.fromJson(e)).toList();
        else
          listContent += contents.map((e) => ContentModel.fromJson(e)).toList();

        listSearchContent = listContent;
        // listContent.sort((a, b) => b.startDate.compareTo(a.startDate));
        // listSearchContent = listContent
        //     .where((e) => e.status && e.startDate.isBefore(DateTime.now()))
        //     .toList();
        update();
        if (contents.length < 10) {
          isThereMore = false;
        }
        isWaiting = false;
        return true;
      }
    }
    print("Ini error contentnya: $res");
    listContent = [];
    return false;
  }

  Future<bool> getCoBrand() async {
    final res2 = await api.fetchCoBrand();
    if (res2.statusCode == 200) {
      // print('Print res fetchCoBrand: ${res2.body}');
      final json = jsonDecode(res2.body);
      if (json['resultCode'] == "OK") {
        List cobrands = json['cobrands'];
        listCoBrand = cobrands.map((e) => CoBrandModel.fromJson(e)).toList();
        update();
        return true;
      }
    }
    print('Error fetchCoBrand: $res2');
    return false;
  }

  void setSearchData(String text) {
    print("Text: $text");
    offset = 0;
    isThereMore = true;
    search = text;
    // Timer(Duration(milliseconds: 800), () {
    //   //stillSearching = true;
    // });
    // //stillSearching = false;
    getContents();
  }
}
