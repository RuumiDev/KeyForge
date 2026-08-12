import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../nfc_engine/nfc_detector.dart';
import '../../nfc_engine/nfc_status_provider.dart';
import '../../nfc_engine/emulation_provider.dart';
import '../../nfc_engine/magic_card_writer.dart';
import '../models/nfc_card.dart';
import '../state/wallet_providers.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.90);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardListProvider);
    final selectedIndex = ref.watch(selectedCardIndex);
    final activeEmulation = ref.watch(activeEmulationProvider);
    final nfcStatus = ref.watch(nfcStatusProvider).value ?? NFCAvailability.not_supported;
    final isNfcOn = nfcStatus == NFCAvailability.available;

    // Auto-emulate focused card silently in the background
    if (isNfcOn && cards.isNotEmpty) {
      final currentCard = cards[selectedIndex.clamp(0, cards.length - 1)];
      if (activeEmulation?.id != currentCard.id) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(activeEmulationProvider.notifier).startEmulating(currentCard);
        });
      }
    } else if (!isNfcOn && activeEmulation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(activeEmulationProvider.notifier).stopEmulating();
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            Expanded(
              child: !isNfcOn
                  ? const _NfcDisabledPrompt()
                  : cards.isEmpty
                      ? const _EmptyVaultState()
                      : Column(
                          children: [
                            const SizedBox(height: 12),
                            // Minimalist Horizontal Card Carousel
                            SizedBox(
                              height: 200,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: cards.length,
                                onPageChanged: (i) => ref.read(selectedCardIndex.notifier).state = i,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, i) {
                                  final isCurrent = i == selectedIndex;
                                  return AnimatedScale(
                                    scale: isCurrent ? 1.0 : 0.94,
                                    duration: const Duration(milliseconds: 250),
                                    child: _MinimalAccessCard(
                                      card: cards[i],
                                      index: i,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Page Indicators
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                cards.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: i == selectedIndex ? 16 : 5,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: i == selectedIndex ? KF.primary : KF.surfaceHigh,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Actions & Card Info
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: _CardDetailSection(
                                  card: cards[selectedIndex.clamp(0, cards.length - 1)],
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isNfcOn ? KF.primary : KF.surfaceHigh,
        onPressed: () {
          if (!isNfcOn) {
            _showNfcDisabledAlert(context);
          } else {
            _showScanModal(context);
          }
        },
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Add Card', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  void _showNfcDisabledAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: KF.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('NFC Disabled', style: GoogleFonts.spaceGrotesk(color: KF.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text(
          'Please turn on NFC in your phone\'s settings to scan and clone access cards.',
          style: TextStyle(color: KF.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss', style: TextStyle(color: KF.primary)),
          ),
        ],
      ),
    );
  }

  void _showScanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: KF.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ScanSheet(),
    );
  }
}

// ── Clean Minimal Header ────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
      child: Text(
        'KeyForge',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: KF.textPrimary,
          letterSpacing: -0.6,
        ),
      ),
    );
  }
}

// ── Static NFC Disabled View (Zero Breathing / Bouncing Animation) ───────────

