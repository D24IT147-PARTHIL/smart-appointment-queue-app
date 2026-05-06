import 'package:flutter/material.dart';

/// App-wide color constants matching the QueueEase design
class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF6C3CE1); // Deep purple
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF4C1D95);

  // Status colors
  static const Color scheduled = Color(0xFF3B82F6); // Blue
  static const Color inProgress = Color(0xFFF97316); // Orange
  static const Color completed = Color(0xFF22C55E); // Green
  static const Color cancelled = Color(0xFFEF4444); // Red

  // Neutral colors
  static const Color background = Color(0xFFF8F9FC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
}

/// Appointment status values
class AppointmentStatus {
  static const String scheduled = 'Scheduled';
  static const String inProgress = 'In Progress';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';

  /// Get color for a given status
  static Color getColor(String status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return AppColors.scheduled;
      case AppointmentStatus.inProgress:
        return AppColors.inProgress;
      case AppointmentStatus.completed:
        return AppColors.completed;
      case AppointmentStatus.cancelled:
        return AppColors.cancelled;
      default:
        return AppColors.textSecondary;
    }
  }
}

/// Available service types
class ServiceTypes {
  static const List<String> all = [
    'Regular Checkup',
    'Follow-up Consultation',
    'Vaccination',
    'General Consultation',
    'Emergency Consultation',
  ];
}

/// Available time slots
class TimeSlots {
  static const List<String> all = [
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
  ];
}

/// Maximum appointments allowed per time slot
const int maxAppointmentsPerSlot = 2;

/// Estimated minutes per appointment for queue calculation
const int minutesPerAppointment = 10;
