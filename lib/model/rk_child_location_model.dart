import 'package:ruangkeluarga/global/global_formatter.dart';

class LocationChild {
  // final String id;
  final String email;
  final LocationModel location;
  final String dateHistory;
  final String dateCreate;
  final DateTime createdAt;

  LocationChild({required this.email, required this.location, required this.dateHistory, required this.dateCreate, required this.createdAt});

  factory LocationChild.fromJson(Map<String, dynamic> json) {
    String tglHistory = strToDate_EddMMMyyyyHHmm(json['dateTimeHistory']);
    if (json['dateUntil'] != null) {
      DateTime dateUntil = DateTime.parse(json['dateUntil']).toUtc().toLocal();
      dateUntil.add(const Duration(hours: 7));
      tglHistory =
          tglHistory + ' - \n' + strToDate_EddMMMyyyyHHmm(dateUntil.toIso8601String());
    }

    return LocationChild(
      // id: json['_id'],
      email: json['emailUser'],
      location: LocationModel.fromJson(json['location']),
      // dateHistory: strToEDMYHourOnly(json['dateTimeHistory']),
      dateHistory: tglHistory,
      dateCreate: strToDate_EddMMMyyyyHHmm(json['dateCreate']),
      createdAt: DateTime.parse(json['dateCreate']).toUtc().toLocal(),
    );
  }
}

class LocationModel {
  final String place;
  final String type;
  final List coordinates;

  LocationModel({required this.place, required this.type, required this.coordinates});

  LocationModel.fromJson(Map<String, dynamic> json)
      : place = json['place'],
        type = json['type'],
        coordinates = json['coordinates'];
}
