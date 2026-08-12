import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nfc_card.dart';

/// In-memory card list state — starts empty, populated only by real user scans
final cardListProvider = NotifierProvider<CardListNotifier, List<NfcCard>>(
  CardListNotifier.new,
);

class CardListNotifier extends Notifier<List<NfcCard>> {
  @override
  List<NfcCard> build() => []; // Zero placeholders — strictly user-scanned cards

  void add(NfcCard card) => state = [...state, card];

  void remove(String id) => state = state.where((c) => c.id != id).toList();

  void update(String id, NfcCard Function(NfcCard) updater) {
    state = [for (final c in state) c.id == id ? updater(c) : c];
  }
}

/// Selected card index in the wallet deck
final selectedCardIndex = StateProvider<int>((ref) => 0);
