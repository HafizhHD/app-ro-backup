package com.ruangkeluargamobile.listener;

import com.ruangkeluargamobile.model.DataAplikasi;

import java.util.List;

public interface DataStatus {
    void DataLoaded(List<DataAplikasi> aplikasiList, List<String> keys);
}
