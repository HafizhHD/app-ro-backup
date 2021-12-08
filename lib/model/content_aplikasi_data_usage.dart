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

  AplikasiDataUsage(
      {this.appCategory,
        this.appName,
        this.blacklist,
        this.packageId});


  factory AplikasiDataUsage.fromJson(Map<dynamic, dynamic> json) {
    return AplikasiDataUsage(
      appCategory: json['appCategory'] as String?,
      appName: json['appName'] as String?,
      blacklist: json['blacklist'] as String?,
      packageId: json['packageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "appCategory": appCategory,
    "appName": appName,
    "blacklist": blacklist,
    "packageId": packageId,
  };
}