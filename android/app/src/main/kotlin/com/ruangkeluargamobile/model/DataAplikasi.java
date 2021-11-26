package com.ruangkeluargamobile.model;

public class DataAplikasi {
    String appCategory;
    String appName;
    String blacklist;
    String packageId;

    public DataAplikasi() {
    }

    public DataAplikasi(String appCategory, String appName, String blacklist, String packageId) {
        this.appCategory = appCategory;
        this.appName = appName;
        this.blacklist = blacklist;
        this.packageId = packageId;
    }

    public String getAppCategory() {
        return appCategory;
    }

    public void setAppCategory(String appCategory) {
        this.appCategory = appCategory;
    }

    public String getAppName() {
        return appName;
    }

    public void setAppName(String appName) {
        this.appName = appName;
    }

    public String getBlacklist() {
        return blacklist;
    }

    public void setBlacklist(String blacklist) {
        this.blacklist = blacklist;
    }

    public String getPackageId() {
        return packageId;
    }

    public void setPackageId(String packageId) {
        this.packageId = packageId;
    }
}
