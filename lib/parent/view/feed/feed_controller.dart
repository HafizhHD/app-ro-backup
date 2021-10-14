import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

enum ContentType { video, image, artikel }
ContentType ContentTypeFromString(String input) {
  if (input.trim().toLowerCase() == 'video') return ContentType.video;
  if (input.trim().toLowerCase() == 'image') return ContentType.image;
  return ContentType.artikel;
}

class ContentModel {
  String id;
  String coBrandEmail;
  String programId;
  String contentName;
  String contentDescription;
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
      contentType: ContentTypeFromString(json["contentType"]),
      contentThumbnail: json["contentThumbnail"],
      contents: json["contents"],
      startDate: DateTime.parse(json["startDate"]).toUtc().toLocal(),
      dateCreated: DateTime.parse(json["dateCreated"]).toUtc().toLocal(),
      status: json["status"].toString().toLowerCase() == 'active' ? true : false,
    );
  }
}

class FeedController extends GetxController {
  late List<ContentModel> listContent;
  late List<ContentModel> listSearchContent;
  final api = MediaRepository();
  Future<bool>? fGetList;

  @override
  void onInit() {
    super.onInit();
    WidgetsFlutterBinding.ensureInitialized();
    fGetList = getContents();
  }

  Future<bool> getContents() async {
    final res = await api.fetchCoBrandContents();
    if (res.statusCode == 200) {
      print('print res fetchCoBrandContents ${res.body}');
      final json = jsonDecode(res.body);
      if (json['resultCode'] == "OK") {
        List contents = json['contents'];
        listContent = contents.map((e) => ContentModel.fromJson(e)).toList();
        listContent.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
        listSearchContent = listContent.where((e) => e.status).toList();
        update();
        return true;
      }
    }

    listContent = [];
    return false;
  }

  void setSearchData(String text) {
    print("Text: $text");
    listSearchContent = listContent.where((element) => element.status && element.contentName.contains(text)).toList();
    update();
  }
}
