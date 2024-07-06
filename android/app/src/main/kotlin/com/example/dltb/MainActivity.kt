package com.example.dltb

import android.os.Build
import android.os.Bundle
import android.Manifest
import android.content.pm.PackageManager
import android.telephony.TelephonyManager
import android.content.Context
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.lang.reflect.Method
class MainActivity: FlutterActivity() {
    // private val CHANNEL = "com.flutter.epic/epic"
    private val REQUEST_CODE_READ_PHONE_STATE = 1
    // override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    //     GeneratedPluginRegistrant.registerWith(flutterEngine)
    //     MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { methodCall, result->
    //         if(methodCall.method == "Printy") {
    //             result.success("Hello From The Kotlin")
    //         }
    //     }
    // }


    // old

    // override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    //     super.configureFlutterEngine(flutterEngine)

    //     val systemPropertiesClass = Class.forName("android.os.SystemProperties")
    //     val getMethod: Method = systemPropertiesClass.getDeclaredMethod("get", String::class.java)
    //     MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.flutter.epic/epic").setMethodCallHandler {
    //       call, result ->
    //         if(call.method == "Printy") {
    //         //   result.success("Hello From The Kotlin")
    //         val serial: String? = getSerialNumber(getMethod)
    //         result.success(serial)
    //         }
            
    //         else {
    //           result.notImplemented()
    //         }
    //     }
    //   }


    // old
    // new

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        // val systemPropertiesClass = Class.forName("android.os.SystemProperties")
        // val getMethod: Method = systemPropertiesClass.getDeclaredMethod("get", String::class.java)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.flutter.epic/epic").setMethodCallHandler {
          call, result ->
          when (call.method) {
            "Printy" -> {
                val systemPropertiesClass = Class.forName("android.os.SystemProperties")
                val getMethod: Method = systemPropertiesClass.getDeclaredMethod("get", String::class.java)
                val serial: String? = getSerialNumber(getMethod)
                result.success(serial)
            }
            "getSimCardNumber" -> {
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_PHONE_STATE), REQUEST_CODE_READ_PHONE_STATE)
                    result.error("PERMISSION_DENIED", "Permission not granted", null)
                } else {
                    val iccid = getSimCardNumber()
                    if (iccid != null) {
                        result.success(iccid)
                    } else {
                        result.error("UNAVAILABLE", "SIM card number not available.", null)
                    }
                }
            }
            else -> {
                result.notImplemented()
            }
        }
            // if(call.method == "Printy") {
            // //   result.success("Hello From The Kotlin")
            // val serial: String? = getSerialNumber(getMethod)
            // result.success(serial)
            // }
            // else if(call.method == "getNumber"){
            //     val mynum: String? = getSimCardNumber()
            //     result.success(mynum)
            // }
            
            // else {
            //   result.notImplemented()
            // }
        }
      }
// new
    //   override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    //     super.configureFlutterEngine(flutterEngine)

    //     MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.flutter.epic/epic").setMethodCallHandler { call, result ->
    //         if (call.method == "getSimCardNumber") {
    //             val simCardNumber = getSimCardNumber()
    //             if (simCardNumber != null) {
    //                 result.success(simCardNumber)
    //             } else {
    //                 result.error("UNAVAILABLE", "SIM card number not available.", null)
    //             }
    //         } else {
    //             result.notImplemented()
    //         }
    //     }
    // }

    private fun getSimCardNumber(): String? {
        val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        return telephonyManager.simSerialNumber
    }
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CODE_READ_PHONE_STATE) {
            if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                // Permission granted, retry getting SIM card number if needed
            } else {
                // Permission denied
            }
        }
    }
    // private fun getSimCardNumber(): String? {
    //     val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
    //     return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
    //         telephonyManager.simSerialNumber
    //     } else {
    //         @Suppress("DEPRECATION")
    //         telephonyManager.simSerialNumber
    //     }
    // }
      private fun getSerialNumber(getMethod: Method): String? {
        val apiLevel = Build.VERSION.SDK_INT

        return when {
            apiLevel >= Build.VERSION_CODES.R -> {
                try {
                    getMethod.invoke(null, "ro.sunmi.serial") as String
                } catch (e: Exception) {
                    e.printStackTrace()
                    null
                }
            }
            apiLevel >= Build.VERSION_CODES.O -> Build.getSerial()
            else -> {
                try {
                    getMethod.invoke(null, "ro.serialno") as String
                } catch (e: Exception) {
                    e.printStackTrace()
                    null
                }
            }
        }
    }
}