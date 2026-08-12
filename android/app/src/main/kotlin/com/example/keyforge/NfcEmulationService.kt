package com.example.keyforge

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.util.Log

class NfcEmulationService : HostApduService() {

    companion object {
        @Volatile
        var activePayload: ByteArray? = null
        var aidList: List<String>? = null

        private const val TAG = "NfcEmulationService"
        private val SELECT_OK = byteArrayOf(0x90.toByte(), 0x00.toByte())
        private val UNKNOWN_CMD = byteArrayOf(0x6F.toByte(), 0x00.toByte())
        private val SELECT_APDU_HEADER = byteArrayOf(0x00, 0xA4.toByte(), 0x04, 0x00)
    }

    override fun processCommandApdu(commandApdu: ByteArray, extras: Bundle?): ByteArray {
        Log.d(TAG, "Received APDU: ${commandApdu.joinToString("") { "%02X".format(it) }}")

        // Check for SELECT AID command
        if (commandApdu.size >= 4 &&
            commandApdu[0] == SELECT_APDU_HEADER[0] &&
            commandApdu[1] == SELECT_APDU_HEADER[1] &&
            commandApdu[2] == SELECT_APDU_HEADER[2] &&
            commandApdu[3] == SELECT_APDU_HEADER[3]
        ) {
            // Validate AID (optional: could check against aidList)
            return SELECT_OK
        }

        // Return active payload or unknown command
        val payload = activePayload
        return if (payload != null) payload.plus(SELECT_OK) else UNKNOWN_CMD
    }

    override fun onDeactivated(reason: Int) {
        Log.d(TAG, "Deactivated, reason: $reason")
    }
}
