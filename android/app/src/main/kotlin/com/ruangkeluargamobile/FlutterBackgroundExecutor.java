// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.ruangkeluargamobile;

import android.app.ActivityManager;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.view.FlutterCallbackInformation;
import io.flutter.view.FlutterMain;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicBoolean;

import static com.ruangkeluargamobile.AlarmService.blockAppAndPackageNow;
import static com.ruangkeluargamobile.AlarmService.closeApps;
import static com.ruangkeluargamobile.AlarmService.getForegroundApplication;
import java.util.Iterator;
import io.flutter.embedding.engine.loader.FlutterLoader;

/**
 * An background execution abstraction which handles initializing a background isolate running a
 * callback dispatcher, used to invoke Dart callbacks while backgrounded.
 */
public class FlutterBackgroundExecutor implements MethodCallHandler {
  private static final String TAG = "FlutterBackgroundExecutor";
  private Context context;
  private static final String CALLBACK_HANDLE_KEY = "callback_handle";
  private static PluginRegistrantCallback pluginRegistrantCallback;
  private FlutterLoader backgroundFlutterLoader;
  /**
   * The {@link MethodChannel} that connects the Android side of this plugin with the background
   * Dart isolate that was created by this plugin.
   */
  private MethodChannel backgroundChannel;

  private FlutterEngine backgroundFlutterEngine;

  private final AtomicBoolean isCallbackDispatcherReady = new AtomicBoolean(false);

  /**
   * Sets the {@code PluginRegistrantCallback} used to register plugins with the newly spawned
   * isolate.
   *
   * <p>Note: this is only necessary for applications using the V1 engine embedding API as plugins
   * are automatically registered via reflection in the V2 engine embedding API. If not set, alarm
   * callbacks will not be able to utilize functionality from other plugins.
   */
  public static void setPluginRegistrant(PluginRegistrantCallback callback) {
    pluginRegistrantCallback = callback;
  }

  /**
   * Sets the Dart callback handle for the Dart method that is responsible for initializing the
   * background Dart isolate, preparing it to receive Dart callback tasks requests.
   */
  public static void setCallbackDispatcher(Context context, long callbackHandle) {
    SharedPreferences prefs = context.getSharedPreferences(AlarmService.SHARED_PREFERENCES_KEY, 0);
    prefs.edit().putLong(CALLBACK_HANDLE_KEY, callbackHandle).apply();
  }

  /** Returns true when the background isolate has started and is ready to handle alarms. */
  public boolean isRunning() {
    return isCallbackDispatcherReady.get();
  }

