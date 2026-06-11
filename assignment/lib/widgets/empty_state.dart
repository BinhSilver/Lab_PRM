import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback onAdd;

  const EmptyState({
    super.key,
    required this.isFiltered,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              color: Color(0xFFE8EAFF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFiltered
                  ? Icons.filter_list_off_rounded
                  : Icons.task_alt_rounded,
              size: 64,
              color: const Color(0xFF9FA8DA),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isFiltered
                ? 'Không có task nào\ntrong bộ lọc này'
                : 'Chưa có công việc nào,\nhãy thêm mới!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF9FA8DA),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          if (!isFiltered) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Thêm Task đầu tiên'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5C6BC0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
