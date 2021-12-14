package com.ruangkeluargamobile;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.AlertDialog;
import android.app.admin.DevicePolicyManager;
import android.app.usage.UsageStats;
import android.app.usage.UsageStatsManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.Window;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;
import java.util.TreeMap;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static com.ruangkeluargamobile.AlarmService.blockAppAndPackageNow;
import static com.ruangkeluargamobile.AlarmService.closeApps;
import static com.ruangkeluargamobile.AlarmService.getForegroundApplication;

public class MainAplication extends FlutterActivity implements MethodChannel.MethodCallHandler {
    public static int HOUR_RANGE = 1000 * 3600 * 24;

    public static MainAplication instan;
    private Context context;
    private final Object initializationLock = new Object();
    private MethodChannel alarmManagerPluginChannel;
    ComponentName compName;
    DevicePolicyManager deviceManger;
    public static MethodChannel.Result resultPremission;

    public static MainAplication getInstance(){
        return instan;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(getFlutterEngine());
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        instan = this;
        context = this;
        synchronized (initializationLock) {
            if (alarmManagerPluginChannel != null) {
                return;
            }
            alarmManagerPluginChannel =
                    new MethodChannel(
                            getFlutterEngine().getDartExecutor(),
                            "com.ruangkeluargamobile/android_service_background",
                            JSONMethodCodec.INSTANCE);
            alarmManagerPluginChannel.setMethodCallHandler(this);
        }
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if(!hasFocus) {
            Intent closeDialog = new Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS);
            sendBroadcast(closeDialog);
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
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
                    AndroidAlarmManagerPlugin.PeriodicRequest periodicRequest = AndroidAlarmManagerPlugin.PeriodicRequest.fromJson((JSONArray) arguments);
                    AlarmService.setPeriodic(context, periodicRequest);
                    result.success(true);
                    break;
                case "Alarm.oneShotAt":
                    // This message indicates that the Flutter app would like to schedule a one-time
                    // task.
                    AndroidAlarmManagerPlugin.OneShotRequest oneShotRequest = AndroidAlarmManagerPlugin.OneShotRequest.fromJson((JSONArray) arguments);
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
                    JSONObject checkAppLoad = (JSONObject) arguments;
                    JSONArray jsonArray = new JSONArray(checkAppLoad.getString("data"));
                    if(jsonArray.length()>0){
                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                            ModelKillAplikasi appForeground = getForegroundApplication(context);
                            if(appForeground != null){
                                if(!appForeground.getPackageId().equals("com.keluargahkbp")){
                                    System.out.println("APLIKASI CURRENT : "+appForeground.getPackageId());
                                    System.out.println("PENGGUNAAN : "+appForeground.getTimePenggunaan());
                                    for(int i = 0; i<jsonArray.length(); i++){
                                        JSONObject jsonObject = jsonArray.getJSONObject(i);
                                        if (appForeground.getPackageId().equals(jsonObject.getString("packageId"))) {
                                            System.out.println("PACKAGE FOREGROUND : "+appForeground.getPackageId());
                                            System.out.println("TIME FOREGROUND : "+appForeground.getTimePenggunaan());
                                            if(jsonObject.getString("blacklist").equals("true")){
                                                appForeground.setAppName(jsonObject.getString("appName"));
                                                appForeground.setBlacklist(jsonObject.getString("blacklist"));
                                                closeApps(context, appForeground);
                                            }else {
                                                if(Double.parseDouble(jsonObject.getString("limit" )) < Double.parseDouble(appForeground.getTimePenggunaan())){
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
                    JSONObject dataLock = (JSONObject) arguments;
                    MainAplication.getInstance().lockApp();
                    result.success(true);
                    break;
                case "permissionLockApp":
                    MainAplication.getInstance().resultPremission = result;
                    JSONObject permissionLock = (JSONObject) arguments;
                    MainAplication.getInstance().permissionLockApp();
                    break;
                default:
                    result.notImplemented();
                    break;
            }
        } catch (JSONException e) {
            result.error("error", "JSON error: " + e.getMessage(), null);
        } catch (PluginRegistrantException e) {
            result.error("error", "AlarmManager error: " + e.getMessage(), null);
        }catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
    }

    public void lockApp(){
        compName = new ComponentName(MainAplication.getInstance(), MyAdmin.class);
        deviceManger = (DevicePolicyManager)
                getSystemService(Context.DEVICE_POLICY_SERVICE);
        Intent intent = new Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN);
        intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, compName);
        intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "You should enable the app!");
        startActivityForResult(intent, 1111);
    }

    public void permissionLockApp(){
        compName = new ComponentName(MainAplication.getInstance(), MyAdmin.class);
        deviceManger = (DevicePolicyManager)
                getSystemService(Context.DEVICE_POLICY_SERVICE);
        Intent intent = new Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN);
        intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, compName);
        intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "You should enable the app!");
        startActivityForResult(intent, 11111111);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch (requestCode) {
            case 1111:
                if (resultCode == Activity.RESULT_OK) {
                    deviceManger.lockNow();
                }
            case 11111111:
                if (resultCode == Activity.RESULT_OK) {
                    MainAplication.getInstance().resultPremission.success(true);
                }else{
                    MainAplication.getInstance().resultPremission.success(false);
                }
                return;
        }
    }
}
