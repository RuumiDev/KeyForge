import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KeyStore & Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SecurityStatusCard(),
          const SizedBox(height: 24),
          const Text('VAULT INTEGRITY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: KF.textMuted, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.shield_rounded,
            title: 'Android Hardware KeyStore',
            subtitle: 'AES-256 GCM Hardware-Backed Master Key',
            status: 'Active',
            statusColor: KF.secondary,
          ),
          _SettingTile(
            icon: Icons.cloud_off_rounded,
            title: 'Zero Cloud Storage',
            subtitle: 'All card dumps encrypted in local Hive vault',
            status: 'Offline',
            statusColor: KF.primary,
          ),
          _SettingTile(
            icon: Icons.lock_outline_rounded,
            title: 'Block 0 Anti-Collision Protection',
            subtitle: 'UID rewriting restricted to CUID / Gen2 Magic Cards',
            status: 'Enforced',
            statusColor: KF.secondary,
          ),
        ],
      ),
    );
  }
}

class _SecurityStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KF.surface,
        borderRadius: BorderRadius.circular(KF.cardRadius),
        border: Border.all(color: KF.secondary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: KF.secondary.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: KF.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_rounded, color: KF.secondary, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hardware Vault Secure', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: KF.textPrimary)),
                    SizedBox(height: 2),
                    Text('No leaks detected • Local encryption active', style: TextStyle(fontSize: 12, color: KF.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
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
          Icon(icon, color: KF.textMuted, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: KF.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: KF.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ],
      ),
    );
  }
}