class _NfcDisabledPrompt extends StatelessWidget {
  const _NfcDisabledPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KF.surfaceHigh,
                border: Border.all(color: KF.border),
              ),
              child: const Icon(Icons.nfc_outlined, color: KF.textMuted, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              'NFC is turned off',
              style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: KF.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Turn on NFC in your phone\'s quick settings to scan, view, and emulate access cards.',
              style: TextStyle(fontSize: 13, color: KF.textMuted, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Minimalist Access Card Design ───────────────────────────────────────────

class _MinimalAccessCard extends StatelessWidget {
  final NfcCard card;
  final int index;

  const _MinimalAccessCard({required this.card, required this.index});

  @override
  Widget build(BuildContext context) {
    // Elegant, restrained palette
    final palettes = [
      (const Color(0xFF0F172A), const Color(0xFF1E293B), const Color(0xFF38BDF8)),
      (const Color(0xFF18181B), const Color(0xFF27272A), const Color(0xFFA1A1AA)),
      (const Color(0xFF064E3B), const Color(0xFF065F46), const Color(0xFF34D399)),
      (const Color(0xFF1E1B4B), const Color(0xFF312E81), const Color(0xFF818CF8)),
      (const Color(0xFF3F1D38), const Color(0xFF581C87), const Color(0xFFC084FC)),
    ];

    final (bg1, bg2, accent) = palettes[index % palettes.length];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bg1, bg2],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.nfc_rounded, size: 18, color: accent),
                    const SizedBox(width: 6),
                    Text(
                      card.typeBadge.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: accent,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.contactless_rounded, size: 20, color: Colors.white.withValues(alpha: 0.4)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  card.uid,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card Detail Section ──────────────────────────────────────────────────────

class _CardDetailSection extends ConsumerWidget {
  final NfcCard card;

  const _CardDetailSection({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Protocol Status Notice
        if (!card.canEmulateViaHce)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KF.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Requires Magic Card transfer for door locks (Layer 2 UID).',
                    style: TextStyle(fontSize: 12, color: KF.textMuted),
                  ),
                ),
              ],
            ),
          ),
        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: _DetailButton(
                icon: Icons.copy_rounded,
                label: 'Magic Card',
                onTap: () => _showMagicCardWriter(context, card),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailButton(
                icon: Icons.code_rounded,
                label: 'Hex Dump',
                onTap: () => _showHexModal(context, card),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailButton(
                icon: Icons.edit_rounded,
                label: 'Rename',
                onTap: () => _showRenameDialog(context, ref, card),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                color: KF.error,
                onTap: () => _confirmDelete(context, ref, card),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Specs List
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: KF.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KF.border),
          ),
          child: Column(
            children: [
              _SpecRow(label: 'Raw UID', value: card.uid),
              const Divider(color: KF.border, height: 16),
              _SpecRow(label: 'Protocol', value: card.typeBadge),
              const Divider(color: KF.border, height: 16),
              _SpecRow(
                label: 'Memory Dump',
                value: card.dumpData != null ? '${card.dumpData!.length} Bytes' : 'None',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMagicCardWriter(BuildContext context, NfcCard card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: KF.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _MagicCardWriteSheet(card: card),
    );
  }

  void _showHexModal(BuildContext context, NfcCard card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: KF.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hex Dump', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: KF.textPrimary)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KF.scaffold,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: KF.border),
                ),
                child: Text(
                  card.dumpData != null
                      ? card.dumpData!.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')
                      : 'UID: ${card.uid.replaceAll(':', ' ')}',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: KF.secondary),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, NfcCard card) {
    final controller = TextEditingController(text: card.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: KF.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Rename Card', style: GoogleFonts.spaceGrotesk(color: KF.textPrimary, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: KF.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter nickname',
            hintStyle: TextStyle(color: KF.textMuted),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: KF.textMuted))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(cardListProvider.notifier).update(
                  card.id,
                  (c) => c.copyWith(title: controller.text),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, NfcCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: KF.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Delete Card', style: GoogleFonts.spaceGrotesk(color: KF.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('Delete "${card.title}" from your vault?', style: const TextStyle(color: KF.textMuted, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: KF.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: KF.error),
            onPressed: () {
              ref.read(cardListProvider.notifier).remove(card.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DetailButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DetailButton({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KF.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: KF.border),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: color ?? KF.textMuted),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color ?? KF.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: KF.textMuted)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: KF.textPrimary, fontFamily: 'monospace')),
      ],
    );
  }
}

