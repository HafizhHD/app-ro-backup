class Child {
  final String id;
  final String? name;
  final int? age;
  final String? email;
  final int? childOfNumber;
  final int? childNumber;
  final String? studyLevel;
  final String? imgPhoto;
  final String? phone;
  final String? address;
  final DateTime? birdDate;
  final String? status;

  Child(
      {required this.id,
      this.name,
      this.age,
      this.email,
      this.childOfNumber,
      this.childNumber,
      this.studyLevel,
      this.imgPhoto,
      this.phone,
      this.address,
      this.birdDate,
      this.status});

  factory Child.fromJson(Map<String, dynamic> json) {
    final bdate = json['birdDate'];
    return Child(
        id: json['_id'] ?? '',
        name: json['name'] as String?,
        age: json['age'] as int?,
        email: json['email'] as String?,
        childOfNumber: json['childOfNumber'] as int?,
        childNumber: json['childNumber'] as int?,
        studyLevel: json['StudyLevel'] as String?,
        imgPhoto: json['imagePhoto'],
        phone: json['phoneNumber'] as String?,
        address: json['address'] as String?,
        birdDate: bdate != null && bdate != ''
            ? DateTime.parse(bdate).toUtc().toLocal()
            : null,
        status: json['status'] as String?);
  }
}
