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
      id: fields[9] as String?,
      title: fields[0] as String,
      category: fields[1] as String?,
      status: fields[2] as bool,
      deadline: fields[3] is String 
          ? DateTime.parse(fields[3] as String) 
          : fields[3] as DateTime,
      selected: fields[4] as bool? ?? false,
      description: fields[5] as String?,
      createdAt: fields[6] is String 
          ? DateTime.parse(fields[6] as String) 
          : fields[6] as DateTime,
      notificationFrequency: fields[7] as String? ?? 'Daily',
      updatedAt: fields[8] is String 
          ? DateTime.parse(fields[8] as String) 
          : fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AgendaModel obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.notificationFrequency)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.id);
  }
}
