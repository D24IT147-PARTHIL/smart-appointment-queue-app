import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Grid widget for selecting time slots
class TimeSlotPicker extends StatelessWidget {
  final List<String> slots;
  final String? selectedSlot;
  final Map<String, int> slotCounts; // slot -> current count
  final Set<String> pastSlots; // slots that are in the past (today only)
  final ValueChanged<String> onSlotSelected;
  final VoidCallback? onPastSlotTapped; // callback when user taps a past slot

  const TimeSlotPicker({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.slotCounts,
    this.pastSlots = const {},
    required this.onSlotSelected,
    this.onPastSlotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = slot == selectedSlot;
        final count = slotCounts[slot] ?? 0;
        final isFull = count >= maxAppointmentsPerSlot;
        final isPast = pastSlots.contains(slot);
        final isDisabled = isFull || isPast;

        return GestureDetector(
          onTap: isDisabled
              ? (isPast ? onPastSlotTapped : null)
              : () => onSlotSelected(slot),
          child: Container(
            decoration: BoxDecoration(
              color: isDisabled
                  ? Colors.grey.shade100
                  : isSelected
                      ? AppColors.primary
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDisabled
                    ? Colors.grey.shade300
                    : isSelected
                        ? AppColors.primary
                        : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slot,
                    style: TextStyle(
                      color: isDisabled
                          ? Colors.grey
                          : isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (isPast)
                    Text(
                      'Past',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    )
                  else if (isFull)
                    Text(
                      'Full',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

