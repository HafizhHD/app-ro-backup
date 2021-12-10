// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/main.dart';
import 'package:ruangkeluarga/model/content_aplikasi_data_usage.dart';
import 'package:ruangkeluarga/utils/app_usage.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:system_alert_window/system_alert_window.dart';

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
  static bool _isShowingWindow = false;
  static bool _isUpdatedWindow = false;
  static SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;

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

  static Future<void> cekAppLaunch(String deviceAppUsage) async {
    DatabaseReference dbPref = FirebaseDatabase.instance.reference().child("dataAplikasi"+deviceAppUsage.toString());
    dbPref.once().then((DataSnapshot snapshot) async {
      if(snapshot.value != null){
        List<AplikasiDataUsage> values = List<AplikasiDataUsage>.from(snapshot.value.map((x) => AplikasiDataUsage.fromJson(x)));
        List<AplikasiDataUsage> dataTrue = values.where((element) => element.blacklist == 'true' || element.limit != '0').toList();
        if(dataTrue != null && dataTrue.length>0){
          for(var i=0; i<dataTrue.length; i++){
            print("DATA APLIKASI USAGE : "+dataTrue[i].toJson().toString());
          }
          DateTime endDate = new DateTime.now();
          DateTime startPenggunaan = endDate.subtract(Duration(days: 1));
          List<UsageInfo> infoList = await UsageStats.queryUsageStats(startPenggunaan, endDate);
          if(infoList.length>0) {
            infoList.sort((a, b) => a.lastTimeUsed!.compareTo(b.lastTimeUsed!));
            for(var i=0; i<infoList.length; i++){
              for(var j = 0; j<dataTrue.length; j++){
                if(dataTrue[j].packageId == infoList[infoList.length-1].packageName) {
                  print("DATA APLIKASI CURRENT : " + infoList[i].packageName.toString());
                }
              }
            }
            List<AplikasiDataUsage> dataUsage = dataTrue.where((element) => element.packageId == infoList[infoList.length-1].packageName).toList();
            if(dataUsage!= null && dataUsage.length>0){
              if(dataUsage.last.blacklist == 'true'){
                print("BLOCK APP : "+dataUsage.last.toJson().toString());
                _channel.invokeMethod('blockAppAndPackageNow', dataUsage.last.toJson());
                /*SystemAlertWindow.registerOnClickListener(callBackAlert);
                _showOverlayWindow();*/

                // SystemAlertWindow.closeSystemWindow(prefMode: prefMode);
              }else{
                if(int.parse(dataUsage.last.limit.toString()) <
                    ((int.parse(infoList[infoList.length-1].totalTimeInForeground.toString()) / (1000*60)) % 60)){
                  print("BATAS APP : "+dataUsage.last.toJson().toString());
                  _channel.invokeMethod('blockAppAndPackageNow', dataUsage.last.toJson());
                  /*SystemAlertWindow.registerOnClickListener(callBackAlert);
                  _showOverlayWindow();*/
                  // SystemAlertWindow.closeSystemWindow(prefMode: prefMode);
                }
              }
            }
          }


          /*ListAplikasiDataUsage listAplikasiDataUsage = new ListAplikasiDataUsage(data: dataTrue);
          if(Platform.isAndroid) {
            print("Data To Method : "+listAplikasiDataUsage.toJson().toString());
            _channel.invokeMethod('startServiceCheckApp', listAplikasiDataUsage.toJson());
          }*/
        }
      }
    });
  }

  static void _showOverlayWindow() {
    if (!_isShowingWindow) {
      SystemWindowHeader header = SystemWindowHeader(
          title: SystemWindowText(text: "Incoming Call", fontSize: 10, textColor: Colors.black45),
          padding: SystemWindowPadding.setSymmetricPadding(12, 12),
          subTitle: SystemWindowText(text: "9898989899", fontSize: 14, fontWeight: FontWeight.BOLD, textColor: Colors.black87),
          decoration: SystemWindowDecoration(startColor: Colors.grey[100]),
          button: SystemWindowButton(text: SystemWindowText(text: "Personal", fontSize: 10, textColor: Colors.black45), tag: "personal_btn"),
          buttonPosition: ButtonPosition.TRAILING);
      SystemWindowBody body = SystemWindowBody(
        rows: [
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(text: "Some body", fontSize: 12, textColor: Colors.black45),
              ),
            ],
            gravity: ContentGravity.CENTER,
          ),
          EachRow(columns: [
            EachColumn(
                text: SystemWindowText(text: "Long data of the body", fontSize: 12, textColor: Colors.black87, fontWeight: FontWeight.BOLD),
                padding: SystemWindowPadding.setSymmetricPadding(6, 8),
                decoration: SystemWindowDecoration(startColor: Colors.black12, borderRadius: 25.0),
                margin: SystemWindowMargin(top: 4)),
          ], gravity: ContentGravity.CENTER),
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(text: "Notes", fontSize: 10, textColor: Colors.black45),
              ),
            ],
            gravity: ContentGravity.LEFT,
            margin: SystemWindowMargin(top: 8),
          ),
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(text: "Some random notes.", fontSize: 13, textColor: Colors.black54, fontWeight: FontWeight.BOLD),
              ),
            ],
            gravity: ContentGravity.LEFT,
          ),
        ],
        padding: SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
      );
      SystemWindowFooter footer = SystemWindowFooter(
          buttons: [
            SystemWindowButton(
              text: SystemWindowText(text: "Simple button", fontSize: 12, textColor: Color.fromRGBO(250, 139, 97, 1)),
              tag: "simple_button",
              padding: SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
              width: 0,
              height: SystemWindowButton.WRAP_CONTENT,
              decoration: SystemWindowDecoration(startColor: Colors.white, endColor: Colors.white, borderWidth: 0, borderRadius: 0.0),
            ),
            SystemWindowButton(
              text: SystemWindowText(text: "Focus button", fontSize: 12, textColor: Colors.white),
              tag: "focus_button",
              width: 0,
              padding: SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
              height: SystemWindowButton.WRAP_CONTENT,
              decoration: SystemWindowDecoration(
                  startColor: Color.fromRGBO(250, 139, 97, 1), endColor: Color.fromRGBO(247, 28, 88, 1), borderWidth: 0, borderRadius: 30.0),
            )
          ],
          padding: SystemWindowPadding(left: 16, right: 16, bottom: 12),
          decoration: SystemWindowDecoration(startColor: Colors.white),
          buttonsPosition: ButtonPosition.CENTER);
      SystemAlertWindow.showSystemWindow(
          height: 230,
          header: header,
          body: body,
          footer: footer,
          margin: SystemWindowMargin(left: 8, right: 8, top: 200, bottom: 0),
          gravity: SystemWindowGravity.TOP,
          notificationTitle: "Incoming Call",
          notificationBody: "+1 646 980 4741",
          prefMode: prefMode
      );
      _isShowingWindow = true;
    } else if (!_isUpdatedWindow) {
      SystemWindowHeader header = SystemWindowHeader(
          title: SystemWindowText(text: "Outgoing Call", fontSize: 10, textColor: Colors.black45),
          padding: SystemWindowPadding.setSymmetricPadding(12, 12),
          subTitle: SystemWindowText(text: "8989898989", fontSize: 14, fontWeight: FontWeight.BOLD, textColor: Colors.black87),
          decoration: SystemWindowDecoration(startColor: Colors.grey[100]),
          button: SystemWindowButton(text: SystemWindowText(text: "Personal", fontSize: 10, textColor: Colors.black45), tag: "personal_btn"),
          buttonPosition: ButtonPosition.TRAILING);
      SystemWindowBody body = SystemWindowBody(
        rows: [
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(text: "Updated body", fontSize: 12, textColor: Colors.black45),
              ),
            ],
            gravity: ContentGravity.CENTER,
          ),
          EachRow(columns: [
            EachColumn(
                text: SystemWindowText(text: "Updated long data of the body", fontSize: 12, textColor: Colors.black87, fontWeight: FontWeight.BOLD),
                padding: SystemWindowPadding.setSymmetricPadding(6, 8),
                decoration: SystemWindowDecoration(startColor: Colors.black12, borderRadius: 25.0),
                margin: SystemWindowMargin(top: 4)),
          ], gravity: ContentGravity.CENTER),
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(text: "Notes", fontSize: 10, textColor: Colors.black45),
              ),
            ],
            gravity: ContentGravity.LEFT,
            margin: SystemWindowMargin(top: 8),
          ),
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(text: "Updated random notes.", fontSize: 13, textColor: Colors.black54, fontWeight: FontWeight.BOLD),
              ),
            ],
            gravity: ContentGravity.LEFT,
          ),
        ],
        padding: SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
      );
      SystemWindowFooter footer = SystemWindowFooter(
          buttons: [
            SystemWindowButton(
              text: SystemWindowText(text: "Updated Simple button", fontSize: 12, textColor: Color.fromRGBO(250, 139, 97, 1)),
              tag: "updated_simple_button",
              padding: SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
              width: 0,
              height: SystemWindowButton.WRAP_CONTENT,
              decoration: SystemWindowDecoration(startColor: Colors.white, endColor: Colors.white, borderWidth: 0, borderRadius: 0.0),
            ),
            SystemWindowButton(
              text: SystemWindowText(text: "Focus button", fontSize: 12, textColor: Colors.white),
              tag: "focus_button",
              width: 0,
              padding: SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
              height: SystemWindowButton.WRAP_CONTENT,
              decoration: SystemWindowDecoration(
                  startColor: Color.fromRGBO(250, 139, 97, 1), endColor: Color.fromRGBO(247, 28, 88, 1), borderWidth: 0, borderRadius: 30.0),
            )
          ],
          padding: SystemWindowPadding(left: 16, right: 16, bottom: 12),
          decoration: SystemWindowDecoration(startColor: Colors.white),
          buttonsPosition: ButtonPosition.CENTER);
      SystemAlertWindow.updateSystemWindow(
          height: 230,
          header: header,
          body: body,
          footer: footer,
          margin: SystemWindowMargin(left: 8, right: 8, top: 200, bottom: 0),
          gravity: SystemWindowGravity.TOP,
          notificationTitle: "Outgoing Call",
          notificationBody: "+1 646 980 4741",
          prefMode: prefMode);
      _isUpdatedWindow = true;
    } else {
      _isShowingWindow = false;
      _isUpdatedWindow = false;
      SystemAlertWindow.closeSystemWindow(prefMode: prefMode);
    }
  }
}
