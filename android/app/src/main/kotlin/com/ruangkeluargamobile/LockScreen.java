package com.ruangkeluargamobile;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

import androidx.annotation.Nullable;
import com.keluargahkbp.R;

public class LockScreen extends Activity {
    String appName = "";
    TextView textDesc;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_lockscreen);
        textDesc = (TextView) findViewById(R.id.textDesc);
        if(getIntent() != null){
            if (getIntent().hasExtra("APP_NAME")){
                appName = getIntent().getStringExtra("APP_NAME");
            }
        }
        textDesc.setText("Keluarga HKBP melakukan blokir aplikasi "+appName+" karena saat ini aplikasi tersebut dibatasi oleh Orangtua.");
        ServiceBackground.getInstance().killProses = true;
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        ServiceBackground.getInstance().killProses = false;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        ServiceBackground.getInstance().killProses = false;
    }
}
