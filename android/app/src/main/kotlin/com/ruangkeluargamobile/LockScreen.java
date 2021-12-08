package com.ruangkeluargamobile;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.Nullable;
import com.keluargahkbp.R;

import static com.ruangkeluargamobile.AlarmService.sharePref;

public class LockScreen extends Activity {
    String appName = "";
    TextView textDesc;
    Button buttonCLose;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_lockscreen);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        textDesc = (TextView) findViewById(R.id.textDesc);
        if(getIntent() != null){
            if (getIntent().hasExtra("APP_NAME")){
                appName = getIntent().getStringExtra("APP_NAME");
            }
        }
        sharePref(getApplicationContext(), "APP_NAME", true);
        textDesc.setText("Keluarga HKBP melakukan blokir aplikasi "+appName+" karena saat ini aplikasi tersebut dibatasi oleh Orangtua.");

        buttonCLose = (Button) findViewById(R.id.buttonCLose);
        buttonCLose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        sharePref(getApplicationContext(), "APP_NAME", false);
    }
}
