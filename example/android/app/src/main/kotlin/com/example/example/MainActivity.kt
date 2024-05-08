package com.example.example

import com.sunmi.peripheral.printer.InnerPrinterCallback
import com.sunmi.peripheral.printer.InnerPrinterException
import com.sunmi.peripheral.printer.InnerPrinterManager
import com.sunmi.peripheral.printer.InnerResultCallback
import com.sunmi.peripheral.printer.SunmiPrinterService
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.properties.Delegates

class MainActivity: FlutterActivity() {
    private lateinit var printerService: SunmiPrinterService
    private var sunmiRegistrationResult by Delegates.notNull<Boolean>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        try {
            sunmiRegistrationResult = InnerPrinterManager
                .getInstance()
                .bindService(context, printerCallback)
        } catch (e: InnerPrinterException) {
            Log.e(LOG_TAG, "Error: $e")
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "hasInternalPrinter" -> result.success(sunmiRegistrationResult)
                        "print" -> printBytes(call.arguments<ByteArray>())
                    }
                } catch (e: Exception) {
                    Log.d(LOG_TAG, e.toString())
                }
            }
    }

    private fun printBytes(bytes: ByteArray?) {
        if (bytes == null || !sunmiRegistrationResult) return
        Log.d(LOG_TAG, "Printing bytes: $bytes")
        printerService.sendRAWData(bytes, resultCallback)
    }

    private val printerCallback = object: InnerPrinterCallback() {
        override fun onConnected(service: SunmiPrinterService) {
            printerService = service
        }

        override fun onDisconnected() {}
    }

    private val resultCallback = object: InnerResultCallback() {
        override fun onRunResult(isSuccess: Boolean) {
            Log.d(LOG_TAG, "Run result: $isSuccess")
        }

        override fun onPrintResult(code: Int, msg: String?) {
            Log.d(LOG_TAG, "Print result. Code: $code, Msg: $msg")
        }

        override fun onRaiseException(code: Int, msg: String?) {
            Log.e(LOG_TAG, "Error $code. $msg")
        }

        override fun onReturnString(result: String?) {
            Log.d(LOG_TAG, "Return string: $result")
        }
    }

    companion object {
        private const val CHANNEL = "it.elsyco.touchticket_webview/sunmi_printer"
        private const val LOG_TAG = "it.elsyco.touchticket_webview"
    }
}
