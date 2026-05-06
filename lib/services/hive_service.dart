import 'package:hive_flutter/hive_flutter.dart';
import '../models/appointment.dart';

/// Service class to handle all Hive database operations
class HiveService {
  static const String _boxName = 'appointments';

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AppointmentAdapter());
    await Hive.openBox<Appointment>(_boxName);
  }

  /// Get the appointments box
  static Box<Appointment> get _box => Hive.box<Appointment>(_boxName);

  /// Get all appointments from local storage
  static List<Appointment> getAllAppointments() {
    return _box.values.toList();
  }

  /// Add a new appointment to local storage
  static Future<void> addAppointment(Appointment appointment) async {
    await _box.put(appointment.id, appointment);
  }

  /// Update an existing appointment in local storage
  static Future<void> updateAppointment(Appointment appointment) async {
    await appointment.save();
  }

  /// Delete an appointment from local storage
  static Future<void> deleteAppointment(String id) async {
    await _box.delete(id);
  }

  /// Get the next queue number (max existing + 1)
  static int getNextQueueNumber() {
    if (_box.isEmpty) return 1;
    final maxQueue = _box.values
        .map((a) => a.queueNumber)
        .reduce((a, b) => a > b ? a : b);
    return maxQueue + 1;
  }

  /// Count appointments for a specific date and time slot
  static int countAppointmentsForSlot(DateTime date, String timeSlot) {
    return _box.values.where((a) {
      return a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day &&
          a.timeSlot == timeSlot &&
          a.status != 'Cancelled';
    }).length;
  }
}
