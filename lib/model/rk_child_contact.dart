class Contact {
  final String name;
  final String phone;
  final bool blacklist;

  Contact({required this.name, required this.phone, required this.blacklist});

  factory Contact.fromJson(Map<String, dynamic> json, List<BlacklistedContact> blacklisted) {
    final thisName = json['name'];
    List nomor = json['nomor'];
    final isBL = blacklisted.where((blData) => blData.name == thisName).toList();

    try {
      return Contact(
        name: thisName,
        phone: nomor.join(', '),
        blacklist: isBL.length > 0
            ? true
            : json['blacklist'].toString().toLowerCase() == 'true'
                ? true
                : false,
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

class BlacklistedContact {
  final String name;
  final String phone;

  BlacklistedContact({required this.name, required this.phone});

  factory BlacklistedContact.fromJson(Map<String, dynamic> json) {
    final data = json['contact'];
    final List nomor = data['phones'];

    return BlacklistedContact(
      name: data['name'],
      phone: nomor.join(', '),
    );
  }
}
