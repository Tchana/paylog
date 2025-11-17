// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrollment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnrollmentAdapter extends TypeAdapter<Enrollment> {
  @override
  final int typeId = 5;

  @override
  Enrollment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Enrollment(
      id: fields[0] as String?,
      programId: fields[1] as String,
      courseId: fields[2] as String,
      memberId: fields[3] as String,
      amountPaid: fields[4] as double,
    )..updatedAt = fields[6] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Enrollment obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.programId)
      ..writeByte(2)
      ..write(obj.courseId)
      ..writeByte(3)
      ..write(obj.memberId)
      ..writeByte(4)
      ..write(obj.amountPaid)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnrollmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
