package com.ruangkeluargamobile;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.keluargahkbp.R;
import com.ruangkeluargamobile.listener.ScheduleListener;
import com.ruangkeluargamobile.schedule.ScheduleUtil;
import com.ruangkeluargamobile.schedule.TimeConverter;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import id.flutter.flutter_background_service.BackgroundService;
import io.flutter.plugin.common.EventChannel;

import static androidx.core.app.NotificationCompat.PRIORITY_MIN;

public class ServiceBackground extends Service implements ScheduleListener {
    public static ServiceBackground instan;

    private final int RC_SEND_DATA = 1;
    private ScheduleUtil scheduleSendData;
    String CHANNEL_ID = "my_service";
    String CHANNEL_NAME = "Keluarga HKBP";
    String CHANNEL_CONTENT= "Update "+new SimpleDateFormat("yyyy MM dd HH:mm").format(new Date());

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        instan = this;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            updateNotifikasi(CHANNEL_CONTENT);
        }
    }

    public void updateNotifikasi(String content){
        String packageName = getApplicationContext().getPackageName();
        Intent i = getPackageManager().getLaunchIntentForPackage(packageName);

        PendingIntent pi = PendingIntent.getActivity(ServiceBackground.this, 101, i, PendingIntent.FLAG_CANCEL_CURRENT);

        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.mipmap.launcher_icon)
                .setAutoCancel(true)
                .setOngoing(true)
                .setContentTitle(CHANNEL_NAME)
                .setContentText(content)
                .setContentIntent(pi)
                .setCategory(Notification.CATEGORY_SERVICE)
                .setPriority(PRIORITY_MIN);

        startForeground(101, mBuilder.build());
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        scheduleSendData();
        return START_STICKY;
    }

    public static ServiceBackground getInstance() {
        return instan;
    }
    
    @Override
    public boolean onRun(int requestCode) {
        if (requestCode == RC_SEND_DATA) {
            System.out.println("RUNNING");
            updateNotifikasi("Update "+new SimpleDateFormat("yyyy MM dd HH:mm").format(new Date()));
            MainAplication.getInstance().eventSink.success("RUNNING");
        }
        return true;
    }

    @Override
    public void onDone(int requestCode) {

    }

    @Override
    public void onFail(int requestCode) {

    }

    public void scheduleSendData() {
        if (scheduleSendData == null) {
            scheduleSendData = new ScheduleUtil(this, RC_SEND_DATA).always(true);
            scheduleSendData.always(true);
            scheduleSendData.run(TimeConverter.convertToSecond(60));
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    public void stopService(){
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            stopForeground(false);
            scheduleSendData.end();
        }else{
            scheduleSendData.end();
        }
        MainAplication.getInstance().eventSink.success("STOPPED");
        stopSelf();
    }
}
