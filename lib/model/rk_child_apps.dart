class ApplicationInstalled {
  final String? appName;
  final String? packageId;
  final bool? blacklist;
  final String appCategory;
  final String? appIcon;

  ApplicationInstalled({this.appName, this.packageId, required this.appCategory, this.blacklist, this.appIcon});

  factory ApplicationInstalled.fromJson(Map<String, dynamic> json) {
    return ApplicationInstalled(
      appName: json['appName'] as String?,
      packageId: json['packageId'] as String?,
      blacklist: json['blacklist'] as bool?,
      appCategory: json['appCategory'],
      appIcon: json['appIcon'],
    );
  }

  Map toJson() {
    return {
      "appName": appName,
      "packageId": packageId,
      "blacklist": blacklist.toString(),
      "appCategory": appCategory,
      "appIcon": appIcon,
    };
  }
}
