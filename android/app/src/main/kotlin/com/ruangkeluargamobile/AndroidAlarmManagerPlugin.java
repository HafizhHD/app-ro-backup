// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.ruangkeluargamobile;

import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.util.Log;
import java.util.Iterator;
import java.net.HttpURLConnection;
import java.net.URL;
import java.io.DataOutputStream;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.FlutterNativeView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import static com.ruangkeluargamobile.AlarmService.blockAppAndPackageNow;
import static com.ruangkeluargamobile.AlarmService.closeApps;
import static com.ruangkeluargamobile.AlarmService.getForegroundApplication;

/**
 * Flutter plugin for running one-shot and periodic tasks sometime in the future on Android.
 *
 * <p>Plugin initialization goes through these steps:
 *
 * <ol>
 *   <li>Flutter app instructs this plugin to initialize() on the Dart side.
 *   <li>The Dart side of this plugin sends the Android side a "AlarmService.start" message, along
 *       with a Dart callback handle for a Dart callback that should be immediately invoked by a
 *       background Dart isolate.
 *   <li>The Android side of this plugin spins up a background {@link FlutterNativeView}, which
 *       includes a background Dart isolate.
 *   <li>The Android side of this plugin instructs the new background Dart isolate to execute the
 *       callback that was received in the "AlarmService.start" message.
 *   <li>The Dart side of this plugin, running within the new background isolate, executes the
 *       designated callback. This callback prepares the background isolate to then execute any
 *       given Dart callback from that point forward. Thus, at this moment the plugin is fully
 *       initialized and ready to execute arbitrary Dart tasks in the background. The Dart side of
 *       this plugin sends the Android side a "AlarmService.initialized" message to signify that the
 *       Dart is ready to execute tasks.
 * </ol>
 */
