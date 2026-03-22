// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vial.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VialAdapter extends TypeAdapter<Vial> {
  @override
  final int typeId = 0;

  @override
  Vial read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vial(
      compoundName: fields[0] as String,
      dosage: fields[1] as double,
      unit: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Vial obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.compoundName)
      ..writeByte(1)
      ..write(obj.dosage)
      ..writeByte(2)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
