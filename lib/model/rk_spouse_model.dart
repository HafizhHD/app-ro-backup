import 'package:ruangkeluarga/global/global.dart';

class Spouse {
  final String id;
  final String? name;
  final String? email;
  final String? imgPhoto;
  final String? phone;
  final ParentCharacter parentStatus;
  final String? status;
  final String? address;
  final DateTime? birdDate;

  Spouse(
      {required this.id,
      this.name,
      this.email,
      this.imgPhoto,
      this.phone,
      required this.parentStatus,
      this.status,
      this.address,
      this.birdDate});

  factory Spouse.fromJson(Map<String, dynamic> json) {
    final bdate = json['birdDate'];
    return Spouse(
        id: json['_id'] ?? '',
        name: json['name'] as String?,
        email: json['email'] as String?,
        imgPhoto: json['imagePhoto'],
        phone: json['phoneNumber'] as String?,
        parentStatus: json['parentStatus'].toString().toLowerCase() == 'ayah'
            ? ParentCharacter.Ayah
            : (json['parentStatus'].toString().toLowerCase() == 'bunda'
                ? ParentCharacter.Bunda
                : ParentCharacter.Lainnya),
        status: json['status'] as String?,
        address: json['address'] as String?,
        birdDate: bdate != null && bdate != ''
            ? DateTime.parse(bdate).toUtc().toLocal()
            : null);
  }
}
