import 'package:ruangkeluarga/global/global_formatter.dart';

class AppListWithIcons {
  final String? appName;
  final String? packageId;
  final bool? blacklist;
  final String? appIcons;
  final String appCategory;

  AppListWithIcons({this.appName, this.packageId, this.blacklist, required this.appCategory, this.appIcons});

  factory AppListWithIcons.fromJson(Map<String, dynamic> json) {
    print('json $json');
    return AppListWithIcons(
      appName: json['appName'] as String?,
      packageId: json['packageId'] as String?,
      appCategory: json['appCategory'],
      blacklist: json['blacklist'].toString().toLowerCase() == 'true' ? true : false,
      appIcons: json['appIcons'] as String?,
    );
  }
}

class AppUsageData {
  final String appId;
  final bool blacklist;
  final String appCategory;
  final int limit;
  final DateTime createDate;

  AppUsageData({required this.appId, required this.appCategory, required this.blacklist, required this.limit, required this.createDate});

  factory AppUsageData.fromJson(Map<String, dynamic> json) {
    return AppUsageData(
      appId: json['appId'] ?? '',
      appCategory: json['appCategory'] ?? '',
      blacklist: json['blacklist'] == 'true' ? true : false,
      limit: json['limit'] ?? 0,
      createDate: DateTime.parse(json['dateCreate']),
    );
  }
}
