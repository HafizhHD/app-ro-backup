class GerejaHKBP {
  String id;
  bool status;
  String nama;
  String distrik;
  String alamat;
  String ressort;
  String displayName;

  GerejaHKBP({
    required this.id,
    required this.status,
    required this.nama,
    required this.distrik,
    required this.alamat,
    required this.ressort,
    required this.displayName,
  });

  factory GerejaHKBP.fromJson(Map<String, dynamic> json) {
    final namaHuria = json['nama'];
    final distrik = json['distrik'];
    final ressort = json['ressort'];

    return GerejaHKBP(
        id: json['_id'],
        status: json['status'].toString().trim().toLowerCase() == 'active' ? true : false,
        nama: namaHuria,
        distrik: distrik,
        alamat: json['alamat'],
        ressort: ressort,
        displayName: '[$distrik] Ressort $ressort - Huria $namaHuria');
  }
}
