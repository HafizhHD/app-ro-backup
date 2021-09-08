class Contact {
  final String name;
  final String phone;
  final bool blacklist;

  Contact({required this.name, required this.phone, required this.blacklist});

  factory Contact.fromJson(Map<String, dynamic> json) {
    List nomor = json['nomor'];
    try {
      return Contact(
        name: json['name'],
        phone: nomor.join(', '),
        blacklist: json['blacklist'].toString().toLowerCase() == 'true' ? true : false,
      );
    } catch (e, s) {
      print('err: $e');
      print('stack: $s');
      return Contact(
        name: json['name'],
        phone: '-',
        blacklist: json['blacklist'].toString().toLowerCase() == 'true' ? true : false,
      );
    }
  }
}
