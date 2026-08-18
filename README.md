<div align="center">

<img src="public/assets/keyForgeBanner.gif" width="100%" alt="KeyForge Banner" />

# KeyForge

**Offline, Secure 13.56 MHz NFC Access Card Manager & Cloner for Android**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&style=flat-square)](https://flutter.dev)
[![Android API](https://img.shields.io/badge/Android-API%2026%2B-3DDC84?logo=android&style=flat-square)](https://developer.android.com)
[![Encryption](https://img.shields.io/badge/Vault-AES--256%20GCM-blueviolet?style=flat-square)]()
[![Zero Cloud](https://img.shields.io/badge/Data-100%25%20Offline-success?style=flat-square)]()

</div>

---

## ⚡ Core Capabilities

*   **Multi-Protocol Hardware Probing:**
    *   **ISO 14443-4 (IsoDep):** Identifies Smart Cards, sends standard `SELECT AID` APDUs, and extracts application descriptors.
    *   **MIFARE Classic 1K / 4K:** Executes automated dictionary authentication against **50+ well-known default factory keys** (`FFFFFFFFFFFF`, `A0A1A2A3A4A5`, etc.) across all 16/32 sectors.
    *   **Generic NFC-A / ISO 14443-3A:** Extracts raw 4-byte / 7-byte hardware UID (CSN), ATQA, and SAK descriptors.
*   **Multi-Gen Magic Card Cloning:**
    *   **Gen 2 (CUID / Direct):** Direct Block 0 overwrite using standard `0xA0` and `0xA2` write commands without backdoor requirements.
    *   **Gen 1 (UID / Chinese Backdoor):** Executes backdoor unlock sequence (`0x40` & `0x43`) to bypass standard OTP locks.
    *   **Gen 3 (UFUID / APDU Envelope):** Wrapped APDU write command execution.
*   **Silent Background Host Card Emulation (HCE):**
    *   Android `HostApduService` integration allows silent broadcasting of smart card APDU payloads to compatible terminals in the background.
    *   Seamless payload swapping when swiping through cards in the wallet view.
*   **Minimalist Obsidian Nexus UI:**
    *   Modern, dark-mode card carousel with fluid spring physics.
    *   Dynamic procedural access card designs (Cyber Stealth, Titanium Industrial, Facility Pass, Root Key) featuring RFID antenna graphics, security barcodes, and etched monospace UIDs.
    *   Real-time NFC status detection (gated access when NFC is disabled, auto-prompt for nickname upon card capture).

---

## 🔐 Architecture & Security

KeyForge operates on a **strictly offline model with zero network permissions**.

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
```

*   **Encryption:** All card profiles and binary dumps are stored inside a local [Hive](https://pub.dev/packages/hive) database encrypted with a **256-bit AES master key backed by the Android Hardware KeyStore**.

---

## ⚠️ Hardware Constraints

*   **Android HCE Limitation:** Android's NFC controller randomizes the UID (`08:xx:xx:xx`) at Layer 2 (anticollision cascade) for anti-tracking privacy. Standard door readers check this hardware UID before executing Layer 4 APDUs. **Stock Android HCE cannot spoof raw UIDs.** Use KeyForge to clone the UID onto a physical **CUID / Gen 2 Magic Card / Fob ($1)** instead.
*   **On-Device Cracking Limitations:** Android NFC drivers (NXP / Broadcom) do not expose microsecond radio timing or raw parity bits required for cryptographic PRNG exploit attacks (Darkside / Nested). KeyForge uses dictionary attacks for default keys. For custom-keyed cards, dump via **Proxmark3 / Flipper Zero** and import the `.bin` / `.mfd` dump.
*   **OTP Standard Tags:** Standard tags have their Block 0 permanently fused at the semiconductor factory. UIDs cannot be rewritten on standard cards.

---

## 🚀 Future Roadmap

*   **Dump Import & Export:** Full `.mfd`, `.bin`, and Flipper Zero `.nfc` file import/export.
*   **Custom Dictionary Manager:** Allow users to import custom wordlists and `.dic` files for sector key cracking.
*   **Rooted / Magisk NFC UID Spoofing:** Optional module for rooted devices with NXP controllers to override `libnfc-nci.conf` and spoof raw Layer 2 UIDs directly from the phone.
*   **Proxmark3 Bluetooth Bridge:** Direct wireless pairing with Proxmark3 RDV4 over BLE for executing on-device Nested/Hardnested cryptographic attacks.
*   **NDEF Record Editor:** Read, write, and format NFC tags with custom URLs, WiFi credentials, text, and vCards.

---

## 🛠️ Getting Started

### Prerequisites
*   Flutter SDK `^3.12.0` (Dart 3.x)
*   Android Studio / Android SDK (minSdk `26` / Android 8.0+)
*   Physical Android smartphone with NFC hardware enabled

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

## ⚖️ Legal & Educational Disclaimer

KeyForge is developed solely for **authorized security testing, educational research, personal card backup, and penetration testing engagements**. Do not attempt to clone or access facilities, door locks, or systems without explicit prior authorization from the property owner. The authors assume no liability for misuse.

---

## 📄 License

MIT License — Copyright (c) 2026 RuumiDev
