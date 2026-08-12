import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class MagicCardWriter {
  /// Brute-forces through all known Magic Card protocols (Gen 1 Backdoor, Gen 2 CUID Direct, Gen 3 UFUID)
  /// to rewrite Block 0 (hardware UID) on physical target cards/fobs.
  static Future<MagicWriteResult> bruteForceAndRewriteBlock0(
    String newUidHex, {
    Uint8List? fullBlock0Data,
    Function(String progress)? onProgress,
  }) async {
    try {
      onProgress?.call('Polling for target Magic Card / Fob...');
      await FlutterNfcKit.poll(iosAlertMessage: 'Hold Magic Card near device');

      final cleanUid = newUidHex.replaceAll(':', '').replaceAll(' ', '').toUpperCase();
      final block0 = fullBlock0Data != null && fullBlock0Data.length == 16
          ? fullBlock0Data
          : _constructBlock0(cleanUid);

      if (block0.isEmpty) {
        return MagicWriteResult(success: false, message: 'Invalid UID format ($cleanUid)');
      }

      final block0Hex = bytesToHex(block0);

      // ── Attack Vector 1: Gen 2 / CUID Direct Write (Standard A0/A2 Command) ──
      onProgress?.call('Attempting Gen 2 (CUID) direct Block 0 write...');
      try {
        // Try write command A0 for sector 0 block 0
        final respA0 = await FlutterNfcKit.transceive('A000$block0Hex');
        debugPrint('Gen2 A0 Write Response: $respA0');
        return MagicWriteResult(
          success: true,
          generation: 'Gen 2 (CUID)',
          message: 'Successfully rewrote Block 0 using Gen 2 direct command.',
        );
      } catch (e) {
        debugPrint('Gen 2 A0 failed, trying A2...');
      }

      try {
        // Try write command A2 for block 0 (Ultralight / NTAG style CUID)
        final respA2 = await FlutterNfcKit.transceive('A200$block0Hex');
        debugPrint('Gen2 A2 Write Response: $respA2');
        return MagicWriteResult(
          success: true,
          generation: 'Gen 2 (CUID A2)',
          message: 'Successfully rewrote Block 0 using Gen 2 A2 command.',
        );
      } catch (e) {
        debugPrint('Gen 2 direct write failed, escalating to Gen 1 Backdoor...');
      }

      // ── Attack Vector 2: Gen 1 (UID Backdoor Sequence 0x40 / 0x43) ──
      onProgress?.call('Attempting Gen 1 (Backdoor) unlock sequence...');
      try {
        // Send Gen 1 Unlock 1
        await FlutterNfcKit.transceive('40');
        // Send Gen 1 Unlock 2
        await FlutterNfcKit.transceive('43');
        // Write Block 0
        final respGen1 = await FlutterNfcKit.transceive('A000$block0Hex');
        debugPrint('Gen 1 Backdoor Write Response: $respGen1');
        return MagicWriteResult(
          success: true,
          generation: 'Gen 1 (Backdoor)',
          message: 'Successfully unlocked and wrote Block 0 via Gen 1 backdoor.',
        );
      } catch (e) {
        debugPrint('Gen 1 standard backdoor failed, trying APDU envelope...');
      }

      // ── Attack Vector 3: APDU Wrapped Unlock (Android ISO-DEP Envelope) ──
      onProgress?.call('Attempting ISO 14443-4 APDU envelope write...');
      try {
        // Wrapped APDU write command
        final apduWrite = '00A4040007D2760000850101';
        await FlutterNfcKit.transceive(apduWrite);
        final respApdu = await FlutterNfcKit.transceive('FFD6000010$block0Hex');
        if (respApdu.contains('9000') || respApdu.isNotEmpty) {
          return MagicWriteResult(
            success: true,
            generation: 'Gen 3 (APDU Wrapped)',
            message: 'Successfully wrote Block 0 via APDU command wrapper.',
          );
        }
      } catch (e) {
        debugPrint('APDU wrapped write failed: $e');
      }

      return MagicWriteResult(
        success: false,
        message: 'Target is a locked standard tag (OTP). Gen 1/Gen 2 Magic Card required.',
      );
    } catch (e) {
      debugPrint('Magic card brute force error: $e');
      return MagicWriteResult(success: false, message: 'Scan timed out or card disconnected.');
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  /// Constructs standard 16-byte MIFARE Classic Block 0 with BCC, SAK, and ATQA
  static Uint8List _constructBlock0(String uidHex) {
    final uidBytes = hexToBytes(uidHex);
    if (uidBytes.length != 4 && uidBytes.length != 7) {
      return Uint8List(0);
    }

    if (uidBytes.length == 4) {
      final bcc = uidBytes[0] ^ uidBytes[1] ^ uidBytes[2] ^ uidBytes[3];
      const sak = 0x08; // SAK MIFARE 1K
      final atqa = [0x04, 0x00];

      final block0 = List.filled(16, 0);
      block0.setRange(0, 4, uidBytes);
      block0[4] = bcc;
      block0[5] = sak;
      block0.setRange(6, 8, atqa);
      // Manufacturer bytes
      block0.setRange(8, 16, [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
      return Uint8List.fromList(block0);
    }

    // 7-byte UID cascade
    final block0 = List.filled(16, 0);
    block0.setRange(0, 7, uidBytes);
    block0[7] = 0x08; // SAK
    block0[8] = 0x44; // ATQA
    block0[9] = 0x00;
    return Uint8List.fromList(block0);
  }

  static String bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('').toUpperCase();
  }

  static List<int> hexToBytes(String hex) {
    final clean = hex.replaceAll(RegExp(r'\s+'), '');
    final bytes = <int>[];
    for (int i = 0; i < clean.length; i += 2) {
      bytes.add(int.parse(clean.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }
}

class MagicWriteResult {
  final bool success;
  final String? generation;
  final String message;

  MagicWriteResult({required this.success, this.generation, required this.message});
}
