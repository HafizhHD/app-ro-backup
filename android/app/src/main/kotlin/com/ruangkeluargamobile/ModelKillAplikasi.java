package com.ruangkeluargamobile;

public class ModelKillAplikasi {
    int Uuid;
    int pid;
    String packageId;
    String appName;
    String timePenggunaan;

    public ModelKillAplikasi() {
    }

    public ModelKillAplikasi(int uuid, int pid, String packageId, String appName, String timePenggunaan) {
        Uuid = uuid;
        this.pid = pid;
        this.packageId = packageId;
        this.appName = appName;
        this.timePenggunaan = timePenggunaan;
    }

    public int getUuid() {
        return Uuid;
    }

    public void setUuid(int uuid) {
        Uuid = uuid;
    }

    public String getPackageId() {
        return packageId;
    }

    public void setPackageId(String packageId) {
        this.packageId = packageId;
    }

    public int getPid() {
        return pid;
    }

    public void setPid(int pid) {
        this.pid = pid;
    }

    public String getAppName() {
        return appName;
    }

    public void setAppName(String appName) {
        this.appName = appName;
    }

    public String getTimePenggunaan() {
        return timePenggunaan;
    }

    public void setTimePenggunaan(String timePenggunaan) {
        this.timePenggunaan = timePenggunaan;
    }
}
