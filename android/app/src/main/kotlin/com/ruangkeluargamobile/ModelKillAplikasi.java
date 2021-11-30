package com.ruangkeluargamobile;

public class ModelKillAplikasi {
    int Uuid;
    int pid;
    String packageId;
    String appName;

    public ModelKillAplikasi() {
    }

    public ModelKillAplikasi(int uuid, int pid, String packageId, String appName) {
        Uuid = uuid;
        this.pid = pid;
        this.packageId = packageId;
        this.appName = appName;
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
}
