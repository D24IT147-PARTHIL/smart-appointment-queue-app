// GENERATED CODE - Hand-written Hive TypeAdapter for Appointment

part of 'appointment.dart';

/// TypeAdapter for serializing/deserializing Appointment to Hive
class AppointmentAdapter extends TypeAdapter<Appointment> {
  @override
  final int typeId = 0;

  @override
  Appointment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Appointment(
      id: fields[0] as String,
      name: fields[1] as String,
      serviceType: fields[2] as String,
      date: fields[3] as DateTime,
      timeSlot: fields[4] as String,
      status: fields[5] as String,
      queueNumber: fields[6] as int,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Appointment obj) {
    writer
      ..writeByte(8) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.serviceType)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.timeSlot)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.queueNumber)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
