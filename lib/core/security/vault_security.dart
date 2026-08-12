import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math';

class VaultSecurity {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyAlias = 'master_encryption_key';

  Future<Uint8List> getOrCreateMasterKey() async {
    String? keyString = await _storage.read(key: _keyAlias);
    if (keyString == null) {
      final random = Random.secure();
      final key = Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));
      keyString = base64Encode(key);
      await _storage.write(key: _keyAlias, value: keyString);
    }
    return base64Decode(keyString);
  }
}
