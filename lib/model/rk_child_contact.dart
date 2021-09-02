class Contact {
  final String name;
  final String phone;
  final bool blacklist;

  Contact({required this.name, required this.phone, required this.blacklist});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      phone: json['nomor'],
      blacklist: json['blacklist'].toString().toLowerCase() == 'true' ? true : false,
    );
  }
}
