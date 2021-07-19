class AppIconList {
  final String? id;
  final String? appId;
  final String? appIcon;
  final String? dateCreate;
  final String? appName;

  AppIconList(
      {this.id,
        this.appId,
        this.appIcon,
        this.dateCreate,
        this.appName,});

  factory AppIconList.fromJson(Map<String, dynamic> json) {
    return AppIconList(
      id: json['_id'] as String?,
      appId: json['appId'] as String?,
      appIcon: json['appIcon'] as String?,
      dateCreate: json['dateCreate'] as String?,
      appName: json['appName'] as String?,
    );
  }
}