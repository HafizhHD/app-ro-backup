// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'package:ruangkeluarga/child/child_controller.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/main.dart';
import 'package:ruangkeluarga/model/content_aplikasi_data_usage.dart';
import 'package:ruangkeluarga/model/rk_schedule_model.dart';
import 'package:ruangkeluarga/utils/app_usage.dart';
import 'package:ruangkeluarga/utils/database/aplikasiDb.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usage_stats/usage_stats.dart';

const String _backgroundName =
    'com.ruangkeluargamobile/android_service_background';

// This is the entrypoint for the background isolate. Since we can only enter
// an isolate once, we setup a MethodChannel to listen for method invocations
// from the native portion of the plugin. This allows for the plugin to perform
// any necessary processing in Dart (e.g., populating a custom object) before
// invoking the provided callback.
void _alarmManagerCallbackDispatcher() {
  // Initialize state necessary for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  const _channel = MethodChannel(_backgroundName, JSONMethodCodec());
  // This is where the magic happens and we handle background events from the
  // native portion of the plugin.
  _channel.setMethodCallHandler((MethodCall call) async {
    final dynamic args = call.arguments;
    final handle = CallbackHandle.fromRawHandle(args[0]);

    // PluginUtilities.getCallbackFromHandle performs a lookup based on the
    // callback handle and returns a tear-off of the original callback.
    final closure = PluginUtilities.getCallbackFromHandle(handle);

    if (closure == null) {
      developer.log('Fatal: could not find callback');
      exit(-1);
    }

    // ignore: inference_failure_on_function_return_type
    if (closure is Function()) {
      closure();
      // ignore: inference_failure_on_function_return_type
    } else if (closure is Function(int)) {
      final int id = args[1];
      closure(id);
    }
  });

  // Once we've finished initializing, let the native portion of the plugin
  // know that it can start scheduling alarms.
  _channel.invokeMethod<void>('AlarmService.initialized');
}

// A lambda that returns the current instant in the form of a [DateTime].
typedef _Now = DateTime Function();
// A lambda that gets the handle for the given [callback].
typedef _GetCallbackHandle = CallbackHandle? Function(Function callback);

/// A Flutter plugin for registering Dart callbacks with the Android
/// AlarmManager service.
///
/// See the example/ directory in this package for sample usage.
class BackgroundServiceNew {
  static const String _channelName =
      'com.ruangkeluargamobile/android_service_background';
  static const MethodChannel _channel =
      MethodChannel(_channelName, JSONMethodCodec());
  /*static bool _isShowingWindow = false;
  static bool _isUpdatedWindow = false;
  static SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;*/

  // Function used to get the current time. It's [DateTime.now] by default.
  // ignore: prefer_function_declarations_over_variables
  static _Now _now = () => DateTime.now();

  // Callback used to get the handle for a callback. It's
  // [PluginUtilities.getCallbackHandle] by default.
  // ignore: prefer_function_declarations_over_variables
  static _GetCallbackHandle _getCallbackHandle =
      (Function callback) => PluginUtilities.getCallbackHandle(callback);

  /// This is exposed for the unit tests. It should not be accessed by users of
  /// the plugin.
  @visibleForTesting
  static void setTestOverrides({
    _Now? now,
    _GetCallbackHandle? getCallbackHandle,
  }) {
    _now = (now ?? _now);
    _getCallbackHandle = (getCallbackHandle ?? _getCallbackHandle);
  }

  /// Starts the [AndroidAlarmManager] service. This must be called before
  /// setting any alarms.
  ///
  /// Returns a [Future] that resolves to `true` on success and `false` on
  /// failure.
  static Future<bool> initialize() async {
    final handle = _getCallbackHandle(_alarmManagerCallbackDispatcher);
    if (handle == null) {
      return false;
    }
    final r = await _channel.invokeMethod<bool>(
        'AlarmService.start', <dynamic>[handle.toRawHandle()]);
    return r ?? false;
  }

