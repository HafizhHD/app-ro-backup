class AppUsages {
  String id;
  String emailUser;
  String appUsageDate;
  List<AppUsagesDetail> appUsagesDetail;

  AppUsages({
    required this.id,
    required this.emailUser,
    required this.appUsageDate,
    required this.appUsagesDetail,
  });

  factory AppUsages.fromJson(Map<String, dynamic> json) {
    final List appUsageData = json['appUsages'];

    return AppUsages(
      id: json['_id'],
      emailUser: json['emailUser'],
      appUsageDate: json['appUsageDate'],
      appUsagesDetail: appUsageData.map((e) => AppUsagesDetail.fromJson(e)).toList(),
    );
  }
}

class AppUsagesDetail {
  String appName;
  String packageId;
  int duration;
  String appCategory;
  List<dynamic>? usageHour;
  String? iconUrl;

  AppUsagesDetail({
    required this.appName,
    required this.packageId,
    required this.duration,
    required this.appCategory,
    this.usageHour,
    this.iconUrl,
  });

  factory AppUsagesDetail.fromJson(Map<String, dynamic> json) {
    return AppUsagesDetail(
      appName: json['appName'],
      packageId: json['packageId'],
      duration: json['duration'],
      appCategory: json['appCategory'],
      usageHour: json['usageHour'] ?? []
    );
  }
}
