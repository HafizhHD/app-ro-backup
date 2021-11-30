package com.ruangkeluargamobile;

import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.app.usage.UsageStats;
import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import com.keluargahkbp.R;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.TreeMap;

import static androidx.core.app.NotificationCompat.PRIORITY_MIN;

public class ServiceBackground extends Service{
    public static ServiceBackground instan;

    String CHANNEL_ID = "my_service";
    String CHANNEL_NAME = "Keluarga HKBP";
    Timer timer;
    public static String CHANNEL_CONTENT= "Update "+new SimpleDateFormat("MMM, yyyy-dd HH:mm").format(new Date());
    public static Boolean killProses = false;
    public static int HOUR_RANGE = 1000 * 3600 * 24;

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

    @RequiresApi(api = Build.VERSION_CODES.O)
    public void updateNotifikasi(String content){
        NotificationChannel channel = new NotificationChannel(CHANNEL_ID,
                CHANNEL_NAME, NotificationManager.IMPORTANCE_NONE);
        ((NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE)).createNotificationChannel(channel);
        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setCategory(Notification.CATEGORY_SERVICE).setSmallIcon(R.mipmap.launcher_icon).setPriority(PRIORITY_MIN).build();
        startForeground(1010101, notification);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        CHANNEL_CONTENT= "Update "+new SimpleDateFormat("MMM, yyyy-dd HH:mm").format(new Date());
        if(timer != null){
            timer.cancel();
        }
        timer = new Timer();
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                ServiceBackground.getInstance().readDataFirebaseDatabase();
            }
        }, 5000, 5000);
        MainAplication.getInstance().eventSink.success("RUNNING");
        return START_STICKY;
    }

    public void readDataFirebaseDatabase(){
        new FirebaseDatabaseHelper().readDataFirebase(new DataStatus() {
            @Override
            public void DataLoaded(List<DataAplikasi> aplikasiList, List<String> keys) {
                try {
                    ModelKillAplikasi appForeground = getForegroundApplication();
                    if(appForeground != null){
                        if(!appForeground.getPackageId().equals("com.keluargahkbp")){
                            if(aplikasiList.size()>0) {
                                for (int i = 0; i < aplikasiList.size(); i++) {
                                    if (aplikasiList.get(i).getBlacklist().equals("true") && appForeground.getPackageId().equals(aplikasiList.get(i).getPackageId())) {
                                        ServiceBackground.getInstance().closeApps(appForeground);
                                    }
                                }
                            }
                        }
                    }
                } catch (PackageManager.NameNotFoundException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    public void closeApps(ModelKillAplikasi appForeground){
        try {
            android.os.Process.killProcess(appForeground.getUuid());
            android.os.Process.killProcess(appForeground.getPid());
        }catch (Exception e){
        }
        Intent lockIntent = new Intent(this, LockScreen.class);
        lockIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        ServiceBackground.getInstance().startActivity(lockIntent);
    }

    public static ServiceBackground getInstance() {
        return instan;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    public void stopService(){
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            stopForeground(false);
        }
        MainAplication.getInstance().eventSink.success("STOPPED");
        stopSelf();
    }

    public ModelKillAplikasi getForegroundApplication() throws PackageManager.NameNotFoundException {
        UsageStatsManager usageStatsManager = (UsageStatsManager)
                ServiceBackground.getInstance().getSystemService(Context.USAGE_STATS_SERVICE);
        long currentTime = System.currentTimeMillis();
        List<UsageStats> usageStats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY,
                currentTime - HOUR_RANGE, currentTime);
        ActivityManager am = (ActivityManager) ServiceBackground.getInstance().getSystemService(Context.ACTIVITY_SERVICE);
        List<ActivityManager.RunningAppProcessInfo> runningProcesses = am.getRunningAppProcesses();
        if(usageStats != null) {
            TreeMap<Long, UsageStats> sortedMap = new TreeMap<Long, UsageStats>();
            for(UsageStats usageStat : usageStats) {
                Long time = usageStat.getLastTimeUsed();
                sortedMap.put(time, usageStat);
            }
            if(!sortedMap.isEmpty()) {
                Long lastKey = sortedMap.lastKey();
                UsageStats foregroundAppUsageStats = sortedMap.get(lastKey);
                if(foregroundAppUsageStats != null) {
                    String applicationName = ServiceBackground.getInstance().getPackageManager().
                            getApplicationLabel(ServiceBackground.getInstance().getPackageManager()
                                    .getApplicationInfo(foregroundAppUsageStats.getPackageName(), 0)).toString();
                    if(applicationName != null) {
                        ModelKillAplikasi modelKillAplikasi = new ModelKillAplikasi();
                        modelKillAplikasi.setPackageId(foregroundAppUsageStats.getPackageName());
                        for (int i = 0; i < runningProcesses.size(); i++) {
                            if (foregroundAppUsageStats.getPackageName().equals(runningProcesses.get(i).processName)) {
                                modelKillAplikasi.setUuid(runningProcesses.get(i).uid);
                                modelKillAplikasi.setPid(runningProcesses.get(i).pid);
                            }
                        }
                        return modelKillAplikasi;
                    }
                }
            }
        }
        return null;
    }
}
