import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'status_badge.dart';

/// Reusable card widget for displaying an appointment in lists
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppointmentStatus.getColor(appointment.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border(
            left: BorderSide(color: statusColor, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Status badge + ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: appointment.status, small: true),
                  Text(
                    '#${appointment.queueNumber.toString().padLeft(3, '0')}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Name
              Text(
                appointment.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),

              // Service type and ID
              Text(
                '${appointment.serviceType} • ID: #${appointment.id}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),

              // Date and time row
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    isToday(appointment.date)
                        ? 'Today, ${formatDate(appointment.date)}'
                        : formatDateWithYear(appointment.date),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    appointment.timeSlot,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Optional action buttons
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
