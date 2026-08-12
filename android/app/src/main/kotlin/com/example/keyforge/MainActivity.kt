package com.example.keyforge

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.nfc.cardemulation.CardEmulation
import android.nfc.NfcAdapter
import android.content.ComponentName

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.keyforge/hce"
    private var nfcAdapter: NfcAdapter? = null
    private var cardEmulation: CardEmulation? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        if (nfcAdapter != null) {
            cardEmulation = CardEmulation.getInstance(nfcAdapter)
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setPayload" -> {
                    val payload = call.argument<ByteArray>("payload")
                    val aidList = call.argument<List<String>>("aidList")
                    NfcEmulationService.activePayload = payload
                    NfcEmulationService.aidList = aidList
                    result.success(true)
                }
                "clearPayload" -> {
                    NfcEmulationService.activePayload = null
                    NfcEmulationService.aidList = null
                    result.success(true)
                }
                "isEmulating" -> {
                    result.success(NfcEmulationService.activePayload != null)
                }
                "setPreferredService" -> {
                    if (cardEmulation != null) {
                        val componentName = ComponentName(this, NfcEmulationService::class.java)
                        cardEmulation?.setPreferredService(this, componentName)
                        result.success(true)
                    } else {
                        result.error("UNAVAILABLE", "NFC adapter or card emulation not available", null)
                    }
                }
                "unsetPreferredService" -> {
                    if (cardEmulation != null) {
                        cardEmulation?.unsetPreferredService(this)
                        result.success(true)
                    } else {
                        result.error("UNAVAILABLE", "NFC adapter or card emulation not available", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
