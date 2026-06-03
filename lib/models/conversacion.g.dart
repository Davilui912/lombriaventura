// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversacion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversacionAdapter extends TypeAdapter<Conversacion> {
  @override
  final int typeId = 0;

  @override
  Conversacion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Conversacion(
      id: fields[0] as String,
      titulo: fields[1] as String,
      fecha: fields[2] as DateTime,
      mensajes: (fields[3] as List)
          .map((dynamic e) => (e as Map).cast<String, String>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, Conversacion obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titulo)
      ..writeByte(2)
      ..write(obj.fecha)
      ..writeByte(3)
      ..write(obj.mensajes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversacionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
