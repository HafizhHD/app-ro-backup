import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_child_model.dart';

import '../../../model/rk_spouse_model.dart';

class ParentProfile {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String? address;
  final ParentCharacter parentStatus;
  final String userType;
  final String? imgPhoto;
  final DateTime? birdDate;
//  final String? namaGereja;
  final List<Child>? children;
  final List<Spouse>? spouse;
  final String? status;
  final bool isMainParent;

  ParentProfile(
      {required this.id,
      required this.email,
      required this.name,
      required this.phone,
      this.address,
      required this.parentStatus,
      required this.userType,
      this.imgPhoto,
      this.children,
      this.spouse,
      this.birdDate,
      this.status,
      required this.isMainParent});

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    final List listChild = json['childs'] ?? [];
    final List listSpouse = json['spouse'] ?? [];
    final bdate = json['birdDate'];
    final String parentEmail = json['parentEmail'] ?? '';
    try {
      return ParentProfile(
        id: json['_id'],
        name: json['nameUser'],
        email: json['emailUser'],
        phone: json['phoneNumber'],
        address: (json['address'] != null) ? json['address'] : "",
        imgPhoto: json['imagePhoto'],
        userType: json['userType'],
        birdDate: bdate != null && bdate != ''
            ? DateTime.parse(bdate).toUtc().toLocal()
            : null,
        parentStatus: json['parentStatus'].toString().toLowerCase() == 'ayah'
            ? ParentCharacter.Ayah
            : (json['parentStatus'].toString().toLowerCase() == 'bunda'
                ? ParentCharacter.Bunda
                : ParentCharacter.Lainnya),
        children: listChild.map((e) => Child.fromJson(e)).toList(),
        spouse: listSpouse.map((e) => Spouse.fromJson(e)).toList(),
        status: json['status'] as String?,
        isMainParent: parentEmail == '',
      );
    } catch (e, s) {
      print('Error: $e');
      print('Stack: $s');
      return ParentProfile(
        id: json['_id'],
        name: json['nameUser'],
        email: json['emailUser'],
        phone: json['phoneNumber'],
        address: (json['address'] != null) ? json['address'] : "",
        imgPhoto: json['imagePhoto'],
        userType: json['userType'],
        parentStatus: json['parentStatus'].toString().toLowerCase() == 'ayah'
            ? ParentCharacter.Ayah
            : (json['parentStatus'].toString().toLowerCase() == 'bunda'
                ? ParentCharacter.Bunda
                : ParentCharacter.Lainnya),
        children: listChild.map((e) => Child.fromJson(e)).toList(),
        spouse: listSpouse.map((e) => Spouse.fromJson(e)).toList(),
        status: json['status'] as String?,
        isMainParent: parentEmail == '',
      );
    }
  }
}
