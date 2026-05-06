import 'dart:math';
import 'package:intl/intl.dart';

/// Generate a unique appointment ID in format QE-XXXX
String generateAppointmentId() {
  final random = Random();
  final number = random.nextInt(9000) + 1000; // 1000–9999
  return 'QE-$number';
}

/// Format a DateTime to a readable date string (e.g., "Oct 24")
String formatDate(DateTime date) {
  return DateFormat('MMM d').format(date);
}

/// Format a DateTime to full readable date (e.g., "Mon, Oct 12")
String formatFullDate(DateTime date) {
  return DateFormat('EEE, MMM d').format(date);
}

/// Format a DateTime to date with year (e.g., "Oct 26, 2023")
String formatDateWithYear(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

/// Get the day abbreviation (e.g., "MON")
String getDayAbbr(DateTime date) {
  return DateFormat('EEE').format(date).toUpperCase();
}

/// Check if a date is today
bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

/// Check if a date is in the past (before today)
bool isPastDate(DateTime date) {
  final today = DateTime.now();
  final dateOnly = DateTime(date.year, date.month, date.day);
  final todayOnly = DateTime(today.year, today.month, today.day);
  return dateOnly.isBefore(todayOnly);
}

/// Get the next 7 days starting from today
List<DateTime> getNextSevenDays() {
  final today = DateTime.now();
  return List.generate(7, (i) => today.add(Duration(days: i)));
}

/// Check if a time slot (e.g., "10:00 AM") is in the past for a given date.
/// Returns true only when [date] is today AND the slot time has already passed.
bool isSlotPast(DateTime date, String timeSlot) {
  if (!isToday(date)) return false;

  final now = DateTime.now();

  // Parse the time slot string (format: "HH:MM AM/PM")
  final parts = timeSlot.split(' '); // ["10:00", "AM"]
  final timeParts = parts[0].split(':'); // ["10", "00"]
  int hour = int.parse(timeParts[0]);
  final int minute = int.parse(timeParts[1]);
  final period = parts[1].toUpperCase();

  // Convert 12-hour to 24-hour format
  if (period == 'PM' && hour != 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;

  final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
  return slotTime.isBefore(now);
}