  private void onInitialized() {
    isCallbackDispatcherReady.set(true);
    AlarmService.onInitialized();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String method = call.method;
    Object arguments = call.arguments;
    try {
      if (method.equals("AlarmService.initialized")) {
        // This message is sent by the background method channel as soon as the background isolate
        // is running. From this point forward, the Android side of this plugin can send
        // callback handles through the background method channel, and the Dart side will execute
        // the Dart methods corresponding to those callback handles.
        onInitialized();
        result.success(true);
      }else  if (method.equals("Alarm.periodic")) {
        AndroidAlarmManagerPlugin.PeriodicRequest periodicRequest = AndroidAlarmManagerPlugin.PeriodicRequest.fromJson((JSONArray) arguments);
        AlarmService.setPeriodic(context, periodicRequest);
        result.success(true);
        result.success(true);
      }else  if (method.equals("Alarm.oneShotAt")) {
        AndroidAlarmManagerPlugin.OneShotRequest oneShotRequest = AndroidAlarmManagerPlugin.OneShotRequest.fromJson((JSONArray) arguments);
        AlarmService.setOneShot(context, oneShotRequest);
        result.success(true);
      }else  if (method.equals("Alarm.cancel")) {
        int requestCode = ((JSONArray) arguments).getInt(0);
        AlarmService.cancel(context, requestCode);
        result.success(true);
      }else  if (method.equals("startServiceCheckApp")) {
        try {
          JSONObject checkAppLoad = (JSONObject) arguments;
          JSONArray jsonArray = new JSONArray(checkAppLoad.getString("data"));
          Double duration = 0.0;
          // System.out.println("jsonArray : "+ jsonArray.toString());
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
//                System.out.println("APLIKASI CURRENT : "+ currentAppId);
//                System.out.println("PENGGUNAAN : "+ duration.toString());
                if(!appForeground.getPackageId().equals("com.byasia.ruangortu")){
                // if(currentAppId != "com.byasia.ruangortu") {
                  for(int i = 0; i<jsonArray.length(); i++){
                    JSONObject jsonObject = jsonArray.getJSONObject(i);
                    // System.out.println("cek dengan app:" + jsonObject.getString("packageId"));
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
                      }
                    }
                  }
                }
              }
            }
          }
        }catch (Exception e){System.out.println(e);}
        result.success(true);
      } else  if (method.equals("blockAppAndPackageNow")) {
        JSONObject checkAppLoad = (JSONObject) arguments;
        ModelKillAplikasi modelKillAplikasi = new ModelKillAplikasi();
        modelKillAplikasi.setAppName(checkAppLoad.getString("appName"));
        modelKillAplikasi.setPackageId(checkAppLoad.getString("packageId"));
        modelKillAplikasi.setTimePenggunaan(checkAppLoad.getString("limit"));
        modelKillAplikasi.setBlacklist(checkAppLoad.getString("blacklist"));
        blockAppAndPackageNow(context, modelKillAplikasi);
        result.success(true);
      } else if (method.equals("lockDeviceChils")) {
        try {
          JSONObject dataLock = (JSONObject) arguments;
          DevicePolicyManager deviceManger = (DevicePolicyManager)
                  context.getSystemService(Context.DEVICE_POLICY_SERVICE);
          deviceManger.lockNow();
        }catch (Exception e){System.out.println(e);}
        result.success(true);
      }else if (method.equals("permissionLockApp")) {
        MainAplication.getInstance().resultPremission = result;
        JSONObject permissionLock = (JSONObject) arguments;
        MainAplication.getInstance().permissionLockApp();
      }else if (method.equals("getAppUsageInfo")) {
        JSONObject args = (JSONObject) arguments;
        long start = args.getLong("start");
        long end = args.getLong("end");
        result.success(Stats.getUsageEvents(context, start, end));
      } else {
        result.notImplemented();
      }
    } catch (PluginRegistrantException | JSONException e) {
      System.out.println(e);
      result.success(true);
    } catch (Exception e){
      System.out.println(e);
      result.success(true);
    }
  }

  /**
   * Starts running a background Dart isolate within a new {@link FlutterEngine} using a previously
   * used entrypoint.
   *
   * <p>The isolate is configured as follows:
   *
   * <ul>
   *   <li>Bundle Path: {@code FlutterMain.findAppBundlePath(context)}.
   *   <li>Entrypoint: The Dart method used the last time this plugin was initialized in the
   *       foreground.
   *   <li>Run args: none.
   * </ul>
   *
   * <p>Preconditions:
   *
   * <ul>
   *   <li>The given callback must correspond to a registered Dart callback. If the handle does not
   *       resolve to a Dart callback then this method does nothing.
   *   <li>A static {@link #pluginRegistrantCallback} must exist, otherwise a {@link
   *       PluginRegistrantException} will be thrown.
   * </ul>
   */
  public void startBackgroundIsolate(Context context) {
    if (!isRunning()) {
      SharedPreferences p = context.getSharedPreferences(AlarmService.SHARED_PREFERENCES_KEY, 0);
      long callbackHandle = p.getLong(CALLBACK_HANDLE_KEY, 0);
      startBackgroundIsolate(context, callbackHandle);
    }
  }

  /**
   * Starts running a background Dart isolate within a new {@link FlutterEngine}.
   *
   * <p>The isolate is configured as follows:
   *
   * <ul>
   *   <li>Bundle Path: {@code FlutterMain.findAppBundlePath(context)}.
   *   <li>Entrypoint: The Dart method represented by {@code callbackHandle}.
   *   <li>Run args: none.
   * </ul>
   *
   * <p>Preconditions:
   *
   * <ul>
   *   <li>The given {@code callbackHandle} must correspond to a registered Dart callback. If the
   *       handle does not resolve to a Dart callback then this method does nothing.
   *   <li>A static {@link #pluginRegistrantCallback} must exist, otherwise a {@link
   *       PluginRegistrantException} will be thrown.
   * </ul>
   */
  public void startBackgroundIsolate(Context context, long callbackHandle) {
    if (backgroundFlutterEngine != null) {
      Log.e(TAG, "Background isolate already started");
      return;
    }

    this.context= context;

    Log.i(TAG, "Starting AlarmService...");
    // String appBundlePath = FlutterMain.findAppBundlePath(context);
    if(backgroundFlutterLoader == null) backgroundFlutterLoader = new FlutterLoader();
    if(!backgroundFlutterLoader.initialized()) {
      backgroundFlutterLoader.startInitialization(context);
      backgroundFlutterLoader.ensureInitializationComplete​(context, null);
    }
    String appBundlePath = backgroundFlutterLoader.findAppBundlePath();
    AssetManager assets = context.getAssets();
    if (appBundlePath != null && !isRunning()) {
      backgroundFlutterEngine = new FlutterEngine(context);

      // We need to create an instance of `FlutterEngine` before looking up the
      // callback. If we don't, the callback cache won't be initialized and the
      // lookup will fail.
      FlutterCallbackInformation flutterCallback =
          FlutterCallbackInformation.lookupCallbackInformation(callbackHandle);
      if (flutterCallback == null) {
        Log.e(TAG, "Fatal: failed to find callback");
        return;
      }

      DartExecutor executor = backgroundFlutterEngine.getDartExecutor();
      initializeMethodChannel(executor);
      DartCallback dartCallback = new DartCallback(assets, appBundlePath, flutterCallback);

      executor.executeDartCallback(dartCallback);

      // The pluginRegistrantCallback should only be set in the V1 embedding as
      // plugin registration is done via reflection in the V2 embedding.
      if (pluginRegistrantCallback != null) {
        pluginRegistrantCallback.registerWith(new ShimPluginRegistry(backgroundFlutterEngine));
      }
    }
  }

  /**
   * Executes the desired Dart callback in a background Dart isolate.
   *
   * <p>The given {@code intent} should contain a {@code long} extra called "callbackHandle", which
   * corresponds to a callback registered with the Dart VM.
   */
  public void executeDartCallbackInBackgroundIsolate(Intent intent, final CountDownLatch latch) {
    // Grab the handle for the callback associated with this alarm. Pay close
    // attention to the type of the callback handle as storing this value in a
    // variable of the wrong size will cause the callback lookup to fail.
    long callbackHandle = intent.getLongExtra("callbackHandle", 0);

    // If another thread is waiting, then wake that thread when the callback returns a result.
    Result result = null;
    if (latch != null) {
      result =
          new Result() {
            @Override
            public void success(Object result) {
              latch.countDown();
            }

            @Override
            public void error(String errorCode, String errorMessage, Object errorDetails) {
              latch.countDown();
            }

            @Override
            public void notImplemented() {
              latch.countDown();
            }
          };
    }

    // Handle the alarm event in Dart. Note that for this plugin, we don't
    // care about the method name as we simply lookup and invoke the callback
    // provided.
    backgroundChannel.invokeMethod(
        "invokeAlarmManagerCallback",
        new Object[] {callbackHandle, intent.getIntExtra("id", -1)},
        result);
  }

  private void initializeMethodChannel(BinaryMessenger isolate) {
    // backgroundChannel is the channel responsible for receiving the following messages from
    // the background isolate that was setup by this plugin:
    // - "AlarmService.initialized"
    //
    // This channel is also responsible for sending requests from Android to Dart to execute Dart
    // callbacks in the background isolate.
    backgroundChannel =
        new MethodChannel(
            isolate,
            "com.ruangkeluargamobile/android_service_background",
            JSONMethodCodec.INSTANCE);
    backgroundChannel.setMethodCallHandler(this);
  }
}
