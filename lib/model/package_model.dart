class PackageModel {
  final String PackageId;
  final String PackageName;
  final String PackageDescription;
  final int PackagePrice;
  final String? PackageIcon;


  PackageModel(
  {
    required this.PackageId,
    required this.PackageName,
    required this.PackageDescription,
    required this.PackagePrice,
    this.PackageIcon,
  }
  );


  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      PackageId: json['packageId'] as String,
      PackageName: json['packageName'] as String,
      PackageDescription: json['packageDescription'] as String,
      PackagePrice: json['price'] as int,
      PackageIcon: json['packageIcon'] as String?,
    );
  }
}