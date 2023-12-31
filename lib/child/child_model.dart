import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_child_model.dart';
import 'package:ruangkeluarga/parent/view/main/parent_model.dart';

class ChildProfile {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String? address;
  final String userType;
  final String? imgPhoto;
  final DateTime? birdDate;
  final ParentProfile parent;
  final List otherParent;
  final Child? childInfo;

  ChildProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.address,
    required this.userType,
    this.imgPhoto,
    this.birdDate,
    required this.parent,
    required this.otherParent,
    this.childInfo,
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    final bdate = json['birdDate'];
    try {
      return ChildProfile(
        id: json['_id'],
        name: json['nameUser'],
        email: json['emailUser'],
        phone: json['phoneNumber'],
        address: json['address'],
        imgPhoto: json['imagePhoto'],
        userType: json['userType'],
        birdDate: bdate != null && bdate != ''
            ? DateTime.parse(bdate).toUtc().toLocal()
            : null,
        parent: ParentProfile.fromJson(json['parent']),
        otherParent: json['otherParent'],
        childInfo: Child.fromJson(json['childInfo']),
      );
    } catch (e, s) {
      print('Error: $e');
      print('Stack: $s');
      return ChildProfile(
        id: json['_id'],
        name: json['nameUser'],
        email: json['emailUser'],
        phone: json['phoneNumber'],
        address: json['address'],
        parent: ParentProfile.fromJson(json['parent']),
        otherParent: json['otherParent'],
        imgPhoto: json['imagePhoto'],
        userType: json['userType'],
      );
    }
  }
}
