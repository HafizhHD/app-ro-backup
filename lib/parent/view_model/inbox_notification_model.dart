import 'dart:convert';

import 'package:ruangkeluarga/model/rk_child_location_model.dart';

enum NotifType { sos, alert }
NotifType notifTypeFromString(String text) {
  final type = text.trim().toLowerCase();
  switch (type) {
    case 'sos':
      return NotifType.sos;
    default:
      return NotifType.alert;
  }
}

class InboxNotif {
  bool readStatus;
  String id;
  NotifType type;
  MessageNotif message;
  DateTime createAt;

  InboxNotif({
    required this.readStatus,
    required this.id,
    required this.type,
    required this.message,
    required this.createAt,
  });

  factory InboxNotif.fromJson(Map<String, dynamic> json) {
    final messages = MessageNotif.fromJson(json['message']);
    // if (json['type'].toString() == 'sos') {
    //
    //   String? place = messages.location != null ? messages.location.place : "";
    //   messages.message = "Panggilan SOS dari lokasi " +  messages.location.place;
    // } else {
    //
    // }
    return InboxNotif(
      readStatus:
          json['status'].toString().toLowerCase() == 'unread' ? false : true,
      id: json['_id'],
      type: notifTypeFromString(json['type'].toString()),
      message: messages,
      createAt: DateTime.parse(json['dateCreate']).toUtc().toLocal(),
    );
  }
}

class MessageNotif {
  String message;
  String subject;
  LocationModel? location;
  String? childEmail;
  String? videoUrl;

  MessageNotif({
    required this.message,
    required this.subject,
    this.location,
    this.childEmail,
    this.videoUrl,
  });

  factory MessageNotif.fromJson(Map<String, dynamic> json) {
    final jsonLocation = json['location'];
    try {
      final xx = json['location'];
    } catch (e, s) {
      print('err: $e');
      print('stk: $s');
    }
    return MessageNotif(
      message: json['message'],
      subject: json['subject'] != null ? json['subject'] : '',
      location: jsonLocation != null ? LocationModel.fromJson(json['location']) : null,
      childEmail: json['childEmail'],
      videoUrl: json['videoUrl'],
    );
  }
}
