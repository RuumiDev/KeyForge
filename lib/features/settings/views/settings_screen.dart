import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../../../core/theme.dart';
import '../../nfc_engine/nfc_status_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nfcStatus = ref.watch(nfcStatusProvider).value ?? NFCAvailability.not_supported;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Diagnostics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('NFC HARDWARE STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: KF.textMuted, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KF.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KF.surfaceHigh.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(
                  nfcStatus == NFCAvailability.available ? Icons.nfc_rounded : Icons.nfc_outlined,
                  color: nfcStatus == NFCAvailability.available ? KF.secondary : KF.error,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nfcStatus == NFCAvailability.available
                            ? 'NFC Controller Enabled'
                            : nfcStatus == NFCAvailability.disabled
                                ? 'NFC Disabled in System'
                                : 'NFC Hardware Not Supported',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: KF.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nfcStatus == NFCAvailability.available ? 'Ready for 13.56 MHz probing' : 'Please enable NFC in phone settings',
                        style: const TextStyle(fontSize: 11, color: KF.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('APP CONFIGURATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: KF.textMuted, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _SettingsActionTile(
            icon: Icons.vpn_key_rounded,
            title: 'Dictionary Attack Wordlist',
            subtitle: '50 well-known MIFARE Classic keys loaded',
            onTap: () {},
          ),
          _SettingsActionTile(
            icon: Icons.memory_rounded,
            title: 'HCE Background Emulation',
            subtitle: 'Default AID: F04B455946524745',
            onTap: () {},
          ),
          _SettingsActionTile(
            icon: Icons.info_outline_rounded,
            title: 'About KeyForge',
            subtitle: 'Version 1.0.0 (Production Overhaul)',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'KeyForge',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Offline 13.56 MHz NFC Access Card Tool.',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: KF.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KF.surfaceHigh.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        leading: Icon(icon, color: KF.primary),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: KF.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: KF.textMuted)),
        trailing: const Icon(Icons.chevron_right_rounded, color: KF.textMuted),
        onTap: onTap,
      ),
    );
  }
}