  /// Schedules a one-shot timer to run `callback` after time `delay`.
  ///
  /// The `callback` will run whether or not the main application is running or
  /// in the foreground. It will run in the Isolate owned by the
  /// AndroidAlarmManager service.
  ///
  /// `callback` must be either a top-level function or a static method from a
  /// class.
  ///
  /// `callback` can be `Function()` or `Function(int)`
  ///
  /// The timer is uniquely identified by `id`. Calling this function again
  /// with the same `id` will cancel and replace the existing timer.
  ///
  /// `id` will passed to `callback` if it is of type `Function(int)`
  ///
  /// If `alarmClock` is passed as `true`, the timer will be created with
  /// Android's `AlarmManagerCompat.setAlarmClock`.
  ///
  /// If `allowWhileIdle` is passed as `true`, the timer will be created with
  /// Android's `AlarmManagerCompat.setExactAndAllowWhileIdle` or
  /// `AlarmManagerCompat.setAndAllowWhileIdle`.
  ///
  /// If `exact` is passed as `true`, the timer will be created with Android's
  /// `AlarmManagerCompat.setExact`. When `exact` is `false` (the default), the
  /// timer will be created with `AlarmManager.set`.
  /// For apps with `targetSDK=31` before scheduling an exact alarm a check for
  /// `SCHEDULE_EXACT_ALARM` permission is required. Otherwise, an exeption will
  /// be thrown and alarm won't schedule.
  ///
  /// If `wakeup` is passed as `true`, the device will be woken up when the
  /// alarm fires. If `wakeup` is false (the default), the device will not be
  /// woken up to service the alarm.
  ///
  /// If `rescheduleOnReboot` is passed as `true`, the alarm will be persisted
  /// across reboots. If `rescheduleOnReboot` is false (the default), the alarm
  /// will not be rescheduled after a reboot and will not be executed.
  ///
  /// Returns a [Future] that resolves to `true` on success and `false` on
  /// failure.
  static Future<bool> oneShot(
    Duration delay,
    int id,
    Function callback, {
    bool alarmClock = false,
    bool allowWhileIdle = false,
    bool exact = false,
    bool wakeup = false,
    bool rescheduleOnReboot = false,
  }) =>
      oneShotAt(
        _now().add(delay),
        id,
        callback,
        alarmClock: alarmClock,
        allowWhileIdle: allowWhileIdle,
        exact: exact,
        wakeup: wakeup,
        rescheduleOnReboot: rescheduleOnReboot,
      );

  /// Schedules a one-shot timer to run `callback` at `time`.
  ///
  /// The `callback` will run whether or not the main application is running or
  /// in the foreground. It will run in the Isolate owned by the
  /// AndroidAlarmManager service.
  ///
  /// `callback` must be either a top-level function or a static method from a
  /// class.
  ///
  /// `callback` can be `Function()` or `Function(int)`
  ///
  /// The timer is uniquely identified by `id`. Calling this function again
  /// with the same `id` will cancel and replace the existing timer.
  ///
  /// `id` will passed to `callback` if it is of type `Function(int)`
  ///
  /// If `alarmClock` is passed as `true`, the timer will be created with
  /// Android's `AlarmManagerCompat.setAlarmClock`.
  ///
  /// If `allowWhileIdle` is passed as `true`, the timer will be created with
  /// Android's `AlarmManagerCompat.setExactAndAllowWhileIdle` or
  /// `AlarmManagerCompat.setAndAllowWhileIdle`.
  ///
  /// If `exact` is passed as `true`, the timer will be created with Android's
  /// `AlarmManagerCompat.setExact`. When `exact` is `false` (the default), the
  /// timer will be created with `AlarmManager.set`.
  /// For apps with `targetSDK=31` before scheduling an exact alarm a check for
  /// `SCHEDULE_EXACT_ALARM` permission is required. Otherwise, an exeption will
  /// be thrown and alarm won't schedule.
  ///
  /// If `wakeup` is passed as `true`, the device will be woken up when the
  /// alarm fires. If `wakeup` is false (the default), the device will not be
  /// woken up to service the alarm.
  ///
  /// If `rescheduleOnReboot` is passed as `true`, the alarm will be persisted
  /// across reboots. If `rescheduleOnReboot` is false (the default), the alarm
  /// will not be rescheduled after a reboot and will not be executed.
  ///
  /// Returns a [Future] that resolves to `true` on success and `false` on
  /// failure.
  static Future<bool> oneShotAt(
    DateTime time,
    int id,
    Function callback, {
    bool alarmClock = false,
    bool allowWhileIdle = false,
    bool exact = false,
    bool wakeup = false,
    bool rescheduleOnReboot = false,
  }) async {
    // ignore: inference_failure_on_function_return_type
    assert(callback is Function() || callback is Function(int));
    assert(id.bitLength < 32);
    final startMillis = time.millisecondsSinceEpoch;
    final handle = _getCallbackHandle(callback);
    if (handle == null) {
      return false;
    }
    final r = await _channel.invokeMethod<bool>('Alarm.oneShotAt', <dynamic>[
      id,
      alarmClock,
      allowWhileIdle,
      exact,
      wakeup,
      startMillis,
      rescheduleOnReboot,
      handle.toRawHandle(),
    ]);
    return (r == null) ? false : r;
  }

