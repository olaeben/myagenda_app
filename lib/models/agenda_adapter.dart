import 'package:hive/hive.dart';
import 'agenda_model.dart';

class AgendaAdapter extends TypeAdapter<AgendaModel> {
  @override
  final int typeId = 0;

  @override
  AgendaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return AgendaModel(
      title: fields[0] as String,
      category: fields[1] as String?,
      status: fields[2] as bool,
      deadline: DateTime.parse(fields[3] as String),
      selected: fields[4] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AgendaModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.deadline.toIso8601String())
      ..writeByte(4)
      ..write(obj.selected);
  }
}
