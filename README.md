<div align="center">

# KeyForge

**Offline, Secure 13.56 MHz NFC Access Card Manager & Cloner for Android**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Android API](https://img.shields.io/badge/Android-API%2026%2B-3DDC84?logo=android)](https://developer.android.com)
[![Encryption](https://img.shields.io/badge/KeyStore-AES--256%20GCM-blueviolet)]()
[![Zero Cloud](https://img.shields.io/badge/Storage-100%25%20Offline-success)]()

</div>

---

## Overview

**KeyForge** is an open-source Android security utility designed for reading, managing, emulating, and cloning 13.56 MHz high-frequency (HF) RFID and NFC access cards, key fobs, and smart tokens directly from your smartphone.

Engineered with a strict **Zero-Cloud, 100% Offline** architecture, all card profiles and binary dumps are stored exclusively inside a local [Hive](https://pub.dev/packages/hive) database encrypted with a **256-bit AES master key backed by the Android Hardware KeyStore**.

---

## Core Capabilities

### 1. Multi-Protocol Hardware Probing
KeyForge executes a sequential auto-detection pipeline on scanned physical tags:
* **ISO 14443-4 (IsoDep):** Identifies Smart Cards, sends standard `SELECT AID` APDUs, and extracts application descriptors.
* **MIFARE Classic 1K / 4K:** Executes automated dictionary authentication against **50+ well-known default factory keys** (`FFFFFFFFFFFF`, `A0A1A2A3A4A5`, etc.) across all 16/32 sectors.
* **Generic NFC-A / ISO 14443-3A:** Extracts raw 4-byte / 7-byte hardware UID (CSN), ATQA, and SAK descriptors.

### 2. Multi-Gen Magic Card Cloning (Block 0 Rewriter)
Allows physical cloning of scanned cards to rewritable **Magic Cards & Fobs** by brute-forcing through all known write vectors:
* **Gen 2 (CUID / Direct):** Direct Block 0 overwrite using standard `0xA0` and `0xA2` write commands without backdoor requirement.
* **Gen 1 (UID / Chinese Backdoor):** Executes backdoor unlock sequence (`0x40` & `0x43`) to bypass standard OTP locks.
* **Gen 3 (UFUID / APDU Envelope):** Wrapped APDU write command execution.

### 3. Silent Background Host Card Emulation (HCE)
* Android `HostApduService` integration allows silent broadcasting of smart card APDU payloads to compatible terminals in the background as long as the phone's NFC is enabled.
* Seamless payload swapping when swiping through cards in the wallet view.

### 4. Minimalist Obsidian Nexus UI
* Modern, dark-mode card carousel with fluid spring physics (`BouncingScrollPhysics`).
* Dynamic procedural access card badges (Cyber Stealth, Titanium Industrial, Facility Pass, Root Key) featuring RFID antenna graphics, security barcodes, and etched monospace UIDs.
* Real-time NFC status detection (gated access when NFC is disabled, auto-prompt for nickname upon card capture).
* Built-in Hex Dump Inspector, Rename dialog, and card management.

---

## Architecture & Tech Stack

```
lib/
├── core/
│   ├── security/               # Android Hardware KeyStore AES-256 derivation
│   └── theme.dart              # Space Grotesk typography & Obsidian dark tokens
├── features/
│   ├── nfc_engine/
│   │   ├── nfc_detector.dart   # Sequential auto-detection pipeline
│   │   ├── mifare_dictionary.dart # 50+ MIFARE Classic default keys
│   │   ├── magic_card_writer.dart # Multi-generation Magic Card Block 0 rewriter
│   │   ├── hce_service.dart    # MethodChannel bridge for HostApduService
│   │   └── nfc_status_provider.dart # Real-time NFC hardware availability stream
│   ├── wallet/
│   │   ├── models/nfc_card.dart# Card data model & protocol capability checks
│   │   ├── state/wallet_providers.dart # Riverpod vault state
│   │   └── views/wallet_screen.dart # Minimalist swipeable card carousel & action sheet
│   ├── history/                # Scanned card audit logs
│   ├── security/               # KeyStore health & encryption diagnostics
│   └── settings/               # NFC controller diagnostics & wordlist configuration
└── main.dart                   # Root ProviderScope & 4-tab shell
```

---

## Current Technical Constraints

| Constraint | Root Cause | Solution / Workaround |
|---|---|---|
| **Stock Android HCE Cannot Unlock Physical Door Locks** | Physical door readers authenticate against the **physical hardware UID at Layer 2 (anticollision cascade)**. Android's NFC controller randomizes the UID (`08:xx:xx:xx`) for anti-tracking privacy and only allows Layer 4 APDU emulation. | Use KeyForge's **"Write to Magic Card"** feature to clone the UID onto a physical **CUID / Gen2 Magic Card / Fob ($1)**. |
| **Nested / Hardnested Key Cracking Not Supported on Phone** | Android NFC drivers (NXP / Broadcom) do not expose microsecond radio timing or raw parity bits required for cryptographic PRNG exploit attacks (Darkside / Nested). | Use dictionary attacks in KeyForge for default keys. For custom-keyed cards, dump via **Proxmark3 / Flipper Zero** and import the `.bin` / `.mfd` dump into KeyForge. |
| **OTP Standard Tags are Permanently Read-Only for Block 0** | Genuine NXP MIFARE chips fuse Block 0 at the factory with one-time-programmable silicon fuses. | Standard cards cannot have their UID rewritten. Must use rewritable Magic Cards (CUID/UID). |

---

## Future Roadmap

- [ ] **Dump Import & Export:** Full `.mfd`, `.bin`, and Flipper Zero `.nfc` file import/export.
- [ ] **Custom Dictionary Manager:** Allow users to import custom wordlists and `.dic` files for sector key cracking.
- [ ] **Rooted / Magisk NFC UID Spoofing:** Optional module for rooted devices with NXP controllers to override `libnfc-nci.conf` and spoof raw Layer 2 UIDs directly from the phone.
- [ ] **Proxmark3 Bluetooth Bridge:** Direct wireless pairing with Proxmark3 RDV4 over BLE for executing on-device Nested/Hardnested cryptographic attacks.
- [ ] **NDEF Record Editor:** Read, write, and format NFC tags with custom URLs, WiFi credentials, text, and vCards.

---

## Getting Started

### Prerequisites
* Flutter SDK `^3.12.0` (Dart 3.x)
* Android Studio / Android SDK (minSdk `26` / Android 8.0+)
* Physical Android smartphone with NFC hardware enabled

### Installation & Build
```bash
# Clone the repository
git clone https://github.com/RuumiDev/KeyForge.git
cd KeyForge

# Fetch dependencies
flutter pub get

# Generate Hive model adapters
dart run build_runner build --delete-conflicting-outputs

# Connect phone with USB Debugging enabled and run
flutter run
```

---

## Legal & Educational Disclaimer

KeyForge is developed solely for **authorized security testing, educational research, personal card backup, and penetration testing engagements**. Do not attempt to clone or access facilities, door locks, or systems without explicit prior authorization from the property owner. The authors assume no liability for misuse.

---

## License

MIT License — Copyright (c) 2026 RuumiDev
