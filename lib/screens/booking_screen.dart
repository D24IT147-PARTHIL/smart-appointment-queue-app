import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/time_slot_picker.dart';
import '../services/hive_service.dart';

/// Booking screen — Schedule Your Visit form
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _nameController = TextEditingController();
  String _selectedService = ServiceTypes.all.first;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  final List<DateTime> _availableDates = getNextSevenDays();

  @override
  void initState() {
    super.initState();
    _selectedDate = _availableDates.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Map<String, int> _getSlotCounts() {
    if (_selectedDate == null) return {};
    final counts = <String, int>{};
    for (final slot in TimeSlots.all) {
      counts[slot] = HiveService.countAppointmentsForSlot(_selectedDate!, slot);
    }
    return counts;
  }

  /// Get the set of past time slots for the currently selected date.
  /// Only returns non-empty when today is selected.
  Set<String> _getPastSlots() {
    if (_selectedDate == null) return {};
    final past = <String>{};
    for (final slot in TimeSlots.all) {
      if (isSlotPast(_selectedDate!, slot)) {
        past.add(slot);
      }
    }
    return past;
  }

  Future<void> _handleBooking() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your name');
      return;
    }
    if (_selectedDate == null) {
      _showError('Please select a date');
      return;
    }
    if (_selectedTimeSlot == null) {
      _showError('Please select a time slot');
      return;
    }

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final error = await provider.bookAppointment(
      name: _nameController.text,
      serviceType: _selectedService,
      date: _selectedDate!,
      timeSlot: _selectedTimeSlot!,
    );

    if (error != null) {
      _showError(error);
    } else {
      final newAppt = provider.appointments.last;
      _showConfirmation(newAppt);
      setState(() {
        _nameController.clear();
        _selectedService = ServiceTypes.all.first;
        _selectedTimeSlot = null;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.cancelled,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showConfirmation(dynamic appointment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.completed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.completed, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('Appointment Booked!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Your appointment ID is #${appointment.id}',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Queue Number: ${appointment.queueNumber}',
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slotCounts = _getSlotCounts();
    final pastSlots = _getPastSlots();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              const Text('Schedule Your Visit',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text('Fill in the details below to secure your spot in the queue.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),

              // Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    _label('USER NAME'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'John Doe',
                        suffixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                        filled: true, fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Service
                    _label('SERVICE TYPE'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedService, isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: ServiceTypes.all.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() => _selectedService = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date
                    _label('SELECT DATE'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableDates.length,
                        itemBuilder: (context, index) {
                          final date = _availableDates[index];
                          final isSelected = _selectedDate != null &&
                              date.day == _selectedDate!.day && date.month == _selectedDate!.month;
                          return GestureDetector(
                            onTap: () => setState(() { _selectedDate = date; _selectedTimeSlot = null; }),
                            child: Container(
                              width: 60, margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(getDayAbbr(date),
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white70 : AppColors.textSecondary)),
                                  const SizedBox(height: 4),
                                  Text('${date.day}',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                                          color: isSelected ? Colors.white : AppColors.textPrimary)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Time Slots
                    _label('AVAILABLE TIME SLOTS'),
                    const SizedBox(height: 12),
                    TimeSlotPicker(
                      slots: TimeSlots.all,
                      selectedSlot: _selectedTimeSlot,
                      slotCounts: slotCounts,
                      pastSlots: pastSlots,
                      onSlotSelected: (s) => setState(() => _selectedTimeSlot = s),
                      onPastSlotTapped: () => _showError('Selected slot is no longer available'),
                    ),
                    const SizedBox(height: 16),

                    // Info
                    Row(children: [
                      Icon(Icons.info_outline, size: 16, color: AppColors.inProgress),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Please ensure your user name is entered correctly.',
                          style: TextStyle(fontSize: 12, color: AppColors.inProgress))),
                    ]),
                    const SizedBox(height: 20),

                    // Book button
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: _handleBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
                        ),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('Book Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(width: 8), Icon(Icons.arrow_forward, size: 20),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Preview
              _buildPreview(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Review your selection before finalizing.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6C3CE1), Color(0xFF4C1D95)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.completed.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: const Text('CONFIRMED SLOT', style: TextStyle(color: AppColors.completed, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              Text(_nameController.text.isEmpty ? 'Your Name' : _nameController.text,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.medical_services_outlined, size: 14, color: Colors.white60),
                const SizedBox(width: 6),
                Text('SERVICE\n$_selectedService', style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white60),
                const SizedBox(width: 6),
                Text(
                  _selectedDate != null && _selectedTimeSlot != null
                      ? 'DATE & TIME\n${formatFullDate(_selectedDate!)} • $_selectedTimeSlot'
                      : 'DATE & TIME\nSelect date and time',
                  style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                ),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('ESTIMATED WAIT', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600)),
                  SizedBox(width: 12),
                  Text('~10 min', style: TextStyle(color: AppColors.completed, fontSize: 14, fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8));
}
