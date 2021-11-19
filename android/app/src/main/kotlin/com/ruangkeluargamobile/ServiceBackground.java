package com.ruangkeluargamobile;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
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

import io.flutter.plugin.common.EventChannel;

import static androidx.core.app.NotificationCompat.PRIORITY_MIN;

public class ServiceBackground extends Service implements ScheduleListener {
    public static ServiceBackground instan;

    private final int RC_SEND_DATA = 1;
    private ScheduleUtil scheduleSendData;

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
            String CHANNEL_ID = "my_service";
            String CHANNEL_NAME = "Keluarga HKBP Running";

            NotificationChannel channel = new NotificationChannel(CHANNEL_ID,
                    CHANNEL_NAME, NotificationManager.IMPORTANCE_NONE);
            ((NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE)).createNotificationChannel(channel);

            Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                    .setCategory(Notification.CATEGORY_SERVICE).setSmallIcon(R.mipmap.launcher_icon).setPriority(PRIORITY_MIN).build();

            startForeground(101, notification);
        }
        scheduleSendData();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return super.onStartCommand(intent, flags, startId);
    }

    public static ServiceBackground getInstance() {
        return instan;
    }
    
    @Override
    public boolean onRun(int requestCode) {
        if (requestCode == RC_SEND_DATA) {
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
