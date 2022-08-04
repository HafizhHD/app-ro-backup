class ScreenTimeStandard {
  final String? controlParameterName;
  final int? controlParameterValue;
  final String? unit;

  ScreenTimeStandard(
      {this.controlParameterName, this.controlParameterValue, this.unit});

  factory ScreenTimeStandard.fromJson(Map<String, dynamic> json) {
    return ScreenTimeStandard(
        controlParameterName: json['controlParameterName'] as String?,
        controlParameterValue: int.tryParse(json['controlParameterValue']),
        unit: json['unit'] as String?);
  }
}
