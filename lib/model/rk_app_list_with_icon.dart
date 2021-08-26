class AppListWithIcons {
  final String? appName;
  final String? packageId;
  final bool? blacklist;
  final String? appIcons;
  final String appCategory;

  AppListWithIcons({this.appName, this.packageId, this.blacklist, required this.appCategory, this.appIcons});

  factory AppListWithIcons.fromJson(Map<String, dynamic> json) {
    return AppListWithIcons(
      appName: json['appName'] as String?,
      packageId: json['packageId'] as String?,
      appCategory: json['appCategory'],
      blacklist: json['blacklist'] as bool?,
      appIcons: json['appIcons'] as String?,
    );
  }
}
