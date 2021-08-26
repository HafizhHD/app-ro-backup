class Child {
  final String? name;
  final int? age;
  final String? email;
  final int? childOfNumber;
  final int? childNumber;
  final String? StudyLevel;

  Child({
    this.name,
    this.age,
    this.email,
    this.childOfNumber,
    this.childNumber,
    this.StudyLevel,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      name: json['name'] as String?,
      age: json['age'] as int?,
      email: json['email'] as String?,
      childOfNumber: json['childOfNumber'] as int?,
      childNumber: json['childNumber'] as int?,
      StudyLevel: json['StudyLevel'] as String?,
    );
  }

  void printData() {
    print('Name: $name');
    print('age: $age');
    print('email: $email');
    print('StudyLevel: $StudyLevel');
    print('childNumber: $childNumber');
    print('childOfNumber: $childOfNumber');
  }
}
