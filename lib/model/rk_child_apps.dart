class ApplicationInstalled {
  final String? appName;
  final String? packageId;
  final bool? blacklist;

  ApplicationInstalled(
      {this.appName,
        this.packageId,
      this.blacklist});

  factory ApplicationInstalled.fromJson(Map<String, dynamic> json) {
    return ApplicationInstalled(
      appName: json['appName'] as String?,
      packageId: json['packageId'] as String?,
      blacklist: json['blacklist'] as bool?,
    );
  }
}