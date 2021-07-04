class User {
  final String? name;
  final int? age;
  final String? email;
  final int? childOfNumber;
  final int? childNumber;
  final String? studyLevel;

  User(
      {this.name,
        this.age,
        this.email,
        this.childOfNumber,
        this.childNumber,
        this.studyLevel});


  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String?,
      age: json['age'] as int?,
      email: json['email'] as String?,
      childOfNumber: json['childOfNumber'] as int?,
      childNumber: json['childNumber'] as int?,
      studyLevel: json['studyLevel'] as String?,
    );
  }
}