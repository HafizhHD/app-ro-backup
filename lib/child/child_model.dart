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
  final ParentProfile parent;
  final Child? childInfo;

  ChildProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.address,
    required this.userType,
    this.imgPhoto,
    required this.parent,
    this.childInfo,
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    try {
      return ChildProfile(
        id: json['_id'],
        name: json['nameUser'],
        email: json['emailUser'],
        phone: json['phoneNumber'],
        address: json['address'],
        imgPhoto: json['imagePhoto'],
        userType: json['userType'],
        parent: ParentProfile.fromJson(json['parent']),
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
        imgPhoto: json['imagePhoto'],
        userType: json['userType'],
      );
    }
  }
}