  /// Schedules a repeating timer to run `callback` with period `duration`.
  ///
  /// The `callback` will run whether or not the main application is running or
  /// in the foreground. It will run in the Isolate owned by the
  /// AndroidAlarmManager service.
  ///
  /// `callback` must be either a top-level function or a static method from a
  /// class.
  ///
  /// `callback` can be `Function()` or `Function(int)`
  ///
  /// The repeating timer is uniquely identified by `id`. Calling this function
  /// again with the same `id` will cancel and replace the existing timer.
  ///
  /// `id` will passed to `callback` if it is of type `Function(int)`
  ///
  /// If `startAt` is passed, the timer will first go off at that time and
  /// subsequently run with period `duration`.
  ///
  /// If `allowWhileIdle` is passed as `true`, the timer will be created with
  /// Android's `AlarmManagerCompat.setExactAndAllowWhileIdle` or
  /// `AlarmManagerCompat.setAndAllowWhileIdle`.
  ///
  /// If `exact` is passed as `true`, the timer will be created with Android's
  /// `AlarmManager.setRepeating`. When `exact` is `false` (the default), the
  /// timer will be created with `AlarmManager.setInexactRepeating`.
  /// For apps with `targetSDK=31` before scheduling an exact alarm a check for
  /// `SCHEDULE_EXACT_ALARM` permission is required. Otherwise, an exeption will
  /// be thrown and alarm won't schedule.
  ///
  /// If `wakeup` is passed as `true`, the device will be woken up when the
  /// alarm fires. If `wakeup` is false (the default), the device will not be
  /// woken up to service the alarm.
  ///
  /// If `rescheduleOnReboot` is passed as `true`, the alarm will be persisted
  /// across reboots. If `rescheduleOnReboot` is false (the default), the alarm
  /// will not be rescheduled after a reboot and will not be executed.
  ///
  /// Returns a [Future] that resolves to `true` on success and `false` on
  /// failure.
  static Future<bool> periodic(
    Duration duration,
    int id,
    Function callback, {
    DateTime? startAt,
    bool allowWhileIdle = false,
    bool exact = false,
    bool wakeup = false,
    bool rescheduleOnReboot = false,
  }) async {
    // ignore: inference_failure_on_function_return_type
    assert(callback is Function() || callback is Function(int));
    assert(id.bitLength < 32);
    final now = _now().millisecondsSinceEpoch;
    final period = duration.inMilliseconds;
    final first =
        startAt != null ? startAt.millisecondsSinceEpoch : now + period;
    final handle = _getCallbackHandle(callback);
    if (handle == null) {
      return false;
    }
    final r = await _channel.invokeMethod<bool>('Alarm.periodic', <dynamic>[
      id,
      allowWhileIdle,
      exact,
      wakeup,
      first,
      period,
      rescheduleOnReboot,
      handle.toRawHandle()
    ]);
    return (r == null) ? false : r;
  }

  /// Cancels a timer.
  ///
  /// If a timer has been scheduled with `id`, then this function will cancel
  /// it.
  ///
  /// Returns a [Future] that resolves to `true` on success and `false` on
  /// failure.
  static Future<bool> cancel(int id) async {
    final r = await _channel.invokeMethod<bool>('Alarm.cancel', <dynamic>[id]);
    return (r == null) ? false : r;
  }

