import 'package:flutter/material.dart';

// ── Priority enum ───────────────────────────────────────
enum TaskPriority { low, medium, high }

extension TaskPriorityExt on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Thấp';
      case TaskPriority.medium:
        return 'Trung bình';
      case TaskPriority.high:
        return 'Cao';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF66BB6A);
      case TaskPriority.medium:
        return const Color(0xFFFFB74D);
      case TaskPriority.high:
        return const Color(0xFFEF5350);
    }
  }

  Color get bgColor {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFFE8F5E9);
      case TaskPriority.medium:
        return const Color(0xFFFFF8E1);
      case TaskPriority.high:
        return const Color(0xFFFFEBEE);
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
    }
  }
}

// ── Sort mode enum ──────────────────────────────────────
enum SortMode { newestFirst, oldestFirst, dueDateAsc, priorityDesc }

extension SortModeExt on SortMode {
  String get label {
    switch (this) {
      case SortMode.newestFirst:
        return 'Mới nhất';
      case SortMode.oldestFirst:
        return 'Cũ nhất';
      case SortMode.dueDateAsc:
        return 'Deadline gần nhất';
      case SortMode.priorityDesc:
        return 'Ưu tiên cao nhất';
    }
  }

  IconData get icon {
    switch (this) {
      case SortMode.newestFirst:
        return Icons.arrow_downward_rounded;
      case SortMode.oldestFirst:
        return Icons.arrow_upward_rounded;
      case SortMode.dueDateAsc:
        return Icons.event_rounded;
      case SortMode.priorityDesc:
        return Icons.priority_high_rounded;
    }
  }
}

// ── Form result (returned from bottom sheet) ────────────
class TaskFormResult {
  final String title;
  final DateTime? scheduledDate; // ngày dự định làm
  final DateTime? dueDate;       // ngày hết hạn (deadline)
  final int? estimatedMinutes;
  final TaskPriority priority;

  const TaskFormResult({
    required this.title,
    this.scheduledDate,
    this.dueDate,
    this.estimatedMinutes,
    required this.priority,
  });
}

// ── Task model ──────────────────────────────────────────
class Task {
  final String id;
  String title;
  bool isCompleted;
  final DateTime createdAt;
  DateTime? scheduledDate; // ngày dự định thực hiện
  DateTime? dueDate;       // deadline (phải >= scheduledDate)
  int? estimatedMinutes;
  TaskPriority priority;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.scheduledDate,
    this.dueDate,
    this.estimatedMinutes,
    this.priority = TaskPriority.medium,
  });

  /// True if task is incomplete and past its deadline (or scheduled date if no deadline).
  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    if (dueDate != null) {
      final end = DateTime(dueDate!.year, dueDate!.month, dueDate!.day, 23, 59, 59);
      return now.isAfter(end);
    }
    if (scheduledDate != null) {
      final end = DateTime(scheduledDate!.year, scheduledDate!.month, scheduledDate!.day, 23, 59, 59);
      return now.isAfter(end);
    }
    return false;
  }

  /// Days until deadline or scheduled date (negative = overdue). Null if neither is set.
  int? get daysUntilDue {
    final target = dueDate ?? scheduledDate;
    if (target == null) return null;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final t = DateTime(target.year, target.month, target.day);
    return t.difference(today).inDays;
  }
}
