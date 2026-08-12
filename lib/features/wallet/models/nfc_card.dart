import 'dart:typed_data';

/// NFC card types detected by the auto-detection pipeline
enum NfcCardType { isoDep, mifareClassic, nfcA, unknown }

/// Represents a saved NFC card in the vault
class NfcCard {
  final String id;
  final String title;
  final NfcCardType type;
  final String uid;
  final Uint8List? dumpData;
  final DateTime savedAt;

  const NfcCard({
    required this.id,
    required this.title,
    required this.type,
    required this.uid,
    this.dumpData,
    required this.savedAt,
  });

  /// Masked UID for display: "AB:CD:••:••"
  String get maskedUid {
    final parts = uid.split(':');
    if (parts.length <= 2) return uid;
    final visible = parts.take(2).join(':');
    final hidden = List.filled(parts.length - 2, '••').join(':');
    return '$visible:$hidden';
  }

  /// Human-readable card type badge
  String get typeBadge => switch (type) {
    NfcCardType.isoDep => 'ISO 14443-4',
    NfcCardType.mifareClassic => 'MIFARE Classic',
    NfcCardType.nfcA => '13.56 MHz',
    NfcCardType.unknown => 'Unknown',
  };

  /// Whether this protocol is natively emulatable on Android stock HCE
  bool get canEmulateViaHce => type == NfcCardType.isoDep;

  NfcCard copyWith({String? title, Uint8List? dumpData}) => NfcCard(
    id: id,
    title: title ?? this.title,
    type: type,
    uid: uid,
    dumpData: dumpData ?? this.dumpData,
    savedAt: savedAt,
  );
}
