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
  final List<Subscription> subscription;

  Child(
      {
        required this.id,
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
        this.status,
        required this.subscription
      });

  factory Child.fromJson(Map<String, dynamic> json) {
    final bdate = json['birdDate'];
    final List listSubscription = json['subscription'] ?? [];
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
        status: json['status'] as String?,
        subscription: listSubscription.map((e) => Subscription.fromJson(e)).toList(),
    );
  }
}

class Subscription {
  final String? id;
  final String? cobrandEmail;
  final String? subscriptionPackageId;
  final String? dateStart;
  final String? dateEnd;
  final String? dateCreated;

  Subscription(
  {
    this.cobrandEmail,
    this.dateCreated,
    this.dateStart,
    this.dateEnd,
    this.id,
    this.subscriptionPackageId,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      cobrandEmail: json['cobrandEmail'] as String,
      dateCreated: json['dateCreated'] as String,
      dateStart: json['dateStart'] as String,
      dateEnd: json['dateEnd'] as String,
      id: json['id'] as String,
      subscriptionPackageId: json['subscriptionPackageId'] as String,
    );

  }
}