public class AndroidAlarmManagerPlugin implements FlutterPlugin, MethodCallHandler {
  private static final String TAG = "AndroidAlarmManagerPlugin";
  private Context context;
  private final Object initializationLock = new Object();
  private MethodChannel alarmManagerPluginChannel;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
  }

  public void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
    synchronized (initializationLock) {
      if (alarmManagerPluginChannel != null) {
        return;
      }

      Log.i(TAG, "onAttachedToEngine");
      this.context = applicationContext;

      // alarmManagerPluginChannel is the channel responsible for receiving the following messages
      // from the main Flutter app:
      // - "AlarmService.start"
      // - "Alarm.oneShotAt"
      // - "Alarm.periodic"
      // - "Alarm.cancel"
      alarmManagerPluginChannel =
          new MethodChannel(
              messenger,
              "com.ruangkeluargamobile/android_service_background",
              JSONMethodCodec.INSTANCE);

      // Instantiate a new AndroidAlarmManagerPlugin and connect the primary method channel for
      // Android/Flutter communication.
      alarmManagerPluginChannel.setMethodCallHandler(this);
    }
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    Log.i(TAG, "onDetachedFromEngine");
    context = null;
    alarmManagerPluginChannel.setMethodCallHandler(null);
    alarmManagerPluginChannel = null;
  }

  public AndroidAlarmManagerPlugin() {}

  /** Invoked when the Flutter side of this plugin sends a message to the Android side. */
  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String method = call.method;
    Object arguments = call.arguments;
    try {
      switch (method) {
        case "AlarmService.start":
          // This message is sent when the Dart side of this plugin is told to initialize.
          long callbackHandle = ((JSONArray) arguments).getLong(0);
          // In response, this (native) side of the plugin needs to spin up a background
          // Dart isolate by using the given callbackHandle, and then setup a background
          // method channel to communicate with the new background isolate. Once completed,
          // this onMethodCall() method will receive messages from both the primary and background
          // method channels.
          AlarmService.setCallbackDispatcher(context, callbackHandle);
          AlarmService.startBackgroundIsolate(context, callbackHandle);
          result.success(true);
          break;
        case "Alarm.periodic":
          // This message indicates that the Flutter app would like to schedule a periodic
          // task.
          PeriodicRequest periodicRequest = PeriodicRequest.fromJson((JSONArray) arguments);
          AlarmService.setPeriodic(context, periodicRequest);
          result.success(true);
          break;
        case "Alarm.oneShotAt":
          // This message indicates that the Flutter app would like to schedule a one-time
          // task.
          OneShotRequest oneShotRequest = OneShotRequest.fromJson((JSONArray) arguments);
          AlarmService.setOneShot(context, oneShotRequest);
          result.success(true);
          break;
        case "Alarm.cancel":
          // This message indicates that the Flutter app would like to cancel a previously
          // scheduled task.
          int requestCode = ((JSONArray) arguments).getInt(0);
          AlarmService.cancel(context, requestCode);
          result.success(true);
          break;
        case "startServiceCheckApp":
          try {
            JSONObject checkAppLoad = (JSONObject) arguments;
            JSONArray jsonArray = new JSONArray(checkAppLoad.getString("data"));
            Double duration = 0.0;
            if(jsonArray.length()>0){
              if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                ModelKillAplikasi appForeground = getForegroundApplication(context);
                String currentAppId = "";
                if (checkAppLoad.has("currentApp") && !checkAppLoad.isNull("currentApp")) {
                  JSONObject currentApp = checkAppLoad.getJSONObject("currentApp");
                  Iterator<?> keys = currentApp.keys();
                  while( keys.hasNext() ) {
                    String key = (String) keys.next();
                    currentAppId = key;
                    duration = currentApp.getDouble(currentAppId) / 60000;
                  }
                }
                // if(appForeground != null){
                if (currentAppId != "") {
                  System.out.println("APLIKASI CURRENT : "+ currentAppId);
                  System.out.println("PENGGUNAAN : "+ duration.toString());
                  if(!appForeground.getPackageId().equals("com.byasia.ruangortu")){
                  // if(currentAppId != "com.byasia.ruangortu"){
                    for(int i = 0; i<jsonArray.length(); i++){
                      JSONObject jsonObject = jsonArray.getJSONObject(i);
                      System.out.println("cek dengan app:" + jsonObject.getString("packageId"));
                      // if (appForeground.getPackageId().equals(jsonObject.getString("packageId"))) {
                      if (currentAppId.equals(jsonObject.getString("packageId"))) {
                        System.out.println("PACKAGE FOREGROUND : "+ currentAppId);
                        System.out.println("TIME FOREGROUND : "+ duration.toString());
                        if(jsonObject.getString("blacklist").equals("true")){
                          appForeground.setPackageId(currentAppId);
                          appForeground.setAppName(jsonObject.getString("appName"));
                          appForeground.setBlacklist(jsonObject.getString("blacklist"));
                          closeApps(context, appForeground);
                        }else {
                          if(Double.parseDouble(jsonObject.getString("limit" )) < duration){
                            // if(Double.parseDouble(jsonObject.getString("limit" )) < Double.parseDouble(appForeground.getTimePenggunaan())){
                            appForeground.setPackageId(currentAppId);
                            appForeground.setAppName(jsonObject.getString("appName"));
                            appForeground.setBlacklist(jsonObject.getString("blacklist"));
                            closeApps(context, appForeground);
                          }
                          else if(Double.parseDouble(jsonObject.getString("limit" )) - duration > 29.8 && Double.parseDouble(jsonObject.getString("limit" )) - duration <= 30) {
                            try {
                              URL url = new URL("https://as01.prod.ruangortu.id:8080/api/user/broadcastAdd");
                              HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                              conn.setRequestMethod("POST");
                              conn.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
                              conn.setRequestProperty("Accept","application/json");
                              conn.setDoOutput(true);
                              conn.setDoInput(true);

                              SharedPreferences prefs = context.getSharedPreferences("FlutterSharedPreferences", context.MODE_PRIVATE);
                              String parentEmails = prefs.getString("flutter.parentEmails", "");
                              String childName = prefs.getString("flutter.rkFullName", "");
                              String thisAppName = context.getApplicationInfo().nonLocalizedLabel.toString();
                              String messageContent = "Papa Mama, Saat ini batas waktu penggunaan aplikasi " + jsonObject.getString("appName") + " pada perangkat anak "  + childName + " hanya tinggal 30 menit. Setelah melewati batas waktu tersebut, aplikasi akan terblokir secara otomatis. Gunakan Aplikasi " + thisAppName + " untuk melakukan kontrol & pengawasan pada perangkat anak Anda.";
              
                              JSONObject jsonParam = new JSONObject();
                              jsonParam.put("destination", parentEmails);
                              jsonParam.put("messageSubject", "Batas Penggunaan Aplikasi " + jsonObject.getString("appName") + " Sisa 30 Menit");
                              jsonParam.put("messageContent", messageContent);
                              jsonParam.put("scheduleTime", "");
                              jsonParam.put("mediaType", "Device");
                              jsonParam.put("category", "Informasi");
              
                              Log.i("JSON", jsonParam.toString());
                              DataOutputStream os = new DataOutputStream(conn.getOutputStream());
                              //os.writeBytes(URLEncoder.encode(jsonParam.toString(), "UTF-8"));
                              os.writeBytes(jsonParam.toString());
              
                              os.flush();
                              os.close();
              
                              Log.i("STATUS", String.valueOf(conn.getResponseCode()));
                              Log.i("MSG" , conn.getResponseMessage());
              
                              conn.disconnect();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                          }
                          else if(Double.parseDouble(jsonObject.getString("limit" )) - duration > 59.8 && Double.parseDouble(jsonObject.getString("limit" )) - duration <= 60) {
                            try {
                              URL url = new URL("https://as01.prod.ruangortu.id:8080/api/user/broadcastAdd");
                              HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                              conn.setRequestMethod("POST");
                              conn.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
                              conn.setRequestProperty("Accept","application/json");
                              conn.setDoOutput(true);
                              conn.setDoInput(true);

                              SharedPreferences prefs = context.getSharedPreferences("FlutterSharedPreferences", context.MODE_PRIVATE);
                              String parentEmails = prefs.getString("flutter.parentEmails", "");
                              String childName = prefs.getString("flutter.rkFullName", "");
                              String thisAppName = context.getApplicationInfo().nonLocalizedLabel.toString();
                              String messageContent = "Papa Mama, Saat ini batas waktu penggunaan aplikasi " + jsonObject.getString("appName") + " pada perangkat anak "  + childName + " hanya tinggal 1 jam. Setelah melewati batas waktu tersebut, aplikasi akan terblokir secara otomatis. Gunakan Aplikasi " + thisAppName + " untuk melakukan kontrol & pengawasan pada perangkat anak Anda.";
              
                              JSONObject jsonParam = new JSONObject();
                              jsonParam.put("destination", parentEmails);
                              jsonParam.put("messageSubject", "Batas Penggunaan Aplikasi " + jsonObject.getString("appName") + " Sisa 1 Jam");
                              jsonParam.put("messageContent", messageContent);
                              jsonParam.put("scheduleTime", "");
                              jsonParam.put("mediaType", "Device");
                              jsonParam.put("category", "Informasi");
              
                              Log.i("JSON", jsonParam.toString());
                              DataOutputStream os = new DataOutputStream(conn.getOutputStream());
                              //os.writeBytes(URLEncoder.encode(jsonParam.toString(), "UTF-8"));
                              os.writeBytes(jsonParam.toString());
              
                              os.flush();
                              os.close();
              
                              Log.i("STATUS", String.valueOf(conn.getResponseCode()));
                              Log.i("MSG" , conn.getResponseMessage());
              
                              conn.disconnect();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }catch (Exception e){}
          result.success(true);
          break;
        case "blockAppAndPackageNow":
          JSONObject blockAppAndPackageNow = (JSONObject) arguments;
          ModelKillAplikasi modelKillAplikasi = new ModelKillAplikasi();
          modelKillAplikasi.setAppName(blockAppAndPackageNow.getString("appName"));
          modelKillAplikasi.setPackageId(blockAppAndPackageNow.getString("packageId"));
          modelKillAplikasi.setTimePenggunaan(blockAppAndPackageNow.getString("limit"));
          modelKillAplikasi.setBlacklist(blockAppAndPackageNow.getString("blacklist"));
          blockAppAndPackageNow(context, modelKillAplikasi);
          result.success(true);
          break;
        case "lockDeviceChils":
          try {
            JSONObject dataLock = (JSONObject) arguments;
            DevicePolicyManager deviceManger = (DevicePolicyManager)
                    context.getSystemService(Context.DEVICE_POLICY_SERVICE);
            deviceManger.lockNow();
          }catch (Exception e){}
          result.success(true);
          break;
        case "permissionLockApp":
          MainAplication.getInstance().resultPremission = result;
          JSONObject permissionLock = (JSONObject) arguments;
          MainAplication.getInstance().permissionLockApp();
          break;
        case "getAppUsageInfo":
//                    HashMap<String, Object> map = (HashMap<String, Object>) arguments;
//                    Log.i("MyTag", "map = " + map); // {os=Android}

          JSONObject args = (JSONObject) arguments;
          long start = args.getLong("start");
          long end = args.getLong("end");
          result.success(Stats.getUsageEvents(context, start, end));
          break;
        default:
          result.notImplemented();
          break;
      }
    } catch (PluginRegistrantException | JSONException e) {
      result.success(true);
    }  catch (Exception e){
      result.success(true);
    }
  }

  /** A request to schedule a one-shot Dart task. */
  static final class OneShotRequest {
    static OneShotRequest fromJson(JSONArray json) throws JSONException {
      int requestCode = json.getInt(0);
      boolean alarmClock = json.getBoolean(1);
      boolean allowWhileIdle = json.getBoolean(2);
      boolean exact = json.getBoolean(3);
      boolean wakeup = json.getBoolean(4);
      long startMillis = json.getLong(5);
      boolean rescheduleOnReboot = json.getBoolean(6);
      long callbackHandle = json.getLong(7);

      return new OneShotRequest(
          requestCode,
          alarmClock,
          allowWhileIdle,
          exact,
          wakeup,
          startMillis,
          rescheduleOnReboot,
          callbackHandle);
    }

    final int requestCode;
    final boolean alarmClock;
    final boolean allowWhileIdle;
    final boolean exact;
    final boolean wakeup;
    final long startMillis;
    final boolean rescheduleOnReboot;
    final long callbackHandle;

    OneShotRequest(
        int requestCode,
        boolean alarmClock,
        boolean allowWhileIdle,
        boolean exact,
        boolean wakeup,
        long startMillis,
        boolean rescheduleOnReboot,
        long callbackHandle) {
      this.requestCode = requestCode;
      this.alarmClock = alarmClock;
      this.allowWhileIdle = allowWhileIdle;
      this.exact = exact;
      this.wakeup = wakeup;
      this.startMillis = startMillis;
      this.rescheduleOnReboot = rescheduleOnReboot;
      this.callbackHandle = callbackHandle;
    }
  }

  /** A request to schedule a periodic Dart task. */
  static final class PeriodicRequest {
    static PeriodicRequest fromJson(JSONArray json) throws JSONException {
      int requestCode = json.getInt(0);
      boolean allowWhileIdle = json.getBoolean(1);
      boolean exact = json.getBoolean(2);
      boolean wakeup = json.getBoolean(3);
      long startMillis = json.getLong(4);
      long intervalMillis = json.getLong(5);
      boolean rescheduleOnReboot = json.getBoolean(6);
      long callbackHandle = json.getLong(7);

      return new PeriodicRequest(
          requestCode,
          allowWhileIdle,
          exact,
          wakeup,
          startMillis,
          intervalMillis,
          rescheduleOnReboot,
          callbackHandle);
    }

    final int requestCode;
    final boolean allowWhileIdle;
    final boolean exact;
    final boolean wakeup;
    final long startMillis;
    final long intervalMillis;
    final boolean rescheduleOnReboot;
    final long callbackHandle;

    PeriodicRequest(
        int requestCode,
        boolean allowWhileIdle,
        boolean exact,
        boolean wakeup,
        long startMillis,
        long intervalMillis,
        boolean rescheduleOnReboot,
        long callbackHandle) {
      this.requestCode = requestCode;
      this.allowWhileIdle = allowWhileIdle;
      this.exact = exact;
      this.wakeup = wakeup;
      this.startMillis = startMillis;
      this.intervalMillis = intervalMillis;
      this.rescheduleOnReboot = rescheduleOnReboot;
      this.callbackHandle = callbackHandle;
    }
  }
}
