package com.ruangkeluargamobile.listener;

public interface ScheduleListener {
    boolean onRun(int requestCode);
    void onDone(int requestCode);
    void onFail(int requestCode);
}

