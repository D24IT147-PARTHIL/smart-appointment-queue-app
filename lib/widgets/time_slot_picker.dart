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
  final VoidCallback? onFullSlotTapped; // callback when user taps a full slot

  const TimeSlotPicker({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.slotCounts,
    this.pastSlots = const {},
    required this.onSlotSelected,
    this.onPastSlotTapped,
    this.onFullSlotTapped,
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

        final int remaining = maxAppointmentsPerSlot - count;
        
        Color bgColor;
        Color borderColor;
        Color textColor;
        String bottomText;
        Color bottomTextColor;

        if (isPast) {
          bgColor = Colors.grey.shade100;
          borderColor = Colors.grey.shade300;
          textColor = Colors.grey;
          bottomText = 'Past';
          bottomTextColor = Colors.grey.shade500;
        } else if (isFull) {
          bgColor = Colors.grey.shade200;
          borderColor = Colors.grey.shade400;
          textColor = Colors.grey.shade700;
          bottomText = 'FULL';
          bottomTextColor = Colors.grey.shade600;
        } else if (remaining == 1) {
          bgColor = isSelected ? Colors.orange : Colors.orange.shade50;
          borderColor = isSelected ? Colors.orange : Colors.orange.shade300;
          textColor = isSelected ? Colors.white : AppColors.textPrimary;
          bottomText = '1 slot left';
          bottomTextColor = isSelected ? Colors.white70 : Colors.orange.shade700;
        } else {
          bgColor = isSelected ? Colors.green : Colors.green.shade50;
          borderColor = isSelected ? Colors.green : Colors.green.shade300;
          textColor = isSelected ? Colors.white : AppColors.textPrimary;
          bottomText = 'Available';
          bottomTextColor = isSelected ? Colors.white70 : Colors.green.shade700;
        }

        return GestureDetector(
          onTap: isDisabled
              ? (isPast ? onPastSlotTapped : onFullSlotTapped)
              : () => onSlotSelected(slot),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
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
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    bottomText,
                    style: TextStyle(
                      color: bottomTextColor,
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

