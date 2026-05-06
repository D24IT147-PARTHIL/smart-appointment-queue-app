import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/hive_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Central state management provider for appointments and queue
class AppointmentProvider extends ChangeNotifier {
  // ─── State Variables ───────────────────────────────────────────
  List<Appointment> _appointments = [];
  String _searchQuery = '';
  String _filterStatus = 'All';
  String _filterServiceType = 'All';
  String _filterDateRange = 'All';

  // ─── Getters ───────────────────────────────────────────────────

  /// All appointments
  List<Appointment> get appointments => _appointments;

  /// Current search query
  String get searchQuery => _searchQuery;

  /// Current status filter
  String get filterStatus => _filterStatus;

  /// Current service type filter
  String get filterServiceType => _filterServiceType;

  /// Current date range filter
  String get filterDateRange => _filterDateRange;

  /// Get the currently active (In Progress) appointment
  Appointment? get currentServingAppointment {
    try {
      return _appointments.firstWhere(
        (a) => a.status == AppointmentStatus.inProgress,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get all scheduled (waiting) appointments, sorted by queue number
  List<Appointment> get waitingAppointments {
    return _appointments
        .where((a) => a.status == AppointmentStatus.scheduled)
        .toList()
      ..sort((a, b) => a.queueNumber.compareTo(b.queueNumber));
  }

  /// Get completed appointments count
  int get todayCompletedCount {
    return _appointments.where((a) => a.status == AppointmentStatus.completed).length;
  }

  /// Get cancelled appointments count
  int get todayCancelledCount {
    return _appointments.where((a) => a.status == AppointmentStatus.cancelled).length;
  }

  /// Get total appointments count
  int get todayTotalCount {
    return _appointments.length;
  }

  /// Get appointments filtered by search and filters
  List<Appointment> get filteredAppointments {
    List<Appointment> result = List.from(_appointments);

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      result = result.where((a) {
        return a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            a.id.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (_filterStatus != 'All') {
      result = result.where((a) => a.status == _filterStatus).toList();
    }

    // Apply service type filter
    if (_filterServiceType != 'All') {
      result =
          result.where((a) => a.serviceType == _filterServiceType).toList();
    }

    // Apply date range filter
    if (_filterDateRange != 'All') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (_filterDateRange == 'Today') {
        result = result.where((a) {
          final aDate = DateTime(a.date.year, a.date.month, a.date.day);
          return aDate.isAtSameMomentAs(today);
        }).toList();
      } else if (_filterDateRange == 'Tomorrow') {
        final tomorrow = today.add(const Duration(days: 1));
        result = result.where((a) {
          final aDate = DateTime(a.date.year, a.date.month, a.date.day);
          return aDate.isAtSameMomentAs(tomorrow);
        }).toList();
      } else if (_filterDateRange == 'This Week') {
        final endOfWeek = today.add(const Duration(days: 7));
        result = result.where((a) {
          final aDate = DateTime(a.date.year, a.date.month, a.date.day);
          return !aDate.isBefore(today) && aDate.isBefore(endOfWeek);
        }).toList();
      }
    }

    // Sort by creation date (newest first)
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  /// Get today's appointments
  List<Appointment> get todayAppointments {
    final now = DateTime.now();
    return _appointments.where((a) {
      return a.date.year == now.year &&
          a.date.month == now.month &&
          a.date.day == now.day;
    }).toList()
      ..sort((a, b) => a.queueNumber.compareTo(b.queueNumber));
  }

  /// Get upcoming appointments (future dates)
  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _appointments.where((a) {
      final aDate = DateTime(a.date.year, a.date.month, a.date.day);
      return aDate.isAfter(today);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get past appointments
  List<Appointment> get pastAppointments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _appointments.where((a) {
      final aDate = DateTime(a.date.year, a.date.month, a.date.day);
      return aDate.isBefore(today) ||
          a.status == AppointmentStatus.completed ||
          a.status == AppointmentStatus.cancelled;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ─── Actions ───────────────────────────────────────────────────

  /// Load all appointments from Hive on startup
  void loadAppointments() {
    _appointments = HiveService.getAllAppointments();

    // Dynamically regenerate queue numbers for scheduled appointments based on chronological order
    final scheduled = _appointments
        .where((a) => a.status == AppointmentStatus.scheduled)
        .toList();

    scheduled.sort((a, b) {
      final aDateTime = getSlotDateTime(a.date, a.timeSlot);
      final bDateTime = getSlotDateTime(b.date, b.timeSlot);
      final cmp = aDateTime.compareTo(bDateTime);
      if (cmp != 0) return cmp;

      return a.createdAt.compareTo(b.createdAt);
    });

    for (int i = 0; i < scheduled.length; i++) {
      if (scheduled[i].queueNumber != i + 1) {
        scheduled[i].queueNumber = i + 1;
        HiveService.updateAppointment(scheduled[i]);
      }
    }

    notifyListeners();
  }

  /// Book a new appointment
  /// Returns null on success, or an error message string on failure
  Future<String?> bookAppointment({
    required String name,
    required String serviceType,
    required DateTime date,
    required String timeSlot,
  }) async {
    // Validate inputs
    if (name.trim().isEmpty) return 'Please enter your name';
    if (serviceType.isEmpty) return 'Please select a service type';
    if (timeSlot.isEmpty) return 'Please select a time slot';

    // Validate date is not in the past
    if (isPastDate(date)) return 'Cannot book appointments for past dates';

    // Check slot conflict (max 5 per slot)
    final slotCount = HiveService.countAppointmentsForSlot(date, timeSlot);
    if (slotCount >= maxAppointmentsPerSlot) {
      return 'Selected time slot is fully booked';
    }

    // Generate unique ID (ensure no duplicates)
    String id = generateAppointmentId();
    while (_appointments.any((a) => a.id == id)) {
      id = generateAppointmentId();
    }

    // Assign queue number
    final queueNumber = HiveService.getNextQueueNumber();

    // Create appointment
    final appointment = Appointment(
      id: id,
      name: name.trim(),
      serviceType: serviceType,
      date: date,
      timeSlot: timeSlot,
      status: AppointmentStatus.scheduled,
      queueNumber: queueNumber,
      createdAt: DateTime.now(),
    );

    // Save to Hive
    await HiveService.addAppointment(appointment);

    // Reload appointments
    loadAppointments();
    return null; // Success
  }

  /// Mark an appointment as In Progress
  Future<void> markInProgress(String id) async {
    final appointment = _appointments.firstWhere((a) => a.id == id);
    appointment.status = AppointmentStatus.inProgress;
    await HiveService.updateAppointment(appointment);
    loadAppointments();
  }

  /// Mark an appointment as Completed
  Future<void> markCompleted(String id) async {
    final appointment = _appointments.firstWhere((a) => a.id == id);
    appointment.status = AppointmentStatus.completed;
    await HiveService.updateAppointment(appointment);
    loadAppointments();
  }

  /// Mark an appointment as Cancelled
  Future<void> markCancelled(String id) async {
    final appointment = _appointments.firstWhere((a) => a.id == id);
    appointment.status = AppointmentStatus.cancelled;
    await HiveService.updateAppointment(appointment);
    loadAppointments();
  }

  /// Complete current appointment and move next in queue to In Progress
  Future<void> completeAndMoveNext() async {
    // Complete current serving appointment
    final current = currentServingAppointment;
    if (current != null) {
      current.status = AppointmentStatus.completed;
      await HiveService.updateAppointment(current);
    }

    // Move next waiting appointment to In Progress
    final waiting = waitingAppointments;
    if (waiting.isNotEmpty) {
      waiting.first.status = AppointmentStatus.inProgress;
      await HiveService.updateAppointment(waiting.first);
    }

    loadAppointments();
  }

  /// Call next person in queue (set to In Progress)
  Future<void> callNextInQueue() async {
    final waiting = waitingAppointments;
    if (waiting.isNotEmpty) {
      waiting.first.status = AppointmentStatus.inProgress;
      await HiveService.updateAppointment(waiting.first);
    }
    loadAppointments();
  }

  /// Cancel current appointment and move next
  Future<void> cancelCurrentAndMoveNext() async {
    final current = currentServingAppointment;
    if (current != null) {
      current.status = AppointmentStatus.cancelled;
      await HiveService.updateAppointment(current);
    }

    final waiting = waitingAppointments;
    if (waiting.isNotEmpty) {
      waiting.first.status = AppointmentStatus.inProgress;
      await HiveService.updateAppointment(waiting.first);
    }

    loadAppointments();
  }

  /// Get queue position for a specific appointment
  int getQueuePosition(String appointmentId) {
    final waiting = waitingAppointments;
    final index = waiting.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return 0;
    return index + 1;
  }

  /// Get estimated wait time for a specific appointment (in minutes)
  int getEstimatedWaitTime(String appointmentId) {
    final position = getQueuePosition(appointmentId);
    return position * minutesPerAppointment;
  }

  /// Get number of people ahead in queue
  int getPeopleAhead(String appointmentId) {
    final position = getQueuePosition(appointmentId);
    return position > 0 ? position - 1 : 0;
  }

  // ─── Search & Filter ──────────────────────────────────────────

  /// Update search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Update status filter
  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  /// Update service type filter
  void setFilterServiceType(String serviceType) {
    _filterServiceType = serviceType;
    notifyListeners();
  }

  /// Update date range filter
  void setFilterDateRange(String dateRange) {
    _filterDateRange = dateRange;
    notifyListeners();
  }

  /// Reset all filters
  void resetFilters() {
    _searchQuery = '';
    _filterStatus = 'All';
    _filterServiceType = 'All';
    _filterDateRange = 'All';
    notifyListeners();
  }

  /// Get average wait time for today
  int get averageWaitTimeToday {
    final waiting = waitingAppointments.length;
    final inProg = currentServingAppointment != null ? 1 : 0;
    return (waiting + inProg) * minutesPerAppointment;
  }
}
