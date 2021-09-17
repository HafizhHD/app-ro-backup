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
  final DateTime? birdDate;
  final String? namaGereja;
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
    this.birdDate,
    this.namaGereja,
  });

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    final List listChild = json['childs'] ?? [];
    final bdate = json['birdDate'];
    try {
      return ParentProfile(
        id: json['_id'],
        name: json['nameUser'],
        email: json['emailUser'],
        phone: json['phoneNumber'],
        address: json['address'],
        imgPhoto: json['imagePhoto'],
        userType: json['userType'],
        birdDate: bdate != null && bdate != '' ? DateTime.parse(bdate).toUtc().toLocal() : null,
        namaGereja: json['namaHkbp'],
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

class GerejaHKBP {
  String id;
  String status;
  String nama;
  String distrik;
  String alamat;

  GerejaHKBP({
    required this.id,
    required this.status,
    required this.nama,
    required this.distrik,
    required this.alamat,
  });

  factory GerejaHKBP.fromJson(Map<String, dynamic> json) {
    return GerejaHKBP(
      id: json['_id'],
      status: json['status'],
      nama: json['nama'],
      distrik: json['distrik'],
      alamat: json['alamat'],
    );
  }
}
