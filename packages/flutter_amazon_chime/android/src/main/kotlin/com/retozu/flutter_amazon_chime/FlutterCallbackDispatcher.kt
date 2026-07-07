package com.retozu.flutter_amazon_chime

import android.os.Handler
import android.os.Looper

internal object FlutterCallbackDispatcher {
    private val mainHandler = Handler(Looper.getMainLooper())

    fun runOnMainThread(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            mainHandler.post(block)
        }
    }
}
