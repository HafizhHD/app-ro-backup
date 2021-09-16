import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_child_model.dart';

class ParentProfile {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String? address;
  final GenderCharacter parentStatus;
  final String userType;
  final String? imgPhoto;
  final List<Child>? children;

  ParentProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.address,
    required this.parentStatus,
    required this.userType,
    this.imgPhoto,
    this.children,
  });

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    final List listChild = json['childs'] ?? [];
    try {
      return ParentProfile(
        id: json['_id'],
        name: json['nameUser'],
        email: json['emailUser'],
        phone: json['phoneNumber'],
        address: json['address'],
        imgPhoto: json['imagePhoto'],
        userType: json['userType'],
        parentStatus: json['parentStatus'].toString().toLowerCase() == 'ayah' ? GenderCharacter.Ayah : GenderCharacter.Bunda,
        children: listChild.map((e) => Child.fromJson(e)).toList(),
      );
    } catch (e, s) {
      print('Error: $e');
      print('Stack: $s');
      return ParentProfile(
        id: json['_id'],
        name: json['nameUser'],
        email: json['emailUser'],
        phone: json['phoneNumber'],
        address: json['address'],
        imgPhoto: json['imagePhoto'],
        userType: json['userType'],
        parentStatus: json['parentStatus'].toString().toLowerCase() == 'ayah' ? GenderCharacter.Ayah : GenderCharacter.Bunda,
        children: listChild.map((e) => Child.fromJson(e)).toList(),
      );
    }
  }
}

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
