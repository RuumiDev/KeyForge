// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardProfileAdapter extends TypeAdapter<CardProfile> {
  @override
  final int typeId = 0;

  @override
  CardProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardProfile(
      id: fields[0] as String,
      nickname: fields[1] as String,
      uidHex: fields[2] as String,
      protocolType: fields[3] as String,
      sectorData: (fields[4] as Map).cast<String, String>(),
      rawDump: fields[5] as Uint8List?,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CardProfile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.uidHex)
      ..writeByte(3)
      ..write(obj.protocolType)
      ..writeByte(4)
      ..write(obj.sectorData)
      ..writeByte(5)
      ..write(obj.rawDump)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
