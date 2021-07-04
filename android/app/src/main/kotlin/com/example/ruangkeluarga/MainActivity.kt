package com.ruangkeluarga

import android.Manifest
import android.content.pm.PackageManager
import android.os.AsyncTask
import android.provider.CallLog
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.InputStream
import java.net.URL


class MainActivity: FlutterActivity() {
    private val flutterChannel = "ruangkeluarga.flutter.dev/kmlmap"
    var bytesData: ByteArray? = null
    var resultData: MethodChannel.Result? = null
    var stringMethod = ""

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, flutterChannel).setMethodCallHandler {
                call, result ->
            // Note: this method is invoked on the main thread.

            if (call.method.contains("#@#")) {
                if (call.method.split("#@#")[0] == "KML") {
                    result.success(getKMLResource(call.method.split("#@#")[1]))
                } else {
                    result.notImplemented()
                }
            } else if(call.method.contains("getCall")) {
                resultData = result
                stringMethod = call.method
                val perm = arrayOf<String>(
                    Manifest.permission.READ_CALL_LOG,
                    Manifest.permission.READ_PHONE_STATE
                )
                if (hasPermissions(perm)) {
                    result.success(queryLogs(call.method.split("@@#")[1]))
                } else {
                    ActivityCompat.requestPermissions(
                        this, perm, 0
                    )
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun hasPermissions(permissions: Array<String>): Boolean {
        for (perm in permissions) {
            if (PackageManager.PERMISSION_GRANTED != ContextCompat.checkSelfPermission(
                    this, perm
                )
            ) {
                return false
            } else {
                resultData?.success(queryLogs(stringMethod.split("@@#")[1]))
            }
        }

        return true
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if(requestCode == 0) {
            val perm = arrayOf<String>(
                Manifest.permission.READ_CALL_LOG,
                Manifest.permission.READ_PHONE_STATE
            )
            hasPermissions(perm)
        }
    }

    private fun getKMLResource(url: String) {
//        return R.raw.history
        DownloadKmlFile(url)
            .execute()
    }

    private class DownloadKmlFile(private val mUrl: String) :
        AsyncTask<String?, ByteArray?, ByteArray?>() {
        override fun doInBackground(vararg params: String?): ByteArray? {
            try {
                val `is`: InputStream = URL(mUrl).openStream()
                // Log.d(TAG, "doInBackground: " + mUrl.toString());
                val buffer = ByteArrayOutputStream()
                var nRead: Int
                val data = ByteArray(16384)
                while (`is`.read(data, 0, data.size).also { nRead = it } != -1) {
                    buffer.write(data, 0, nRead)
                }
                buffer.flush()
                return buffer.toByteArray()
            } catch (e: IOException) {
                e.printStackTrace()
            }
            return null
        }

        override fun onPostExecute(byteArr: ByteArray?) {

        }
    }

    private val PROJECTION = arrayOf(
        CallLog.Calls.CACHED_FORMATTED_NUMBER,
        CallLog.Calls.NUMBER,
        CallLog.Calls.TYPE,
        CallLog.Calls.DATE,
        CallLog.Calls.DURATION,
        CallLog.Calls.CACHED_NAME,
        CallLog.Calls.CACHED_NUMBER_TYPE,
        CallLog.Calls.CACHED_NUMBER_LABEL,
        CallLog.Calls.CACHED_MATCHED_NUMBER,
        CallLog.Calls.PHONE_ACCOUNT_ID
    )

    private fun queryLogs(query: String) {
        try {
            contentResolver.query(
                CallLog.Calls.CONTENT_URI,
                PROJECTION,
                query,
                null, CallLog.Calls.DATE + " DESC"
            ).use { cursor ->
                val entries: MutableList<HashMap<String, Any>> =
                    ArrayList()
                while (cursor != null && cursor.moveToNext()) {
                    val map: HashMap<String, Any> = HashMap()
                    map["formattedNumber"] = cursor.getString(0)
                    map["number"] = cursor.getString(1)
                    map["callType"] = cursor.getInt(2)
                    map["timestamp"] = cursor.getLong(3)
                    map["duration"] = cursor.getInt(4)
                    map["name"] = cursor.getString(5)
                    map["cachedNumberType"] = cursor.getInt(6)
                    map["cachedNumberLabel"] = cursor.getString(7)
                    map["cachedMatchedNumber"] = cursor.getString(8)
                    map["phoneAccountId"] = cursor.getString(9)
                    entries.add(map)
                }
            }
        } catch (e: Exception) {
            Log.e("error", "error get call log ${e.message}")
        }
    }
}
