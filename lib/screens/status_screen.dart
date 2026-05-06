import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/status_badge.dart';
import '../widgets/queue_progress_card.dart';

/// Status screen — Queue status view matching the UI design
class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, _) {
          final current = provider.currentServingAppointment;
          final waiting = provider.waitingAppointments;
          // Use first waiting appointment for user perspective
          final userAppt = waiting.isNotEmpty ? waiting.first : current;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Now Serving card
                  _buildNowServingCard(current),
                  const SizedBox(height: 16),

                  // Your Token card
                  if (userAppt != null) ...[
                    _buildYourTokenCard(userAppt),
                    const SizedBox(height: 16),

                    // Queue Progress
                    QueueProgressCard(
                      peopleAhead: provider.getPeopleAhead(userAppt.id),
                      estimatedWaitMinutes:
                          provider.getEstimatedWaitTime(userAppt.id),
                      queuePosition:
                          provider.getQueuePosition(userAppt.id),
                      progressPercent: _calcProgress(provider, userAppt.id),
                    ),
                    const SizedBox(height: 16),

                    // Next Step info card
                    _buildNextStepCard(),
                  ] else
                    _buildEmptyState(),

                  const SizedBox(height: 16),

                  // Status timeline
                  _buildTimeline(userAppt),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _calcProgress(AppointmentProvider provider, String id) {
    final total = provider.waitingAppointments.length + 1;
    final pos = provider.getQueuePosition(id);
    if (total <= 1) return 1.0;
    return 1.0 - (pos / total);
  }

  Widget _buildNowServingCard(dynamic current) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C3CE1), Color(0xFF4C1D95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'NOW SERVING',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            current != null
                ? 'A-${current.queueNumber}'
                : '---',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: current != null ? AppColors.completed : Colors.white30,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                current != null ? 'Live Updates Active' : 'No active queue',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYourTokenCard(dynamic appointment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Text(
            'YOUR TOKEN',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'A-${appointment.queueNumber}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          StatusBadge(status: appointment.status),
        ],
      ),
    );
  }

  Widget _buildNextStepCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NEXT STEP',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Prepare your digital ID and booking reference.',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Our concierge will call your token number shortly. Please stay within the lobby area or keep this screen open.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_available, size: 48, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text(
            'No appointments in queue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Book an appointment to see your queue status',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(dynamic appointment) {
    final status = appointment?.status ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimelineItem(
          icon: Icons.calendar_today_outlined,
          title: 'SCHEDULED',
          subtitle: appointment != null
              ? '${appointment.timeSlot} ${isToday(appointment.date) ? "Today" : formatDate(appointment.date)}'
              : '--',
          isActive: status == AppointmentStatus.scheduled ||
              status == AppointmentStatus.inProgress ||
              status == AppointmentStatus.completed,
          isCompleted: status == AppointmentStatus.inProgress ||
              status == AppointmentStatus.completed,
        ),
        _buildTimelineConnector(status == AppointmentStatus.inProgress ||
            status == AppointmentStatus.completed),
        _buildTimelineItem(
          icon: Icons.play_circle_outline,
          title: 'IN PROGRESS',
          subtitle: status == AppointmentStatus.inProgress
              ? 'Position #${appointment?.queueNumber ?? ""}'
              : '--',
          isActive: status == AppointmentStatus.inProgress ||
              status == AppointmentStatus.completed,
          isCompleted: status == AppointmentStatus.completed,
          color: AppColors.inProgress,
        ),
        _buildTimelineConnector(status == AppointmentStatus.completed),
        _buildTimelineItem(
          icon: Icons.check_circle_outline,
          title: 'COMPLETED',
          subtitle: status == AppointmentStatus.completed ? 'Done' : '--',
          isActive: status == AppointmentStatus.completed,
          isCompleted: status == AppointmentStatus.completed,
          color: AppColors.completed,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isCompleted,
    Color? color,
  }) {
    final itemColor = isActive
        ? (color ?? AppColors.primary)
        : AppColors.textSecondary.withOpacity(0.4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: itemColor, size: 24),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: itemColor,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isActive
                      ? AppColors.textSecondary
                      : AppColors.textSecondary.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector(bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(left: 27),
      child: Container(
        width: 2,
        height: 20,
        color: isActive
            ? AppColors.primary.withOpacity(0.3)
            : AppColors.textSecondary.withOpacity(0.15),
      ),
    );
  }
}
