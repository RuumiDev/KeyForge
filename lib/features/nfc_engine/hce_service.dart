import 'package:flutter/services.dart';

/// Flutter bridge to the native NfcEmulationService via MethodChannel
class HceService {
  static const _channel = MethodChannel('com.keyforge/hce');

  /// Push a card payload and optional AID list to the native HCE service
  static Future<bool> startEmulation(Uint8List payload, {List<String>? aidList}) async {
    final result = await _channel.invokeMethod<bool>('setPayload', {
      'payload': payload,
      'aidList': aidList,
    });
    return result ?? false;
  }

  /// Clear the active emulation payload
  static Future<bool> stopEmulation() async {
    final result = await _channel.invokeMethod<bool>('clearPayload');
    return result ?? false;
  }

  /// Check if HCE is currently emulating a card
  static Future<bool> isEmulating() async {
    final result = await _channel.invokeMethod<bool>('isEmulating');
    return result ?? false;
  }

  /// Set this app as the preferred HCE service (for Android 4.4+)
  static Future<bool> setPreferredService() async {
    final result = await _channel.invokeMethod<bool>('setPreferredService');
    return result ?? false;
  }

  /// Unset this app as the preferred HCE service
  static Future<bool> unsetPreferredService() async {
    final result = await _channel.invokeMethod<bool>('unsetPreferredService');
    return result ?? false;
  }
}
