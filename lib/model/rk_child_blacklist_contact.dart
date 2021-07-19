class BlackListContact {
  final String? id;
  final String? emailUser;
  final String? label;
  final dynamic contact;
  final String? dateCreated;

  BlackListContact(
      {this.id,
        this.emailUser,
        this.label,
        this.contact,
        this.dateCreated,});


  factory BlackListContact.fromJson(Map<String, dynamic> json) {
    return BlackListContact(
      id: json['_id'] as String?,
      emailUser: json['emailUser'] as String?,
      label: json['label'] as String?,
      contact: json['contact'] as dynamic,
      dateCreated: json['dateCreated'] as String?,
    );
  }
}