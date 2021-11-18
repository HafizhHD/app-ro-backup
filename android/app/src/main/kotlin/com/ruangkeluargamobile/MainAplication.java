package com.ruangkeluargamobile;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainAplication extends FlutterActivity {
    private Intent intentService;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        intentService = new Intent(MainAplication.this, ServiceBackground.class);
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "com.ruangkeluargamobile.message").setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                if (call.method.equals("startService")){
                    startService();
                    result.success("Service Started");
                }else if (call.method.equals("stopService")){
                    stopService();
                    result.success("Service Stopped");
                }
            }
        });
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
