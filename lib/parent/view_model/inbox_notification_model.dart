class InboxNotif {
  bool readStatus;
  String id;
  String message;
  DateTime createAt;

  InboxNotif({
    required this.readStatus,
    required this.id,
    required this.message,
    required this.createAt,
  });

  factory InboxNotif.fromJson(Map<String, dynamic> json) {
    return InboxNotif(
      readStatus: json['status'].toString().toLowerCase() == 'unread' ? false : true,
      id: json['_id'],
      message: json['message'],
      createAt: DateTime.parse(json['dateCreate']).toUtc().toLocal(),
    );
  }
}
