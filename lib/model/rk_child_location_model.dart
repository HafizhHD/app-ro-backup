import 'package:ruangkeluarga/global/global_formatter.dart';

class LocationChild {
  // final String id;
  final String email;
  final Location location;
  final String dateHistory;
  final String dateCreate;
  final DateTime createdAt;

  LocationChild({required this.email, required this.location, required this.dateHistory, required this.dateCreate, required this.createdAt});

  factory LocationChild.fromJson(Map<String, dynamic> json) {
    return LocationChild(
      // id: json['_id'],
      email: json['emailUser'],
      location: Location.fromJson(json['location']),
      dateHistory: json['dateTimeHistory'],
      dateCreate: strToDate_EddMMMyyyyHHmm(json['dateCreate']),
      createdAt: DateTime.parse(json['dateCreate']),
    );
  }
}

class Location {
  final String place;
  final String type;
  final List coordinates;

  Location({required this.place, required this.type, required this.coordinates});

  Location.fromJson(Map<String, dynamic> json)
      : place = json['place'],
        type = json['type'],
        coordinates = json['coordinates'];
}
