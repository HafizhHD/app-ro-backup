import 'dart:core';

import 'package:ruangkeluarga/global/global.dart';

class ContentModel {
  String id;
  String coBrandEmail;
  String programId;
  String contentName;
  int? nomerUrutTahapan;
  String contentDescription;
  String contentSource;
  ContentType contentType;
  String contents;
  String? contentThumbnail;
  bool status;
  DateTime startDate;
  DateTime dateCreated;
  Map<String, dynamic>? response;
  String answerKey;

  ContentModel(
      {required this.id,
      required this.coBrandEmail,
      required this.programId,
      required this.contentName,
      this.nomerUrutTahapan,
      required this.contentDescription,
      required this.contentSource,
      required this.contentType,
      required this.contents,
      this.contentThumbnail,
      required this.status,
      required this.startDate,
      required this.dateCreated,
      this.response,
      required this.answerKey});
  factory ContentModel.fromJson(Map<String, dynamic> json) {
    int nomor = 0;
    if (json["nomerUrutTahapan"] != null) nomor = json["nomerUrutTahapan"];
    return ContentModel(
        id: json["_id"],
        coBrandEmail: json["cobrandEmail"],
        programId: json["programId"],
        contentName: json["contentName"],
        nomerUrutTahapan: nomor,
        contentDescription: json["contentDescription"],
        contentSource: json["contentSource"],
        contentType: ContentTypeFromString(json["contentType"]),
        contentThumbnail: json["contentThumbnail"],
        contents: json["contents"],
        startDate: DateTime.parse(json["startDate"]).toUtc().toLocal(),
        dateCreated: DateTime.parse(json["dateCreated"]).toUtc().toLocal(),
        status:
            json["status"].toString().toLowerCase() == 'active' ? true : false,
        response: json["respons"],
        answerKey: json["answerKey"] ?? 'Kunci jawaban tidak ada');
  }
}

class ContentResponseModel {
  String id;
  String emailUser;
  String contentId;
  String programId;
  String respon;
  int point;
  DateTime dateCreated;

  ContentResponseModel(
      {required this.id,
      required this.emailUser,
      required this.contentId,
      required this.programId,
      required this.respon,
      required this.point,
      required this.dateCreated});
  factory ContentResponseModel.fromJson(Map<String, dynamic> json) {
    int nomor = 0;
    if (json["point"] != null) nomor = json["point"];
    return ContentResponseModel(
        id: json["_id"],
        emailUser: json["emailUser"],
        contentId: json["contentId"],
        programId: json["programId"],
        respon: json["respon"],
        point: nomor,
        dateCreated: DateTime.parse(json["dateCreated"]).toUtc().toLocal());
  }
}

ContentType ContentTypeFromString(String input) {
  // print('ini jenis contentnyaaaaa: ${input.trim().toLowerCase()}');
  if (input.trim().toLowerCase() == 'video') return ContentType.video;
  if (input.trim().toLowerCase() == 'image') return ContentType.image;
  if (input.trim().toLowerCase() == 'pdf') return ContentType.pdf;
  return ContentType.artikel;
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

class ProgramModel {
  String id;
  String coBrandEmail;
  String programName;
  String ProgramDescription;
  String? thumbnail;
  DateTime startDate;
  DateTime dateCreated;
  bool status;
  List<String> category;

  ProgramModel(
      {required this.id,
      required this.coBrandEmail,
      required this.programName,
      required this.ProgramDescription,
      this.thumbnail,
      required this.startDate,
      required this.dateCreated,
      required this.status,
      required this.category});
  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
        id: json["_id"],
        coBrandEmail: json["cobrandEmail"],
        programName: json["programName"],
        ProgramDescription: json["ProgramDescription"],
        thumbnail: json["programthumnail"],
        startDate: DateTime.parse(json["startDate"]).toUtc().toLocal(),
        dateCreated: DateTime.parse(json["dateCreated"]).toUtc().toLocal(),
        status:
            json["status"].toString().toLowerCase() == 'active' ? true : false,
        category: List<String>.from(json['category']));
  }
}
