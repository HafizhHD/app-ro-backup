package com.ruangkeluargamobile;

import android.content.BroadcastReceiver;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainAplication extends FlutterActivity {
    private Intent intentService;
    public static MainAplication instan;
    private static final String CHANNEL_SEND_DATA = "com.ruangkeluargamobile.sendData";

    public EventChannel.EventSink eventSink;

    public static MainAplication getInstance() {
        return instan;
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
                        if (arguments.equals("startService")){
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

    private void startService(){
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            startForegroundService(intentService);
        }else{
            startService(intentService);
        }
    }

    private void stopService(){
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            ServiceBackground.getInstance().stopService();
        }else{
            ServiceBackground.getInstance().stopService();
            stopService(intentService);
        }
    }
}
