package com.ruangkeluargamobile;

import android.app.Activity;
import android.os.Bundle;

import androidx.annotation.Nullable;
import com.keluargahkbp.R;

public class LockScreen extends Activity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_lockscreen);
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
