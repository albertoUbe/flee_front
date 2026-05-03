import 'package:flutter/material.dart';

class BirthdayPickerWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String label;

  const BirthdayPickerWidget({
    super.key,
    required this.selectedDate,
    required this.onTap,
    this.label = "Select Birthday",
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF42A5F5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null
                  ? label
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              style: TextStyle(
                color: selectedDate == null ? Colors.white54 : Colors.white,
                fontSize: 16,
              ),
            ),
            const Icon(Icons.calendar_month, color: Color(0xFF42A5F5)),
          ],
        ),
      ),
    );
  }
}
