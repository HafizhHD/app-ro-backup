# Keluarga HKBP
Create key.properties
```bash
storePassword=KeluargaHKBP
keyPassword=KeluargaHKBP
keyAlias=key
storeFile=key.jks
```

Agar Dapat Login menggunakan Google, Tambahkan SHA1 ke Firebase

Generate Release SHA (dari key.jks / key store):
``` 
keytool -list -v -keystore ./android/app/key.jks -alias key
```

Generate Debug SHA:
```
Mac keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

Windows keytool -list -v -keystore "\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

Linux keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```