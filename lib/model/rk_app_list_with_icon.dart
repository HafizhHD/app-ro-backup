class AppListWithIcons {
  final String? appName;
  final String? packageId;
  final bool? blacklist;
  final String? appIcons;

  AppListWithIcons(
      {this.appName,
        this.packageId,
        this.blacklist,
      this.appIcons});

  factory AppListWithIcons.fromJson(Map<String, dynamic> json) {
    return AppListWithIcons(
      appName: json['appName'] as String?,
      packageId: json['packageId'] as String?,
      blacklist: json['blacklist'] as bool?,
      appIcons: json['appIcons'] as String?,
    );
  }
}