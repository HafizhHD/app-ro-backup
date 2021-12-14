import 'package:ruangkeluarga/global/global.dart';

class ListAplikasiDataUsage {
  final List<AplikasiDataUsage>? data;

  ListAplikasiDataUsage(
      {this.data,});

  Map<String, dynamic> toJson() => {
    "data": new List<Map<String, dynamic>>.from(data!.map((x) => x.toJson())),
  };
}

class AplikasiDataUsage {
  final String? appCategory;
  final String? appName;
  final String? blacklist;
  final String? packageId;
  final String? limit;
  final String? date;

  AplikasiDataUsage(
      {this.appCategory,
        this.appName,
        this.blacklist,
        this.packageId,
      this.limit,
      this.date});


  factory AplikasiDataUsage.fromJson(Map<dynamic, dynamic> json) {
    return AplikasiDataUsage(
      appCategory: json['appCategory'].toString(),
      appName: json['appName'].toString(),
      blacklist: json['blacklist'].toString(),
      packageId: json['packageId'].toString(),
      limit: ((json['limit'] != null)? json['limit']:'0').toString(),
      date: now_ddMMMMyyyy(),
    );
  }

  Map<String, dynamic> toJson() => {
    "appCategory": appCategory,
    "appName": appName,
    "blacklist": blacklist,
    "packageId": packageId,
    "limit": limit,
    "date": date,
  };
}