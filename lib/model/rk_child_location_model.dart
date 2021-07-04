class LocationChild {
  final String? id;
  final String? email;
  final dynamic location;
  final String? dateHistory;

  LocationChild({
    this.id,
    this.email,
    this.location,
    this.dateHistory
    });

  factory LocationChild.fromJson(Map<String, dynamic> json) {
    return LocationChild(
      id: json['_id'] as String?,
      email: json['emailUser'] as String?,
      location: json['location'] as dynamic,
      dateHistory: json['dateTimeHistory'] as String?,
    );
  }
}