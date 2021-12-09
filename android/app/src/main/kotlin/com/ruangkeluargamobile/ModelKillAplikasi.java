package com.ruangkeluargamobile;

public class ModelKillAplikasi {
    String packageId;
    String appName;
    String timePenggunaan;

    public ModelKillAplikasi() {
    }

    public ModelKillAplikasi(String packageId, String appName, String timePenggunaan) {
        this.packageId = packageId;
        this.appName = appName;
        this.timePenggunaan = timePenggunaan;
    }

    public String getPackageId() {
        return packageId;
    }

    public void setPackageId(String packageId) {
        this.packageId = packageId;
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
