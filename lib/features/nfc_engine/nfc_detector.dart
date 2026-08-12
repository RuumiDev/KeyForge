import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'mifare_dictionary.dart';

// Definition of an NfcScanResult class (as requested by the task)
class NfcScanResult {
  final NFCTag tag;
  final String uid;
  final String? atqa;
  final String? sak;
  final Map<int, Uint8List>? sectorData; // For MIFARE Classic
  final Uint8List? dumpBytes; // Raw dump if available

  NfcScanResult({
    required this.tag,
    required this.uid,
    this.atqa,
    this.sak,
    this.sectorData,
    this.dumpBytes,
  });

  @override
  String toString() {
    return 'NfcScanResult(\n'
        '  tag: ${tag.type},\n'
        '  uid: $uid,\n'
        '  atqa: $atqa,\n'
        '  sak: $sak,\n'
        '  sectorData: ${sectorData?.length} sectors,\n'
        '  dumpBytes: ${dumpBytes?.length} bytes\n'
        ')';
  }
}

class NfcDetector {
  static Future<NfcScanResult?> detectNfcTag() async {
    try {
      // Step 1: Poll tag
      final tag = await FlutterNfcKit.poll(iosAlertMessage: 'Hold card near device');

      String uid = tag.id;
      String? atqa = tag.atqa;
      String? sak = tag.sak;
      Map<int, Uint8List>? sectorData;
      Uint8List? dumpBytes;

      if (tag.type == NFCTagType.iso7816 ||
          tag.type == NFCTagType.iso15693 ||
          tag.standard == 'ISO 14443-4') {
        // Step 2: Identify Smart Card (ISO 7816 / ISO 14443-4)
        debugPrint('Detected ISO 7816 / ISO 14443-4 compatible tag.');
        try {
          // APDU select command for AID "A0000002471001"
          String apduResponse = await FlutterNfcKit.transceive("00A4040007A0000002471001");
          debugPrint('APDU Select Response: $apduResponse');
        } catch (e) {
          debugPrint('Error sending APDU command: $e');
        }
      } else if (tag.type == NFCTagType.mifare_classic || tag.standard == 'MIFARE Classic') {
        // Step 2: MIFARE Classic - Run automated dictionary attack
        debugPrint('Detected MIFARE Classic tag. Attempting dictionary attack...');
        sectorData = await MifareDictionary.crackSectors(tag);
        if (sectorData != null) {
          dumpBytes = _createDumpFromSectorData(sectorData);
        }
      } else {
        // Step 2: Fallback NfcA / other - Extract raw data
        debugPrint('Detected generic NfcA or other tag type.');
      }

      // Step 3: Return structured NfcScanResult
      return NfcScanResult(
        tag: tag,
        uid: uid,
        atqa: atqa,
        sak: sak,
        sectorData: sectorData,
        dumpBytes: dumpBytes,
      );
    } catch (e) {
      debugPrint('NFC scanning error: $e');
      return null;
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  // Helper to create a byte dump from sector data
  static Uint8List _createDumpFromSectorData(Map<int, Uint8List> sectorData) {
    List<int> bytes = [];
    sectorData.forEach((key, value) {
      bytes.addAll(value);
    });
    return Uint8List.fromList(bytes);
  }
}