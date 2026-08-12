import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../wallet/state/wallet_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Emulate Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: KF.textMuted),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audit log is immutable in Hardware KeyStore.')),
              );
            },
          ),
        ],
      ),
      body: cards.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: KF.textMuted.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('No scan logs yet', style: TextStyle(color: KF.textMuted, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: KF.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: KF.surfaceHigh.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: KF.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.nfc_rounded, color: KF.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.title,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: KF.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'UID: ${card.uid} • ${card.typeBadge}',
                              style: const TextStyle(fontSize: 12, color: KF.textMuted, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${card.savedAt.hour.toString().padLeft(2, '0')}:${card.savedAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12, color: KF.textMuted),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
