import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../utils/date_formatter.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/filter_bar.dart';
import '../widgets/task_item.dart';
import '../widgets/empty_state.dart';
import 'login_screen.dart';

// ═══════════════════════════════════════════════════════
// HOME SCREEN
// ═══════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── State ──────────────────────────────────────
  final List<Task> _tasks = [];
  bool _isLoading = true;
  int _userId = 0;              // userId cua user dang dang nhap
  String _filterType = 'All'; // All | Incomplete | Completed | Overdue
  SortMode _sortMode = SortMode.newestFirst;
  DateTime? _selectedDate; // date-strip filter (null = show all)

  final _db = DatabaseHelper.instance;

  // ── Computed ───────────────────────────────────
  int get _overdueCount => _tasks.where((t) => t.isOverdue).length;

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(
        days: 6, hours: 23, minutes: 59, seconds: 59));
    return date.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
        date.isBefore(weekEnd);
  }

  int get _weeklyTotal => _tasks.where((t) {
        final d = t.scheduledDate ?? t.dueDate ?? t.createdAt;
        return _isThisWeek(d);
      }).length;

  int get _weeklyCompleted => _tasks.where((t) {
        if (!t.isCompleted) return false;
        final d = t.scheduledDate ?? t.dueDate ?? t.createdAt;
        return _isThisWeek(d);
      }).length;

  List<Task> get _filteredAndSortedTasks {
    List<Task> result;
    switch (_filterType) {
      case 'Completed':
        result = _tasks.where((t) => t.isCompleted).toList();
        break;
      case 'Incomplete':
        result = _tasks.where((t) => !t.isCompleted).toList();
        break;
      case 'Overdue':
        result = _tasks.where((t) => t.isOverdue).toList();
        break;
      default:
        result = List.from(_tasks);
    }

    switch (_sortMode) {
      case SortMode.newestFirst:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortMode.oldestFirst:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortMode.dueDateAsc:
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case SortMode.priorityDesc:
        result.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
    }

    // Date-strip filter
    if (_selectedDate != null) {
      final d = _selectedDate!;
      result = result.where((t) {
        bool ms = t.scheduledDate != null &&
            t.scheduledDate!.year == d.year &&
            t.scheduledDate!.month == d.month &&
            t.scheduledDate!.day == d.day;
        bool md = t.dueDate != null &&
            t.dueDate!.year == d.year &&
            t.dueDate!.month == d.month &&
            t.dueDate!.day == d.day;
        return ms || md;
      }).toList();
    }

    return result;
  }

  // ── Lifecycle ──────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadTasksFromDb();
  }

  // ── DB Operations ──────────────────────────────
  Future<void> _loadTasksFromDb() async {
    setState(() => _isLoading = true);
    try {
      // Giải thích (Multi-user):
      // 1. Đọc userId của người dùng hiện tại đang đăng nhập từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt('userId') ?? 0;

      // 2. Truyền userId vào hàm getTasks() để database chỉ trả về
      // danh sách task của riêng người này.
      final tasks = await _db.getTasks(_userId);
      if (mounted) {
        setState(() {
          _tasks.clear();
          _tasks.addAll(tasks);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addTask(TaskFormResult r) async {
    final newTask = Task(
      title: r.title,
      createdAt: DateTime.now(),
      scheduledDate: r.scheduledDate,
      dueDate: r.dueDate,
      estimatedMinutes: r.estimatedMinutes,
      priority: r.priority,
    );
    final insertedId = await _db.insertTask(newTask, _userId);
    newTask.id = insertedId;
    setState(() => _tasks.insert(0, newTask));
    _showSnackBar('✅ Task đã được thêm thành công!');
  }

  Future<void> _editTask(Task task, TaskFormResult r) async {
    task.title = r.title;
    task.scheduledDate = r.scheduledDate;
    task.dueDate = r.dueDate;
    task.estimatedMinutes = r.estimatedMinutes;
    task.priority = r.priority;
    await _db.updateTask(task);
    setState(() {});
    _showSnackBar('✏️ Task đã được cập nhật!');
  }

  Future<void> _toggleTaskStatus(Task task) async {
    task.isCompleted = !task.isCompleted;
    if (task.id != null) {
      await _db.updateTaskStatus(task.id!, task.isCompleted);
    }
    setState(() {});
  }

  Future<void> _deleteTask(Task task) async {
    if (task.id != null) {
      await _db.deleteTask(task.id!);
    }
    setState(() => _tasks.remove(task));
    _showSnackBar('🗑️ Đã xóa task "${task.title}"');
  }

  // ── Logout ─────────────────────────────────────
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFF5C6BC0), size: 26),
            SizedBox(width: 8),
            Text('Đăng xuất'),
          ],
        ),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF5C6BC0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userEmail');

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // ── SnackBar ───────────────────────────────────
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? Colors.red.shade600 : const Color(0xFF3949AB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Bottom Sheet ───────────────────────────────
  void _showTaskBottomSheet({Task? existingTask}) {
    showModalBottomSheet<TaskFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _TaskSheetContent(existingTask: existingTask),
    ).then((result) {
      if (!mounted || result == null) return;
      if (existingTask != null) {
        _editTask(existingTask, result);
      } else {
        _addTask(result);
      }
    });
  }

  // ── Delete Dialog ──────────────────────────────
  void _showDeleteDialog(Task task) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 26),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Text(
          'Bạn có chắc muốn xóa task\n"${task.title}"?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade500,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) _deleteTask(task);
    });
  }

  // ── Sort popup ─────────────────────────────────
  void _showSortMenu(BuildContext btnCtx) async {
    final RenderBox box = btnCtx.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);

    final result = await showMenu<SortMode>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + box.size.height + 4,
        offset.dx + box.size.width,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: SortMode.values.map((mode) {
        final selected = _sortMode == mode;
        return PopupMenuItem<SortMode>(
          value: mode,
          child: Row(
            children: [
              Icon(
                mode.icon,
                size: 18,
                color: selected ? const Color(0xFF5C6BC0) : Colors.grey.shade600,
              ),
              const SizedBox(width: 10),
              Text(
                mode.label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? const Color(0xFF5C6BC0) : Colors.black87,
                ),
              ),
              if (selected) ...[
                const Spacer(),
                const Icon(Icons.check_rounded,
                    size: 16, color: Color(0xFF5C6BC0)),
              ],
            ],
          ),
        );
      }).toList(),
    );

    if (result != null) setState(() => _sortMode = result);
  }

  // ── Date Strip ─────────────────────────────────
  Widget _buildDateStrip() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final baseDate = _selectedDate ?? now;
    final centerDate = DateTime(baseDate.year, baseDate.month, baseDate.day);
    final weekStart =
        centerDate.subtract(Duration(days: centerDate.weekday - 1));
    final dates = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    int taskCountFor(DateTime d) {
      return _tasks.where((t) {
        bool ms = t.scheduledDate != null &&
            t.scheduledDate!.year == d.year &&
            t.scheduledDate!.month == d.month &&
            t.scheduledDate!.day == d.day;
        bool md = t.dueDate != null &&
            t.dueDate!.year == d.year &&
            t.dueDate!.month == d.month &&
            t.dueDate!.day == d.day;
        return ms || md;
      }).length;
    }

    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    return SizedBox(
      height: 82,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        itemCount: dates.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            final active = _selectedDate == null;
            return GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? now,
                  firstDate: DateTime(now.year - 2),
                  lastDate: DateTime(now.year + 5),
                  helpText: 'Chọn ngày để xem tuần khác',
                  confirmText: 'Xem',
                  cancelText: 'Hủy',
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF5C6BC0),
                        onPrimary: Colors.white,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null && mounted) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 52,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF5C6BC0) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active
                        ? const Color(0xFF5C6BC0)
                        : const Color(0xFFDDE1FF),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 15,
                      color: active ? Colors.white : const Color(0xFF5C6BC0),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Lịch',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color:
                            active ? Colors.white : const Color(0xFF5C6BC0),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final date = dates[i - 1];
          final isToday = isSameDay(date, today);
          final isSelected =
              _selectedDate != null && isSameDay(_selectedDate!, date);
          final count = taskCountFor(date);

          return GestureDetector(
            onTap: () =>
                setState(() => _selectedDate = isSelected ? null : date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF5C6BC0)
                    : isToday
                        ? const Color(0xFFE8EAFF)
                        : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF5C6BC0)
                      : isToday
                          ? const Color(0xFF5C6BC0)
                          : const Color(0xFFDDE1FF),
                  width: isToday && !isSelected ? 2 : 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatDayShort(date),
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (count > 0)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : const Color(0xFF5C6BC0),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final tasks = _filteredAndSortedTasks;
    final hasDateFilter = _selectedDate != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FF),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5C6BC0),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardCard(
                  weeklyTotal: _weeklyTotal,
                  weeklyCompleted: _weeklyCompleted,
                  overdue: _overdueCount,
                ),
                FilterBar(
                  selectedFilter: _filterType,
                  onFilterChanged: (f) => setState(() => _filterType = f),
                ),
                _buildDateStrip(),
                if (hasDateFilter)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt_rounded,
                            size: 14, color: Color(0xFF5C6BC0)),
                        const SizedBox(width: 6),
                        Text(
                          'Ngày ${formatDate(_selectedDate!)} · ${tasks.length} task',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5C6BC0),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => setState(() => _selectedDate = null),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EAFF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.close_rounded,
                                    size: 12, color: Color(0xFF5C6BC0)),
                                SizedBox(width: 3),
                                Text(
                                  'Xóa bộ lọc',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF5C6BC0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: tasks.isEmpty
                      ? EmptyState(
                          isFiltered: _filterType != 'All' || hasDateFilter,
                          onAdd: () => _showTaskBottomSheet(),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount: tasks.length,
                          itemBuilder: (_, i) => TaskItem(
                            key: ValueKey(tasks[i].id),
                            task: tasks[i],
                            onToggle: () => _toggleTaskStatus(tasks[i]),
                            onEdit: () =>
                                _showTaskBottomSheet(existingTask: tasks[i]),
                            onDelete: () => _showDeleteDialog(tasks[i]),
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskBottomSheet(),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Thêm Task',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF5C6BC0),
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checklist_rounded, size: 22, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Task Manager',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        // Sort button
        Builder(
          builder: (btnCtx) => Tooltip(
            message: 'Sắp xếp: ${_sortMode.label}',
            child: InkWell(
              onTap: () => _showSortMenu(btnCtx),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_sortMode.icon, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    const Text('Sắp xếp',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Logout button
        Tooltip(
          message: 'Đăng xuất',
          child: IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// TASK BOTTOM SHEET
// ═══════════════════════════════════════════════════════
class _TaskSheetContent extends StatefulWidget {
  final Task? existingTask;
  const _TaskSheetContent({this.existingTask});

  @override
  State<_TaskSheetContent> createState() => _TaskSheetContentState();
}

class _TaskSheetContentState extends State<_TaskSheetContent> {
  late final TextEditingController _ctrl;
  String? _error;
  DateTime? _scheduledDate;
  DateTime? _dueDate;
  int? _estimatedMinutes;
  TaskPriority _priority = TaskPriority.medium;

  static const _durations = [15, 30, 60, 120, 180, 240, 480];

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _ctrl = TextEditingController(text: t?.title ?? '');
    _scheduledDate = t?.scheduledDate;
    _dueDate = t?.dueDate;
    _estimatedMinutes = t?.estimatedMinutes;
    _priority = t?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final val = _ctrl.text.trim();
    if (val.isEmpty) {
      setState(() => _error = 'Tên task không được để trống!');
      return;
    }
    if (val.length < 2) {
      setState(() => _error = 'Tên task phải có ít nhất 2 ký tự!');
      return;
    }

    // Giải thích (Tự động thiết lập ngày mặc định):
    // Lấy ngày giờ hiện tại nhưng ép bỏ phần Giờ/Phút/Giây (chỉ giữ Ngày/Tháng/Năm)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Dùng toán tử ?? (Null-coalescing) để kiểm tra:
    // Nếu _scheduledDate hoặc _dueDate là null (do người dùng không chọn ngày),
    // thì hệ thống tự động lấy giá trị mặc định là biến 'today' (ngày hôm nay).
    final effectiveScheduledDate = _scheduledDate ?? today;
    final effectiveDueDate = _dueDate ?? today;

    Navigator.of(context).pop(
      TaskFormResult(
        title: val,
        scheduledDate: effectiveScheduledDate,
        dueDate: effectiveDueDate,
        estimatedMinutes: _estimatedMinutes,
        priority: _priority,
      ),
    );
  }


  Future<void> _pickScheduledDate() async {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate != null && !_scheduledDate!.isBefore(today)
          ? _scheduledDate!
          : today,
      firstDate: today,
      lastDate: DateTime(DateTime.now().year + 5),
      helpText: 'Chọn ngày lên lịch',
      confirmText: 'Chọn',
      cancelText: 'Hủy',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF5C6BC0),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
        if (_dueDate != null && _dueDate!.isBefore(picked)) _dueDate = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final minDate = (_scheduledDate != null && !_scheduledDate!.isBefore(today))
        ? _scheduledDate!
        : today;
    final initDate =
        (_dueDate != null && !_dueDate!.isBefore(minDate)) ? _dueDate! : minDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: minDate,
      lastDate: DateTime(DateTime.now().year + 5),
      helpText: 'Chọn ngày hết hạn',
      confirmText: 'Chọn',
      cancelText: 'Hủy',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF5C6BC0),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_rounded : Icons.add_task_rounded,
                      color: const Color(0xFF5C6BC0),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Chỉnh sửa Task' : 'Thêm Task mới',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          isEditing
                              ? 'Cập nhật thông tin công việc'
                              : 'Điền thông tin công việc',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Task title
              _SectionLabel(label: 'Tên công việc', icon: Icons.task_alt_rounded),
              const SizedBox(height: 8),
              TextField(
                controller: _ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 15),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Mua sắm đồ ăn...',
                  errorText: _error,
                  prefixIcon: const Icon(Icons.task_alt_rounded,
                      color: Color(0xFF5C6BC0)),
                  filled: true,
                  fillColor: const Color(0xFFF3F4FF),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFDDE1FF), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF5C6BC0), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Scheduled date
              _SectionLabel(
                  label: 'Ngày lên lịch',
                  icon: Icons.calendar_month_rounded,
                  optional: true),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickScheduledDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _scheduledDate != null
                          ? const Color(0xFF5C6BC0)
                          : const Color(0xFFDDE1FF),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded,
                          size: 20,
                          color: _scheduledDate != null
                              ? const Color(0xFF5C6BC0)
                              : Colors.grey.shade400),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _scheduledDate != null
                              ? formatDate(_scheduledDate!)
                              : 'Chọn ngày dự định thực hiện...',
                          style: TextStyle(
                            fontSize: 15,
                            color: _scheduledDate != null
                                ? const Color(0xFF1A1A2E)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                      if (_scheduledDate != null)
                        GestureDetector(
                          onTap: () =>
                              setState(() => _scheduledDate = null),
                          child: Icon(Icons.close_rounded,
                              size: 18, color: Colors.grey.shade500),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 4),
                child: Text(
                  'Ngày bạn dự định làm task này (không chọn ngày quá khứ)',
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),
              const SizedBox(height: 18),

              // Due date
              _SectionLabel(
                  label: 'Ngày hết hạn (Deadline)',
                  icon: Icons.event_rounded,
                  optional: true),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _dueDate != null
                          ? Colors.red.shade300
                          : const Color(0xFFDDE1FF),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 20,
                          color: _dueDate != null
                              ? const Color(0xFF5C6BC0)
                              : Colors.grey.shade400),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dueDate != null
                              ? formatDate(_dueDate!)
                              : 'Chọn ngày hết hạn (tùy chọn)',
                          style: TextStyle(
                            fontSize: 15,
                            color: _dueDate != null
                                ? const Color(0xFF1A1A2E)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                      if (_dueDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _dueDate = null),
                          child: Icon(Icons.close_rounded,
                              size: 18, color: Colors.grey.shade500),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Duration chips
              _SectionLabel(
                  label: 'Thời gian ước tính',
                  icon: Icons.timer_outlined,
                  optional: true),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _durations.map((min) {
                  final selected = _estimatedMinutes == min;
                  return GestureDetector(
                    onTap: () => setState(
                        () => _estimatedMinutes = selected ? null : min),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF5C6BC0)
                            : const Color(0xFFF3F4FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF5C6BC0)
                              : const Color(0xFFDDE1FF),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 14,
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade600),
                          const SizedBox(width: 5),
                          Text(
                            formatDuration(min),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Priority
              _SectionLabel(
                  label: 'Mức độ ưu tiên', icon: Icons.flag_rounded),
              const SizedBox(height: 8),
              Row(
                children: TaskPriority.values.map((p) {
                  final selected = _priority == p;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? p.color : p.bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? p.color
                                  : p.color.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(p.icon,
                                  size: 18,
                                  color: selected ? Colors.white : p.color),
                              const SizedBox(height: 3),
                              Text(
                                p.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      selected ? Colors.white : p.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF5C6BC0)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Hủy',
                          style: TextStyle(color: Color(0xFF5C6BC0))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF5C6BC0),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isEditing ? 'Cập nhật' : 'Thêm Task',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable section label ────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool optional;

  const _SectionLabel({
    required this.label,
    required this.icon,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF5C6BC0)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'tùy chọn',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ],
    );
  }
}
