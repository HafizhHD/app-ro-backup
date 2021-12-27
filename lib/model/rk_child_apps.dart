class ApplicationInstalled {
  final String? appName;
  final String? packageId;
  final bool? blacklist;
  final String appCategory;
  final int? limit;

  ApplicationInstalled({this.appName, this.packageId, required this.appCategory, this.blacklist, this.limit});

  factory ApplicationInstalled.fromJson(Map<String, dynamic> json) {
    return ApplicationInstalled(
      appName: json['appName'] as String?,
      packageId: json['packageId'] as String?,
      blacklist: json['blacklist'].toString().toLowerCase() == 'true' ? true : false,
      appCategory: json['appCategory'],
      limit: (json['limit'] != null)?json['limit'] : 0,
    );
  }

  Map toJson() {
    return {
      "appName": appName,
      "packageId": packageId,
      "blacklist": blacklist.toString(),
      "appCategory": appCategory,
      "limit": limit,
    };
  }
}
