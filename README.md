# Ruang ORTU by ASIA
Create key.properties
```bash
storePassword=ruangORTUASIA
keyPassword=ruangORTUASIA
keyAlias=asia
storeFile=asia.jks
```

Agar Dapat Login menggunakan Google, Tambahkan SHA1 ke Firebase

Generate Release SHA (dari key.jks / key store):
``` 
keytool -list -v -keystore ./android/app/asia.jks -alias key
```

Generate Debug SHA:
```
Mac keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

Windows keytool -list -v -keystore "\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

Linux keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Cara fix background service di Flutter 2.10.4 (android):
```
Downgrade gradle (di gradle-wrapper.properties) ke 6.1.1, gradle:build (di build.gradle) ke 3.6.3, dan kotlin ke 1.6.0

Jika ada error "No version of NDK matched the requested version 20.0.5594570", download NDK versi tersebut di SDK Tools Android studio
```