import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

/// Provider for current NFC hardware availability state
final nfcStatusProvider = StreamProvider.autoDispose<NFCAvailability>((ref) async* {
  // Yield initial check
  try {
    final status = await FlutterNfcKit.nfcAvailability;
    yield status;
  } catch (_) {
    yield NFCAvailability.not_supported;
  }

  // Poll state every 2 seconds for live status changes (e.g. user toggles quick settings)
  final timer = Stream.periodic(const Duration(seconds: 2));
  await for (final _ in timer) {
    try {
      final status = await FlutterNfcKit.nfcAvailability;
      yield status;
    } catch (_) {
      yield NFCAvailability.not_supported;
    }
  }
});
