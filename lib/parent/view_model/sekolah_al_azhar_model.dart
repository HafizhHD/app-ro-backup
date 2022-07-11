import 'dart:ffi';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class SekolahAlAzhar {
  String id;
  bool status;
  String nama;
  String deskripsi;
  String alamat;
  String jenjang;
  String lokasi;
  String telp;
  String fax;
  // List <Float>? geometry;

  SekolahAlAzhar({
    required this.id,
    required this.status,
    required this.nama,
    required this.deskripsi,
    required this.alamat,
    required this.jenjang,
    required this.lokasi,
    required this.telp,
    required this.fax,
    // required this.geometry,
  });

  factory SekolahAlAzhar.fromJson(Map<String, dynamic> json) {
    // final List posisi = json['geometry'] ?? [];
    // var latLong = [1.0,1.0];
    // if (posisi.length == 2) {
    //   latLong[0] = posisi[0];
    //   latLong[1] = posisi[1];
    // }
    final id = json['_id'];
    final status = json['status'];
    final nama = json['nama'];
    final deskripsi = json['deskripsi'];
    final alamat = json['alamat'];
    final jenjang = json['jenjang'];
    final lokasi = json['lokasi'];
    final telp = json['telp'];
    final fax = json['fax'];
    //final geometry = latLong;
    return SekolahAlAzhar(
        id: id,
        status: status.toString().trim().toLowerCase() == 'active' ? true : false,
        nama: nama,
        deskripsi: deskripsi,
        alamat: alamat,
        jenjang: jenjang,
        lokasi: lokasi,
        telp: telp,
        fax: fax,
        // geometry: json['geometry'] ?? [],
    );
  }
}
