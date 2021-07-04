class Contact {
  final String? name;
  final List<dynamic>? phone;
  final bool? blacklist;

  Contact(
    {this.name,
      this.phone,
      this.blacklist});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'] as String?,
      phone: json['nomor'] as List<dynamic>?,
      blacklist: json['blacklist'] as bool?,
    );
  }
}