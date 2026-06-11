import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const _filters = [
    ('All', Icons.all_inclusive_rounded, 'Tất cả'),
    ('Incomplete', Icons.radio_button_unchecked_rounded, 'Chưa xong'),
    ('Completed', Icons.check_circle_rounded, 'Hoàn thành'),
    ('Overdue', Icons.warning_amber_rounded, 'Quá hạn'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        itemCount: _filters.length,
        itemBuilder: (_, i) {
          final filter = _filters[i].$1;
          final icon = _filters[i].$2;
          final label = _filters[i].$3;
          final isSelected = selectedFilter == filter;
          final isOverdue = filter == 'Overdue';

          final activeColor = isOverdue
              ? const Color(0xFFEF5350)
              : const Color(0xFF5C6BC0);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onFilterChanged(filter),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? activeColor : const Color(0xFFDDE1FF),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        size: 15,
                        color: isSelected ? Colors.white : activeColor),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : activeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
