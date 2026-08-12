import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hce_service.dart';
import '../wallet/models/nfc_card.dart';

final activeEmulationProvider = StateNotifierProvider<ActiveEmulationNotifier, NfcCard?>((ref) {
  return ActiveEmulationNotifier();
});

class ActiveEmulationNotifier extends StateNotifier<NfcCard?> {
  ActiveEmulationNotifier() : super(null);

  Future<bool> startEmulating(NfcCard card) async {
    try {
      // Build binary payload from card data or UID bytes
      Uint8List payload;
      if (card.dumpData != null && card.dumpData!.isNotEmpty) {
        payload = card.dumpData!;
      } else {
        // Fallback: use raw UID bytes
        final cleanHex = card.uid.replaceAll(':', '').replaceAll(' ', '');
        final bytes = <int>[];
        for (int i = 0; i < cleanHex.length; i += 2) {
          bytes.add(int.parse(cleanHex.substring(i, i + 2), radix: 16));
        }
        payload = Uint8List.fromList(bytes);
      }

      await HceService.setPreferredService();
      final success = await HceService.startEmulation(payload);
      if (success) {
        state = card;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error starting emulation: $e');
      return false;
    }
  }

  Future<void> stopEmulating() async {
    try {
      await HceService.stopEmulation();
      await HceService.unsetPreferredService();
    } catch (e) {
      debugPrint('Error stopping emulation: $e');
    } finally {
      state = null;
    }
  }
}
