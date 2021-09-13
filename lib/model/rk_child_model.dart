class Child {
  final String id;
  final String? name;
  final int? age;
  final String? email;
  final int? childOfNumber;
  final int? childNumber;
  final String? studyLevel;
  final String? imgPhoto;

  Child({
    required this.id,
    this.name,
    this.age,
    this.email,
    this.childOfNumber,
    this.childNumber,
    this.studyLevel,
    this.imgPhoto,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['_id'] ?? '',
      name: json['name'] as String?,
      age: json['age'] as int?,
      email: json['email'] as String?,
      childOfNumber: json['childOfNumber'] as int?,
      childNumber: json['childNumber'] as int?,
      studyLevel: json['StudyLevel'] as String?,
      imgPhoto: json['imagePhoto'],
    );
  }
}