  static Future<void> cekAppLaunch(currentApp) async {
    try {
      print("cekAppLaunch..");
      if (await AplikasiDB.instance.checkDataAplikasi()) {
        var dataAplikasiDb = await AplikasiDB.instance.queryAllRowsAplikasi();
        // print("dataAplikasiDb : " + dataAplikasiDb.toString());
        // print("dataAplikasiDb..");
        if (dataAplikasiDb != null) {
          bool checkBlockApps = false;
          bool checkSchedule = false;
          //jika lock membahayakan hidde source dibawah ini sampai if selanjutnya
          if (dataAplikasiDb['modekunciLayar'] != null &&
              dataAplikasiDb['modekunciLayar'] == 'true') {
            print('mode kunci layar = ' + dataAplikasiDb['modekunciLayar']);
            new MethodChannel(
                    'com.ruangkeluargamobile/android_service_background',
                    JSONMethodCodec())
                .invokeMethod('lockDeviceChils', {'data': 'data'});
          } else if (dataAplikasiDb['kunciLayar'] != null) {
            List<dynamic> res =
                jsonDecode(dataAplikasiDb['kunciLayar']).map((e) => e).toList();
            if (res.length > 0) {
              bool cekScheduleLayar = false;
              for (var i = 0; i < res.length; i++) {
                DeviceUsageSchedules dataUsage =
                    DeviceUsageSchedules.fromJson(res[i]);
                if (dataUsage.status.toString().toLowerCase() == 'aktif') {
                  if (dataUsage.scheduleType == ScheduleType.harian) {
                    var ss = dataUsage.deviceUsageDays!.where(
                        (element) => element.toString() == dateFormat_EEEE());
                    int ad = dataUsage.deviceUsageDays!.indexWhere(
                        (element) => element.toString() == dateFormat_EEEE());
                    if ((ss.length > 0) || (ad > 0)) {
                      print("jadwal harian ada");
                      String deviceUsageDays = dataUsage.deviceUsageDays!
                          .where((element) =>
                              element.toString() == dateFormat_EEEE())
                          .last;
                      if (deviceUsageDays != null) {
                        if (dataUsage.deviceUsageStartTime != null &&
                            dataUsage.deviceUsageEndTime != null) {
                          final format = new DateFormat("yyyy-MM-dd HH:mm");
                          DateTime startTime = format.parse(
                              DateFormat("yyyy-MM-dd")
                                      .format(DateTime.now())
                                      .toString() +
                                  ' ' +
                                  dataUsage.deviceUsageStartTime.toString());
                          DateTime endTime = format.parse(
                              DateFormat("yyyy-MM-dd")
                                      .format(DateTime.now())
                                      .toString() +
                                  ' ' +
                                  dataUsage.deviceUsageEndTime.toString());
                          DateTime now =
                              format.parse(format.format(DateTime.now()));
                          if (now.isAfter(startTime) && now.isBefore(endTime)) {
                            print("LOCK LAYAR HARIAN : " + now.toString());
                            cekScheduleLayar = true;
                            checkSchedule = true;
                          }
                        }
                      }
                    } else {
                      // print("jadwal harian tidak ada " +
                      //     ad.toString() +
                      //     "  ss =" +
                      //     ss.toString());
                    }
                  } else if (dataUsage.scheduleType == ScheduleType.terjadwal) {
                    if (dataUsage.deviceUsageStartTime != null &&
                        dataUsage.deviceUsageEndTime != null) {
                      try {
                        final format = new DateFormat("dd MMMM yyyy HH:mm");
                        DateTime startTime = format.parse(
                            dataUsage.deviceUsageStartTime!.split(',  ')[1]);
                        DateTime endTime = format.parse(
                            dataUsage.deviceUsageEndTime!.split(',  ')[1]);
                        DateTime now =
                            format.parse(format.format(DateTime.now()));
                        if (now.isAfter(startTime) && now.isBefore(endTime)) {
                          print("LOCK LAYAR SCHEDULE : " + now.toString());
                          cekScheduleLayar = true;
                          checkSchedule = true;
                        }
                      } catch (e) {}
                    }
                  }
                }
              }
              if (cekScheduleLayar) {
                new MethodChannel(
                        'com.ruangkeluargamobile/android_service_background',
                        JSONMethodCodec())
                    .invokeMethod('lockDeviceChils', {'data': 'data'});
              } else {
                if (dataAplikasiDb['dataAplikasi'] != null) {
                  List<AplikasiDataUsage> values = List<AplikasiDataUsage>.from(
                      jsonDecode(dataAplikasiDb['dataAplikasi'])
                          .map((x) => AplikasiDataUsage.fromJson(x)));
                  List<AplikasiDataUsage> dataTrue = values
                      .where((element) =>
                          element.blacklist == 'true' || element.limit != '0')
                      .toList();
                  if (dataTrue != null && dataTrue.length > 0) {
                    checkBlockApps = true;
                    ListAplikasiDataUsage listAplikasiDataUsage =
                        new ListAplikasiDataUsage(data: dataTrue);
                    if (Platform.isAndroid) {
                      // print("Data To Methodx: " + listAplikasiDataUsage.toJson().toString());
                      Map<String, dynamic> data =
                          listAplikasiDataUsage.toJson();
                      data['currentApp'] = currentApp;
                      _channel.invokeMethod('startServiceCheckApp', data);
                    }
                  }
                }
              }
            } else if (dataAplikasiDb['dataAplikasi'] != null) {
              List<AplikasiDataUsage> values = List<AplikasiDataUsage>.from(
                  jsonDecode(dataAplikasiDb['dataAplikasi'])
                      .map((x) => AplikasiDataUsage.fromJson(x)));
              List<AplikasiDataUsage> dataTrue = values
                  .where((element) =>
                      element.blacklist == 'true' || element.limit != '0')
                  .toList();
              if (dataTrue != null && dataTrue.length > 0) {
                checkBlockApps = true;
                ListAplikasiDataUsage listAplikasiDataUsage =
                    new ListAplikasiDataUsage(data: dataTrue);
                if (Platform.isAndroid) {
                  Map<String, dynamic> data = listAplikasiDataUsage.toJson();
                  data['currentApp'] = currentApp;
                  // print("Data To Method : " + data.toString());
                  _channel.invokeMethod('startServiceCheckApp', data);
                }
              }
            }
          } else if (dataAplikasiDb['dataAplikasi'] != null) {
            List<AplikasiDataUsage> values = List<AplikasiDataUsage>.from(
                jsonDecode(dataAplikasiDb['dataAplikasi'])
                    .map((x) => AplikasiDataUsage.fromJson(x)));
            List<AplikasiDataUsage> dataTrue = values
                .where((element) =>
                    element.blacklist == 'true' || element.limit != '0')
                .toList();
            if (dataTrue != null && dataTrue.length > 0) {
              checkBlockApps = true;
              ListAplikasiDataUsage listAplikasiDataUsage =
                  new ListAplikasiDataUsage(data: dataTrue);
              if (Platform.isAndroid) {
                // print("Data To Method : " + listAplikasiDataUsage.toJson().toString());
                Map<String, dynamic> data = listAplikasiDataUsage.toJson();
                data['currentApp'] = currentApp;
                _channel.invokeMethod('startServiceCheckApp', data);
              }
            }
          }
          if (dataAplikasiDb['modekunciLayar'] == null &&
              dataAplikasiDb['kunciLayar'] == null &&
              !checkSchedule &&
              !checkBlockApps) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String parentEmails = await prefs.getString('parentEmails') ?? '';
            String childName = await prefs.getString('rkFullName') ?? '';
            Response response = await MediaRepository().sendNotification(
                parentEmails,
                "Anda Belum melakukan kontrol pada Perangkat Anak",
                "Papa Mama, saat ini anda masih belum melakukan pengaturan atau kontrol terhadap perangkat anak Anda, $childName. Gunakan fitur Mode Asuh Instant untuk mengontrol perangkat anak anda secara mudah & cepat.");
            if (response.statusCode == 200) {
              // print('save appList ${response.body}');
              print('kirim new app notification ok ${response.body}');
            } else {
              print('gagal kirim notifikasi ${response.statusCode}');
            }
          }
        }
      }
    } catch (e) {
      print('error cekAppLaunch: ' + e.toString());
    } finally {
      /* CEK WAKTU SHOLAT */

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int asiaSholatSekarang = await prefs.getInt('asiaSholatSekarang') ?? 0;
      List<String> asiaSholat = await prefs.getStringList('asiaSholat') ?? [];
      DateTime today = DateTime.now();
      String clockTime = DateFormat.Hm().format(today);
      print('clocktime: $clockTime');
      print('try waktu sholat');
      for (int i = 1; i < asiaSholat.length; i++) {
        if (asiaSholat[i] == clockTime) {
          print('saatnya waktu sholat');
          String childEmail = await prefs.getString(rkEmailUser) ?? '';
          String parentEmail = await prefs.getString('parentEmails') ?? '';
          String allEmails = childEmail + ',' + parentEmail;
          String waktuSholat = i == 1
              ? 'Subuh'
              : i == 2
                  ? 'Dzuhur'
                  : i == 3
                      ? 'Asar'
                      : i == 4
                          ? 'Maghrib'
                          : 'Isya';
          if (asiaSholatSekarang != i) {
            Response response = await MediaRepository().sendNotification(
                allEmails,
                "Waktu Sholat $waktuSholat Sudah Tiba",
                "Sudah masuk waktu sholat $waktuSholat nih. Yuk segera laksanakan sholat.");
            if (response.statusCode == 200) {
              // print('save appList ${response.body}');
              print('kirim new app notification ok ${response.body}');
              await prefs.setInt('asiaSholatSekarang', i);
              break;
            } else {
              print('gagal kirim notifikasi ${response.statusCode}');
              break;
            }
          }
        }
      }
    }
  }
}
