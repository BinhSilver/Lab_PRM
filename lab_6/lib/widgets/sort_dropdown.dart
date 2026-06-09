import 'package:flutter/material.dart';

class SortDropdown extends StatelessWidget {
  final String selectedSort;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const SortDropdown({
    super.key,
    required this.selectedSort,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSort,
          dropdownColor: const Color(0xFF1E1E2E),
          icon: const Icon(
            Icons.sort_rounded,
            color: Color(0xFF6C63FF),
            size: 18,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          items: options
              .map(
                (opt) => DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
