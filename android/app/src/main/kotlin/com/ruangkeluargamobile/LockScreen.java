package com.ruangkeluargamobile;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.Nullable;
import com.keluargahkbp.R;

public class LockScreen extends Activity {
    String appName = "";
    TextView textDesc;
    Button buttonCLose;
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
        buttonCLose = (Button) findViewById(R.id.buttonCLose);
        buttonCLose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(LockScreen.this, MainAplication.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_CLEAR_TASK);
                startActivity(intent);
                finish();
            }
        });
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        ServiceBackground.getInstance().killProses = false;
        Intent intent = new Intent(LockScreen.this, MainAplication.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        finish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        ServiceBackground.getInstance().killProses = false;
    }
}
