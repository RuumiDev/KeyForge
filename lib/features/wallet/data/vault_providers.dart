import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keyforge/features/wallet/data/models/card_profile.dart';
import 'package:keyforge/features/wallet/data/vault_repository.dart';

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  final repository = VaultRepository();
  repository.init(); // Initialize the repository
  return repository;
});

final cardListProvider = StreamProvider<List<CardProfile>>((ref) {
  final repository = ref.watch(vaultRepositoryProvider);
  return Stream.value(repository.getAllCards()); // Simple stream for now, can be improved with Hive listeners
});