class _EmptyVaultState extends StatelessWidget {
  const _EmptyVaultState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KF.surfaceHigh,
                border: Border.all(color: KF.border),
              ),
              child: const Icon(Icons.nfc_rounded, size: 28, color: KF.textMuted),
            ),
            const SizedBox(height: 18),
            Text(
              'No cards in vault',
              style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w600, color: KF.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap "Add Card" to scan and clone an NFC access tag.',
              style: TextStyle(fontSize: 13, color: KF.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Live Scan Sheet with Auto-Prompt for Nickname ────────────────────────────

class _ScanSheet extends ConsumerStatefulWidget {
  const _ScanSheet();

  @override
  ConsumerState<_ScanSheet> createState() => _ScanSheetState();
}

class _ScanSheetState extends ConsumerState<_ScanSheet> {
  String _status = 'Hold card against phone...';
  NfcScanResult? _scannedResult;
  bool _scanning = true;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    final result = await NfcDetector.detectNfcTag();
    if (!mounted) return;

    if (result != null) {
      final defaultName = 'Key ${result.uid.substring(0, (result.uid.length).clamp(0, 4))}';
      _nameController.text = defaultName;

      setState(() {
        _scanning = false;
        _scannedResult = result;
        _status = 'Card Detected: ${result.uid}';
      });
    } else {
      setState(() {
        _status = 'Scan timed out. Tap to retry.';
        _scanning = false;
      });
    }
  }

  void _saveCard() {
    if (_scannedResult == null) return;
    final result = _scannedResult!;

    final newCard = NfcCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'NFC Key',
      type: switch (result.tag.type) {
        NFCTagType.iso7816 || NFCTagType.iso15693 => NfcCardType.isoDep,
        NFCTagType.mifare_classic => NfcCardType.mifareClassic,
        _ => NfcCardType.nfcA,
      },
      uid: result.uid,
      dumpData: result.dumpBytes,
      savedAt: DateTime.now(),
    );

    ref.read(cardListProvider.notifier).add(newCard);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: KF.surfaceHigh, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          if (_scanning || _scannedResult == null) ...[
            GestureDetector(
              onTap: _scanning ? null : () {
                setState(() { _scanning = true; _status = 'Hold card against phone...'; });
                _startScan();
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KF.surfaceHigh,
                  border: Border.all(color: KF.border),
                ),
                child: const Icon(Icons.nfc_rounded, size: 30, color: KF.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _scanning ? 'Scanning NFC Tag...' : 'Scan Ready',
              style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w600, color: KF.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(_status, style: const TextStyle(fontSize: 13, color: KF.textMuted)),
          ] else ...[
            // Auto-Prompt for Card Name Form
            Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: KF.secondary, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Card Captured',
                  style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w700, color: KF.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: KF.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Card Name / Nickname',
                labelStyle: const TextStyle(color: KF.textMuted, fontSize: 13),
                filled: true,
                fillColor: KF.scaffold,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: KF.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: KF.border)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _saveCard,
                child: const Text('Save to Vault', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Multi-Gen Magic Card Brute-Force & Rewrite Sheet ─────────────────────────

class _MagicCardWriteSheet extends StatefulWidget {
  final NfcCard card;
  const _MagicCardWriteSheet({required this.card});

  @override
  State<_MagicCardWriteSheet> createState() => _MagicCardWriteSheetState();
}

class _MagicCardWriteSheetState extends State<_MagicCardWriteSheet> {
  String _status = 'Hold target Magic Card / Fob against phone...';
  bool _writing = true;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _startWrite();
  }

  Future<void> _startWrite() async {
    final result = await MagicCardWriter.bruteForceAndRewriteBlock0(
      widget.card.uid,
      fullBlock0Data: widget.card.dumpData,
      onProgress: (step) {
        if (mounted) {
          setState(() {
            _status = step;
          });
        }
      },
    );

    if (!mounted) return;

    setState(() {
      _writing = false;
      _success = result.success;
      _status = result.success
          ? '${result.message} (${result.generation ?? "Magic Card"})'
          : result.message;
    });

    if (result.success) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: KF.surfaceHigh, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: KF.surfaceHigh,
              border: Border.all(color: _success ? KF.secondary : KF.border),
            ),
            child: Icon(
              _writing ? Icons.download_rounded : _success ? Icons.check_rounded : Icons.error_outline_rounded,
              size: 30,
              color: _writing ? KF.primary : _success ? KF.secondary : KF.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _writing ? 'Rewriting Block 0...' : _success ? 'Clone Successful' : 'Write Failed',
            style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w700, color: KF.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            _status,
            style: const TextStyle(fontSize: 12, color: KF.textMuted),
            textAlign: TextAlign.center,
          ),
          if (!_writing && !_success) ...[
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _writing = true;
                  _status = 'Hold target Magic Card / Fob against phone...';
                });
                _startWrite();
              },
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
