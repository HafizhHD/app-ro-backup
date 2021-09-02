import 'package:ruangkeluarga/global/global_formatter.dart';

enum ScheduleType { harian, terjadwal }

class DeviceUsageSchedules {
  final String? id;
  final String? emailUser;
  final ScheduleType scheduleType;
  final String? scheduleName;
  final String? scheduleDescription;
  final String? deviceUsageStartTime;
  final String? deviceUsageEndTime;
  final List<String>? deviceUsageDays;
  final String? status;

  DeviceUsageSchedules(
      {this.id,
      this.emailUser,
      this.scheduleName,
      required this.scheduleType,
      this.scheduleDescription,
      this.deviceUsageStartTime,
      this.deviceUsageEndTime,
      this.deviceUsageDays,
      this.status});

  factory DeviceUsageSchedules.fromJson(Map<String, dynamic> json) {
    try {
      final res = DeviceUsageSchedules(
        id: json['_id'],
        emailUser: json['emailUser'],
        scheduleType: json['scheduleType'] == 'harian' ? ScheduleType.harian : ScheduleType.terjadwal,
        scheduleName: json['scheduleName'],
        scheduleDescription: json['scheduleDescription'],
        deviceUsageStartTime: json['deviceUsageStartTime'],
        deviceUsageEndTime: json['deviceUsageEndTime'],
        deviceUsageDays: List<String>.from(json['deviceUsageDays']),
        status: json['status'][0],
      );
      return res;
    } catch (e, s) {
      print('Error: $e');
      print('StackTrace: $s');

      return DeviceUsageSchedules(scheduleType: ScheduleType.harian);
    }
  }

  Map toJson() {
    return {
      "emailUser": "$emailUser",
      "scheduleType": scheduleType.toEnumString(),
      "scheduleName": "$scheduleName",
      "scheduleDescription": "$scheduleDescription",
      "deviceUsageStartTime": "$deviceUsageStartTime",
      "deviceUsageEndTime": "$deviceUsageEndTime",
      "deviceUsageDays": deviceUsageDays,
      "status": "$status"
    };
  }
}
