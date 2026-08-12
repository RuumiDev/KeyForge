import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keyforge/core/security/vault_security.dart';
import 'package:keyforge/features/wallet/data/models/card_profile.dart';

class VaultRepository {
  Box<CardProfile>? _box;
  final VaultSecurity _security = VaultSecurity();

  Future<void> init() async {
    final key = await _security.getOrCreateMasterKey();
    _box = await Hive.openBox<CardProfile>('card_vault', encryptionCipher: HiveAesCipher(key));
  }

  List<CardProfile> getAllCards() => _box?.values.toList() ?? [];

  CardProfile? getCard(String id) => _box?.get(id);

  Future<void> saveCard(CardProfile card) async => await _box?.put(card.id, card);

  Future<void> deleteCard(String id) async => await _box?.delete(id);

  Future<void> exportCardToFile(String id, String filePath) async {
    final card = getCard(id);
    if (card != null && card.rawDump != null) {
      await File(filePath).writeAsBytes(card.rawDump!);
    }
  }
}
