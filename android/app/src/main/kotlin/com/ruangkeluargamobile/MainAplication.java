package com.ruangkeluargamobile;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainAplication extends FlutterActivity {
    private Intent intentService;
    public static MainAplication instan;
    private static final String CHANNEL_SEND_DATA = "com.ruangkeluargamobile.sendData";

    public EventChannel.EventSink eventSink;

    public static MainAplication getInstance() {
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
        intentService = new Intent(MainAplication.this, ServiceBackground.class);
        new EventChannel(getFlutterEngine().getDartExecutor(), CHANNEL_SEND_DATA).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        MainAplication.getInstance().eventSink = events;
                        if (arguments.toString().contains("startService")){
                            sharePref("NM_DB","dataAplikasi"+arguments.toString().split(" ")[1]);
                            startService();
                        }else if (arguments.equals("stopService")){
                            stopService();
                        }
                    }

                    @Override
                    public void onCancel(Object arguments) {

                    }
                }
        );
    }

    private void sharePref(String key, String value){
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(this);
        SharedPreferences.Editor edit = sp.edit();
        edit.putString(key, value);
        edit.commit();
    }

    public String getDataShare(String key){
        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(this);
        return settings.getString("NM_DB", "dataAplikasi");
    }

    private void startService(){
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            startForegroundService(intentService);
        }else{
            startService(intentService);
        }
    }

    @Override
    protected void onDestroy() {
        stopService();
        super.onDestroy();
    }

    private void stopService(){
        if(intentService == null){
            intentService = new Intent(MainAplication.this, ServiceBackground.class);
        }
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            ServiceBackground.getInstance().stopService();
        }else{
            ServiceBackground.getInstance().stopService();
            stopService(intentService);
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
}
