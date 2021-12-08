package com.ruangkeluargamobile;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

public class AutoStartService extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.e("Service", "iniiiiiiii");
        Intent intentService = new Intent(context, ServiceBackground.class);
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            context.startForegroundService(intentService);
            Log.e("Service", "start ..Foreground Service");
        }else {
            context.startService(intentService);
            Log.e("Service", "start ..Service");
        }
//        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
//            Intent mIntent = new Intent(context, MainAplication.class);
//            mIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//            context.startActivity(mIntent);
//        }
//        else {
//            Intent intentService = new Intent(context, ServiceBackground.class);
//            if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
//                context.startForegroundService(intentService);
//            }else{
//                context.startService(intentService);
//            }
//        }
    }
}
