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
import com.ruangkeluargamobile.database.FirebaseDatabaseHelper;
import com.ruangkeluargamobile.listener.DataStatus;
import com.ruangkeluargamobile.listener.ScheduleListener;
import com.ruangkeluargamobile.model.DataAplikasi;
import com.ruangkeluargamobile.schedule.ScheduleUtil;
import com.ruangkeluargamobile.schedule.TimeConverter;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import id.flutter.flutter_background_service.BackgroundService;
import io.flutter.plugin.common.EventChannel;

import static androidx.core.app.NotificationCompat.PRIORITY_MIN;

public class ServiceBackground extends Service /*implements ScheduleListener*/ {
    public static ServiceBackground instan;

    /*private final int RC_SEND_DATA = 1;
    private ScheduleUtil scheduleSendData;*/
    String CHANNEL_ID = "my_service";
    String CHANNEL_NAME = "Keluarga HKBP";
    String CHANNEL_CONTENT= "Update "+new SimpleDateFormat("MMM, yyyy-dd HH:mm").format(new Date());

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        instan = this;
        CHANNEL_CONTENT= "Update "+new SimpleDateFormat("MMM, yyyy-dd HH:mm").format(new Date());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            updateNotifikasi(CHANNEL_CONTENT);
        }
    }

    public void updateNotifikasi(String content){
        String packageName = getApplicationContext().getPackageName();
        Intent i = getPackageManager().getLaunchIntentForPackage(packageName);

        PendingIntent pi = PendingIntent.getActivity(ServiceBackground.this, 1010101, i, PendingIntent.FLAG_CANCEL_CURRENT);

        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.mipmap.launcher_icon)
                .setAutoCancel(true)
                .setOngoing(true)
                .setContentTitle(CHANNEL_NAME)
                .setContentText(content)
                .setContentIntent(pi)
                .setCategory(Notification.CATEGORY_SERVICE)
                .setPriority(PRIORITY_MIN);

        startForeground(1010101, mBuilder.build());
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
//        scheduleSendDataTimer();
        CHANNEL_CONTENT= "Update "+new SimpleDateFormat("MMM, yyyy-dd HH:mm").format(new Date());
        readDataFirebaseDatabase();
        MainAplication.getInstance().eventSink.success("RUNNING");
        return START_STICKY;
    }

    public void readDataFirebaseDatabase(){
        new FirebaseDatabaseHelper().readDataFirebase(new DataStatus() {
            @Override
            public void DataLoaded(List<DataAplikasi> aplikasiList, List<String> keys) {
                if(aplikasiList.size()>0){
                    for(DataAplikasi dataAplikasi: aplikasiList){
//                        System.out.println("package : "+dataAplikasi.getPackageId());
//                        System.out.println("blacklist : "+dataAplikasi.getBlacklist());
                    }
                }
            }
        });
    }

    public static ServiceBackground getInstance() {
        return instan;
    }
    
    /*@Override
    public boolean onRun(int requestCode) {
        if (requestCode == RC_SEND_DATA) {
            System.out.println("RUNNING");
            updateNotifikasi("Update "+new SimpleDateFormat("MMM, yyyy-dd HH:mm").format(new Date()));
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

    public void scheduleSendDataTimer() {
        if (scheduleSendData == null) {
            scheduleSendData = new ScheduleUtil(this, RC_SEND_DATA).always(true);
            scheduleSendData.always(true);
            scheduleSendData.run(TimeConverter.convertToSecond(60));
        }
    }*/

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    public void stopService(){
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            stopForeground(false);
//            scheduleSendData.end();
        }/*else{
            scheduleSendData.end();
        }*/
        MainAplication.getInstance().eventSink.success("STOPPED");
        stopSelf();
    }
}
