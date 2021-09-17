import 'package:get/get.dart';

enum ContentType { video, image, artikel }

class FeedModel {
  String id;
  String coBrandEmail;
  String programId;
  String contentName;
  String contentDescription;
  ContentType contentType;
  String contentThumbnail;
  bool status;
  DateTime startDate;
  DateTime dateCreated;

  FeedModel({
    required this.id,
    required this.coBrandEmail,
    required this.programId,
    required this.contentName,
    required this.contentDescription,
    required this.contentType,
    required this.contentThumbnail,
    required this.status,
    required this.startDate,
    required this.dateCreated,
  });
  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      id: json["_id"],
      coBrandEmail: json["cobrandEmail"],
      programId: json["programId"],
      contentName: json["contentName"],
      contentDescription: json["contentDescription"],
      contentType: json["contentType"],
      contentThumbnail: json["contentThumbnail"],
      startDate: json["startDate"],
      dateCreated: json["dateCreated"],
      status: json["status"],
    );
  }
}

class FeedController extends GetxController {}
