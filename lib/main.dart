import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'features/wallet/views/wallet_screen.dart';
import 'features/history/views/history_screen.dart';
import 'features/security/views/security_screen.dart';
import 'features/settings/views/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: KeyForgeApp()));
}

class KeyForgeApp extends StatelessWidget {
  const KeyForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KeyForge',
      debugShowCheckedModeBanner: false,
      theme: KF.theme,
      home: const _AppShell(),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _tab = 0;

  static const _screens = <Widget>[
    WalletScreen(),
    HistoryScreen(),
    SecurityScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        height: 64,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.key_rounded), label: 'Keys'),
          NavigationDestination(icon: Icon(Icons.history_rounded), label: 'History'),
          NavigationDestination(icon: Icon(Icons.shield_outlined), label: 'Security'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
