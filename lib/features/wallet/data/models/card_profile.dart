import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'card_profile.g.dart';

@HiveType(typeId: 0)
class CardProfile {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String nickname;
  @HiveField(2)
  final String uidHex;
  @HiveField(3)
  final String protocolType;
  @HiveField(4)
  final Map<String, String> sectorData;
  @HiveField(5)
  final Uint8List? rawDump;
  @HiveField(6)
  final DateTime createdAt;

  CardProfile({
    required this.id,
    required this.nickname,
    required this.uidHex,
    required this.protocolType,
    required this.sectorData,
    this.rawDump,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'uidHex': uidHex,
    'protocolType': protocolType,
    'sectorData': sectorData,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CardProfile.fromJson(Map<String, dynamic> json) => CardProfile(
    id: json['id'],
    nickname: json['nickname'],
    uidHex: json['uidHex'],
    protocolType: json['protocolType'],
    sectorData: Map<String, String>.from(json['sectorData']),
    createdAt: DateTime.parse(json['createdAt']),
  );

  Uint8List toBinaryDump() => rawDump ?? Uint8List(0);

  static CardProfile fromBinaryDump(Uint8List dump, String id, String nickname) {
    return CardProfile(
      id: id,
      nickname: nickname,
      uidHex: '00000000', // Need parsing logic
      protocolType: 'Unknown',
      sectorData: {},
      rawDump: dump,
      createdAt: DateTime.now(),
    );
  }
}
