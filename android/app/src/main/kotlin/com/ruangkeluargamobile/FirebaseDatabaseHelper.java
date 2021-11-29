package com.ruangkeluargamobile;

import androidx.annotation.NonNull;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class FirebaseDatabaseHelper {
    private FirebaseDatabase mDatabase;
    private DatabaseReference mReference;
    private List<DataAplikasi> aplikasiList = new ArrayList<>();

    public FirebaseDatabaseHelper(){
        mDatabase = FirebaseDatabase.getInstance();
        mReference = mDatabase.getReference(MainAplication.getInstance().getDataShare("NM_DB"));
    }

    public void readDataFirebase(final DataStatus dataStatus){
        mReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                aplikasiList.clear();
                List<String> keys = new ArrayList<>();
                for(DataSnapshot dataSnapshot: snapshot.getChildren()){
                    keys.add(dataSnapshot.getKey());
                    DataAplikasi dataAplikasi = dataSnapshot.getValue(DataAplikasi.class);
                    aplikasiList.add(dataAplikasi);
                }
                dataStatus.DataLoaded(aplikasiList, keys);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });
    }
}
