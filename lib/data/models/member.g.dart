// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemberAdapter extends TypeAdapter<Member> {
  @override
  final int typeId = 2;

  @override
  Member read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Member(
      id: fields[0] as String?,
      programId: fields[1] as String,
      name: fields[2] as String,
      contactInfo: fields[3] as String?,
      accountBalance: fields[4] as double,
      totalDebt: fields[5] as double,
    )..updatedAt = fields[7] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Member obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.programId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.contactInfo)
      ..writeByte(4)
      ..write(obj.accountBalance)
      ..writeByte(5)
      ..write(obj.totalDebt)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
