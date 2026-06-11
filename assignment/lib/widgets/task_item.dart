import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/date_formatter.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool done = task.isCompleted;
    final bool overdue = task.isOverdue;
    final int? days = task.daysUntilDue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: overdue
              ? const Color(0xFFFFF3F3)
              : done
                  ? const Color(0xFFF0FFF4)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: overdue
                ? Colors.red.shade200
                : done
                    ? const Color(0xFF81C784).withOpacity(0.6)
                    : const Color(0xFFDDE1FF),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: overdue
                  ? Colors.red.withOpacity(0.08)
                  : done
                      ? const Color(0xFF81C784).withOpacity(0.12)
                      : const Color(0xFF5C6BC0).withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Overdue banner ──────────────────────
            if (overdue)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 14, color: Colors.red.shade400),
                    const SizedBox(width: 5),
                    Text(
                      days != null
                          ? 'Quá hạn ${-days} ngày!'
                          : 'Quá hạn!',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

            // ── Main content (ListTile) ─────────────
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              leading: GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: done
                        ? const Color(0xFF66BB6A)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: done
                          ? const Color(0xFF66BB6A)
                          : overdue
                              ? Colors.red.shade300
                              : const Color(0xFF9FA8DA),
                      width: 2,
                    ),
                  ),
                  child: done
                      ? const Icon(Icons.check_rounded,
                          size: 18, color: Colors.white)
                      : null,
                ),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: done
                      ? Colors.grey.shade400
                      : overdue
                          ? Colors.red.shade700
                          : const Color(0xFF1A1A2E),
                  decoration: done
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: Colors.grey.shade400,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Created time
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          formatDateTime(task.createdAt),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade400),
                        ),
                        if (done) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFA5D6A7).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Hoàn thành',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF388E3C),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Badges row: priority | scheduled | due date | days left | duration
                  if (task.scheduledDate != null ||
                      task.dueDate != null ||
                      task.estimatedMinutes != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 2),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Priority badge
                          _Badge(
                            icon: task.priority.icon,
                            label: task.priority.label,
                            color: task.priority.color,
                            bg: task.priority.bgColor,
                          ),
                          // Scheduled date badge (ngày lên lịch)
                          if (task.scheduledDate != null)
                            _Badge(
                              icon: Icons.calendar_month_rounded,
                              label: formatDate(task.scheduledDate!),
                              color: const Color(0xFF5C6BC0),
                              bg: const Color(0xFFE8EAFF),
                            ),
                          // Due date badge (deadline)
                          if (task.dueDate != null)
                            _Badge(
                              icon: Icons.event_rounded,
                              label: formatDate(task.dueDate!),
                              color: overdue
                                  ? Colors.red.shade600
                                  : days == 0
                                      ? Colors.orange.shade700
                                      : Colors.red.shade400,
                              bg: overdue
                                  ? Colors.red.shade50
                                  : days == 0
                                      ? Colors.orange.shade50
                                      : Colors.red.shade50,
                            ),
                          // Days remaining badge
                          if (days != null && !done)
                            _Badge(
                              icon: overdue
                                  ? Icons.warning_amber_rounded
                                  : days == 0
                                      ? Icons.alarm_rounded
                                      : Icons.hourglass_top_rounded,
                              label: dueDateLabel(days),
                              color: overdue
                                  ? Colors.red.shade600
                                  : days <= 1
                                      ? Colors.orange.shade700
                                      : Colors.teal.shade600,
                              bg: overdue
                                  ? Colors.red.shade50
                                  : days <= 1
                                      ? Colors.orange.shade50
                                      : Colors.teal.shade50,
                            ),
                          // Duration badge
                          if (task.estimatedMinutes != null)
                            _Badge(
                              icon: Icons.timer_outlined,
                              label: formatDuration(task.estimatedMinutes!),
                              color: Colors.purple.shade600,
                              bg: Colors.purple.shade50,
                            ),
                        ],
                      ),
                    )
                  else
                    // Always show priority badge
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 2),
                      child: _Badge(
                        icon: task.priority.icon,
                        label: task.priority.label,
                        color: task.priority.color,
                        bg: task.priority.bgColor,
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconBtn(
                    icon: Icons.edit_rounded,
                    color: const Color(0xFF5C6BC0),
                    bgColor: const Color(0xFFE8EAFF),
                    tooltip: 'Sửa',
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 6),
                  _IconBtn(
                    icon: Icons.delete_outline_rounded,
                    color: Colors.red,
                    bgColor: const Color(0xFFFFEBEE),
                    tooltip: 'Xóa',
                    onTap: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small badge pill ──────────────────────────────────
class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Icon action button ────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String tooltip;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
