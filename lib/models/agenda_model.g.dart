// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AgendaModelAdapter extends TypeAdapter<AgendaModel> {
  @override
  final int typeId = 0;

  @override
  AgendaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AgendaModel(
      title: fields[0] as String,
      category: fields[1] as String?,
      status: fields[2] as bool,
      deadline: fields[3] as DateTime,
      selected: fields[4] as bool,
      description: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AgendaModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.deadline)
      ..writeByte(4)
      ..write(obj.selected)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgendaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
