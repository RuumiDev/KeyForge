import 'package:flutter/services.dart';

/// Flutter bridge to the native NfcEmulationService via MethodChannel
class HceChannel {
  static const _channel = MethodChannel('com.keyforge/hce');

  /// Push a card payload to the native HCE service for emulation
  static Future<bool> setPayload(Uint8List payload) async {
    final result = await _channel.invokeMethod<bool>('setPayload', {'payload': payload});
    return result ?? false;
  }

  /// Clear the active emulation payload
  static Future<bool> clearPayload() async {
    final result = await _channel.invokeMethod<bool>('clearPayload');
    return result ?? false;
  }

  /// Check if HCE is currently emulating a card
  static Future<bool> isEmulating() async {
    final result = await _channel.invokeMethod<bool>('isEmulating');
    return result ?? false;
  }
}
