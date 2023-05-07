package com.xdag.io

import android.os.Build
import android.os.Bundle
import androidx.activity.OnBackPressedCallback
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {
    private lateinit var onBackPressedCallback: OnBackPressedCallback
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // android 33
        if (Build.VERSION.SDK_INT >= 33) {
            onBackPressedCallback = object : OnBackPressedCallback(true) {
                override fun handleOnBackPressed() {
                    // flutter 侧处理返回事件
                    flutterEngine!!.navigationChannel.popRoute()
                }
            }
            // 注册 OnBackPressedCallback
            val onBackPressedDispatcher = onBackPressedDispatcher
            onBackPressedDispatcher.addCallback(this, onBackPressedCallback)
        }
    }
    override fun onDestroy() {
        super.onDestroy()
        if (Build.VERSION.SDK_INT >= 33) {
            onBackPressedCallback.remove()
        }
    }

    override fun onBackPressed() {
//        super.onBackPressed()
        if (Build.VERSION.SDK_INT < 33) {
            flutterEngine!!.navigationChannel.popRoute();
        }
    }


}
