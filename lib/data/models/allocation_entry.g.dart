// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AllocationEntryAdapter extends TypeAdapter<AllocationEntry> {
  @override
  final int typeId = 4;

  @override
  AllocationEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AllocationEntry(
      courseId: fields[0] as String,
      courseName: fields[1] as String,
      amountApplied: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AllocationEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.courseId)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.amountApplied);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllocationEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
