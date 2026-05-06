import 'package:hive/hive.dart';

part 'appointment.g.dart';

/// Appointment model stored in Hive local database
@HiveType(typeId: 0)
class Appointment extends HiveObject {
  /// Unique appointment ID (format: QE-XXXX)
  @HiveField(0)
  final String id;

  /// Customer name
  @HiveField(1)
  final String name;

  /// Type of service requested
  @HiveField(2)
  final String serviceType;

  /// Appointment date
  @HiveField(3)
  final DateTime date;

  /// Selected time slot (e.g., "10:00 AM")
  @HiveField(4)
  final String timeSlot;

  /// Current status: Scheduled, In Progress, Completed, Cancelled
  @HiveField(5)
  String status;

  /// Queue number assigned at booking time
  @HiveField(6)
  int queueNumber;

  /// Timestamp when appointment was created
  @HiveField(7)
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.queueNumber,
    required this.createdAt,
  });
}
