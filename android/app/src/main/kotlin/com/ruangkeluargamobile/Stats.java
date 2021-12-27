package com.ruangkeluargamobile;

import android.app.usage.UsageEvents;
import android.app.usage.UsageEvents.Event;
import android.app.usage.UsageStats;
import android.app.usage.UsageStatsManager;
import android.content.Context;
import android.util.Log;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;

/**
 * Created by User on 3/2/15.
 */
public class Stats {
    private static final String TAG = Stats.class.getSimpleName();

    /** Check if permission for usage statistics is required,
     * by fetching usage statistics since the beginning of time
     */
    @SuppressWarnings("ResourceType")
    public static boolean checkIfStatsAreAvailable(Context context) {
        UsageStatsManager usm = (UsageStatsManager) context.getSystemService("usagestats");
        long now  = Calendar.getInstance().getTimeInMillis();

        // Check if any usage stats are available from the beginning of time until now
        List<UsageStats> stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, 0, now);

        // Return whether or not stats are available
        return stats.size() > 0;
    }

    /** Produces a map for each installed app package name,
     * with the corresponding time in foreground in seconds for that application.
     */
    @SuppressWarnings("ResourceType")
    public static HashMap<String, long[]> getUsageMap(Context context, long start, long end) {
        UsageStatsManager manager = (UsageStatsManager) context.getSystemService("usagestats");
        List<UsageStats> usageStatsMap = manager.queryUsageStats(4, start, end);
        HashMap<String, long[]> usageMap = new HashMap<>();

        for (UsageStats us : usageStatsMap) {
            try {
                long timeMs = us.getTotalTimeInForeground();
                long lastMs = us.getLastTimeUsed();
                long array[] = { timeMs, lastMs };
                usageMap.put(us.getPackageName(), array);
            } catch (Exception e) {
                Log.d(TAG, "Getting timeVisible resulted in an exception");
            }
        }
        return usageMap;
    }

    @SuppressWarnings("ResourceType")
    public static HashMap<String, List<long[]>> getUsageEvents(Context context, long start, long end) {
        // getEventType() values:
        // 0 = NONE
        // 1 = MOVE TO FOREGROUND
        // 2 = MOVE TO BACKGROUND
        UsageStatsManager manager = (UsageStatsManager) context.getSystemService("usagestats");
        UsageEvents usageEvents = manager.queryEvents(start, end);
        HashMap<String, List<long[]>> usageMap = new HashMap<>();
        Event event = new Event();

        while (usageEvents.hasNextEvent()) {
            try {
                usageEvents.getNextEvent(event);
                long eventType = event.getEventType();
                long eventTime = event.getTimeStamp();
                long array[] = { eventType, eventTime };
                if(usageMap.containsKey(event.getPackageName())) {
                    usageMap.get(event.getPackageName()).add(array);
                }
                else {
                    List<long[]> eventPair = new ArrayList<>();
                    eventPair.add(array);
                    usageMap.put(event.getPackageName(), eventPair);
                }
            } catch (Exception e) {
                Log.d(TAG, "Getting event resulted in an exception");
            }
        }

//        for (UsageStats us : usageStatsMap) {
//            try {
//                long timeMs = us.getTotalTimeInForeground();
//                long lastMs = us.getLastTimeUsed();
//                long array[] = { timeMs, lastMs };
//                usageMap.put(us.getPackageName(), array);
//            } catch (Exception e) {
//                Log.d(TAG, "Getting timeVisible resulted in an exception");
//            }
//        }
        return usageMap;
    }
}
