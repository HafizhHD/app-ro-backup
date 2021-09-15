# Keluarga HKBP
Create key.properties
```bash
storePassword=KeluargaHKBP
keyPassword=KeluargaHKBP
keyAlias=signKey
storeFile=key.jks
```

Generate Release SHA:
``` 
keytool -list -v -keystore ./android/app/key.jks -alias signKey 
```

Generate Debug SHA:
```
Mac keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

Windows keytool -list -v -keystore "\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

Linux keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```