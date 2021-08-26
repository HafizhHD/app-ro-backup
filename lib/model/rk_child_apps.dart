class ApplicationInstalled {
  final String? appName;
  final String? packageId;
  final bool? blacklist;
  final String appCategory;

  ApplicationInstalled({this.appName, this.packageId, required this.appCategory, this.blacklist});

  factory ApplicationInstalled.fromJson(Map<String, dynamic> json) {
    return ApplicationInstalled(
        appName: json['appName'] as String?,
        packageId: json['packageId'] as String?,
        blacklist: json['blacklist'] as bool?,
        appCategory: json['appCategory']);
  }
}
