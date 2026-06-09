import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ─────────────────────────────────────────────
// Data Model
// ─────────────────────────────────────────────
class Task {
  final String id;
  String title;
  String content;
  String date;
  String type;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.content = '',
    this.date = '',
    this.type = '',
    this.isCompleted = false,
    required this.createdAt,
  });
}

// ─────────────────────────────────────────────
// Root Widget
// ─────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODOLIST',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}

// ─────────────────────────────────────────────
// Main StatefulWidget
// ─────────────────────────────────────────────
class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  // ── State Variables ──────────────────────────
  final List<Task> _tasks = [];
  String _filterType = 'All'; // 'All' | 'Completed' | 'Incomplete'
  Task? _editingTask;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _dateController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  // ── Getters ──────────────────────────────────
  List<Task> get _filteredAndSortedTasks {
    List<Task> filtered;
    if (_filterType == 'Completed') {
      filtered = _tasks.where((t) => t.isCompleted).toList();
    } else if (_filterType == 'Incomplete') {
      filtered = _tasks.where((t) => !t.isCompleted).toList();
    } else {
      filtered = List.from(_tasks);
    }
    // Sort by createdAt descending
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  int get _completedCount => _tasks.where((t) => t.isCompleted).length;

  // ── Methods ──────────────────────────────────
  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Title is required!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      if (_editingTask == null) {
        // Add mode
        final newTask = Task(
          id: DateTime.now().toString(),
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          date: _dateController.text.trim(),
          type: _typeController.text.trim(),
          createdAt: DateTime.now(),
        );
        _tasks.insert(0, newTask);
      } else {
        // Edit mode
        final index = _tasks.indexWhere((t) => t.id == _editingTask!.id);
        if (index != -1) {
          _tasks[index].title = _titleController.text.trim();
          _tasks[index].content = _contentController.text.trim();
          _tasks[index].date = _dateController.text.trim();
          _tasks[index].type = _typeController.text.trim();
        }
        _editingTask = null;
      }
    });

    _clearControllers();
  }

  void _toggleTaskStatus(String id) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index].isCompleted = !_tasks[index].isCompleted;
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
    });
  }

  void _startEditing(Task task) {
    setState(() {
      _editingTask = task;
      _titleController.text = task.title;
      _contentController.text = task.content;
      _dateController.text = task.date;
      _typeController.text = task.type;
    });
  }

  void _clearControllers() {
    _titleController.clear();
    _contentController.clear();
    _dateController.clear();
    _typeController.clear();
  }

  void _cancelEditing() {
    setState(() {
      _editingTask = null;
    });
    _clearControllers();
  }

  // ── Build ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'TODOLIST',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Part A: Input Form ──────────────────
          _buildInputForm(),

          // ── Part B: Stats & Filter ──────────────
          _buildStatsAndFilter(),

          // ── Part C: Task List ───────────────────
          Expanded(child: _buildTaskList()),
        ],
      ),
    );
  }

  // ── Part A: Input Form Widget ─────────────────
  Widget _buildInputForm() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_editingTask != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'Editing task...',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cancelEditing,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _buildTextField(
            controller: _titleController,
            label: 'Title *',
            icon: Icons.title,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _contentController,
            label: 'Content',
            icon: Icons.notes,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _dateController,
            label: 'Date (e.g. 2024-12-31)',
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _typeController,
            label: 'Type (e.g. Work, Personal)',
            icon: Icons.label_outline,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: Text(
                _editingTask == null ? 'ADD' : 'UPDATE',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green, size: 20),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 1.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }

  // ── Part B: Stats & Filter Widget ─────────────
  Widget _buildStatsAndFilter() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // Stats row
          Row(
            children: [
              const Icon(Icons.list_alt, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text(
                'Total: ${_tasks.length}',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                'Completed: $_completedCount',
                style: const TextStyle(fontSize: 13, color: Colors.green),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.radio_button_unchecked, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                'Remaining: ${_tasks.length - _completedCount}',
                style: const TextStyle(fontSize: 13, color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Filter buttons
          Row(
            children: ['All', 'Completed', 'Incomplete'].map((filter) {
              final isSelected = _filterType == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: () => setState(() => _filterType = filter),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        isSelected ? Colors.green : Colors.grey[200],
                    foregroundColor:
                        isSelected ? Colors.white : Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    filter,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Part C: Task List Widget ───────────────────
  Widget _buildTaskList() {
    final tasks = _filteredAndSortedTasks;

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              _filterType == 'All'
                  ? 'No tasks yet. Add one above!'
                  : 'No $_filterType tasks.',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    final bool completed = task.isCompleted;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: completed
            ? const Color(0xFFDCEDC8) // light green when completed
            : const Color(0xFFE8F5E9), // lighter green when incomplete
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: completed ? Colors.green.shade300 : Colors.green.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        // Leading: Checkbox
        leading: Checkbox(
          value: completed,
          activeColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (_) => _toggleTaskStatus(task.id),
        ),
        // Title + subtitle
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: completed ? Colors.grey : Colors.black87,
            decoration:
                completed ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: _buildSubtitle(task),
        // Trailing: Edit + Delete buttons
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.green, size: 20),
              tooltip: 'Edit',
              onPressed: () => _startEditing(task),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 20),
              tooltip: 'Delete',
              onPressed: () => _showDeleteConfirm(task),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(Task task) {
    final parts = <Widget>[];

    if (task.content.isNotEmpty) {
      parts.add(Text(
        task.content,
        style: TextStyle(
          fontSize: 12,
          color: task.isCompleted ? Colors.grey[400] : Colors.black54,
          decoration: task.isCompleted
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ));
    }

    if (task.date.isNotEmpty || task.type.isNotEmpty) {
      parts.add(const SizedBox(height: 2));
      parts.add(Row(
        children: [
          if (task.date.isNotEmpty) ...[
            const Icon(Icons.calendar_today, size: 11, color: Colors.grey),
            const SizedBox(width: 2),
            Text(
              task.date,
              style:
                  const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(width: 8),
          ],
          if (task.type.isNotEmpty) ...[
            const Icon(Icons.label, size: 11, color: Colors.grey),
            const SizedBox(width: 2),
            Text(
              task.type,
              style:
                  const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ],
      ));
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: parts,
      ),
    );
  }

  void _showDeleteConfirm(Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTask(task.id);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
