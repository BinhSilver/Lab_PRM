# TECHNICAL SPECIFICATION: FLUTTER TODO LIST APP (LOCAL STATE ONLY)

## 1. Core Architecture & Constraints
- **Framework:** Flutter.
- [cite_start]**State Management:** Core Flutter State (`StatefulWidget` & `setState()`) ONLY[cite: 46, 47]. 
- [cite_start]**Strictly Prohibited:** SQLite, Firebase, SharedPreferences, Provider, Bloc, Riverpod, GetX, Backend APIs[cite: 48, 49, 50, 51].
- **Data Persistence:** None. [cite_start]Data is stored in memory and will be lost on app reload[cite: 32, 33].
- [cite_start]**Allowed Widgets:** `MaterialApp`, `Scaffold`, `AppBar`, `Text`, `Icon`, `ListView`, `ListTile`, `TextField`/`TextFormField`, `Form`, `ElevatedButton`, `Checkbox`, `IconButton`, `Row`, `Column`, `Expanded`, `Padding` [cite: 35-47].

## 2. Data Model (`Task`)
Create a standard Dart class to represent a Task item.
**Properties:**
- `String id` (Generate unique string, e.g., using `DateTime.now().toString()`).
- [cite_start]`String title` (Required)[cite: 18].
- `String content` (Optional - from UI).
- `String date` (Optional - from UI).
- `String type` (Optional - from UI).
- [cite_start]`bool isCompleted` (Default: `false`)[cite: 23].
- [cite_start]`DateTime createdAt` (For sorting purposes).

## 3. State Variables (Inside main `StatefulWidget`)
- [cite_start]`List<Task> _tasks`: The primary list holding all task data.
- `String _filterType`: Current filter state. [cite_start]Values: `'All'`, `'Completed'`, `'Incomplete'` [cite: 54-57].
- [cite_start]`TextEditingController _titleController`[cite: 11].
- `TextEditingController _contentController`.
- `TextEditingController _dateController`.
- `TextEditingController _typeController`.
- `Task? _editingTask`: Holds the task currently being edited (null if adding a new task).

## 4. Core Logic & Methods
Implement these specific methods using `setState()`:

- [cite_start]**`_saveTask()`:** Triggered by "ADD" / "UPDATE" button[cite: 12, 13].
  - [cite_start]*Validation:* If `_titleController.text.isEmpty`, show a `SnackBar` with a validation error[cite: 14].
  - [cite_start]*Add Mode:* If `_editingTask` is null, create a new `Task` object, insert it at the beginning of `_tasks`, and clear controllers[cite: 15].
  - [cite_start]*Edit Mode:* If `_editingTask` is NOT null, find the task in `_tasks`, update its properties, reset `_editingTask` to null, and clear controllers.
- [cite_start]**`_toggleTaskStatus(String id)`:** Find task by ID, toggle `isCompleted` [cite: 21-23].
- [cite_start]**`_deleteTask(String id)`:** Remove task from `_tasks` immediately [cite: 27-29].
- [cite_start]**`_startEditing(Task task)`:** Populate controllers with the existing `task` data and set `_editingTask = task`.
- [cite_start]**Getter `_filteredAndSortedTasks`:** - First, filter `_tasks` based on `_filterType` ('Completed' or 'Incomplete') [cite: 54-57].
  - [cite_start]Then, sort the resulting list by `createdAt` descending.
- [cite_start]**Getter `_completedCount`:** Return the number of tasks where `isCompleted == true`.

## 5. UI Layout Structure (Build Method)
[cite_start]Wrap the app in `MaterialApp` and `Scaffold`[cite: 36, 37].

### 5.1. AppBar
- [cite_start]Title: "TODOLIST" (Centered, black text, white background)[cite: 38].

### 5.2. Body (`Column`)
**Part A: Input Form Section**
- [cite_start]4x `TextField` or `TextFormField` widgets for: Title, Content, Date, Type[cite: 11, 43]. Add proper underlining to match the UI.
- `ElevatedButton`: 
  - Color: Green.
  - Width: Full width (`double.infinity`).
  - [cite_start]Label: Dynamic ("ADD" if `_editingTask == null`, else "UPDATE")[cite: 12, 45].
  - `onPressed`: Call `_saveTask()`.

**Part B: Statistics & Filters (Bonus Features)**
- A `Row` displaying:
  - [cite_start]Total Tasks / Completed Tasks counter (e.g., "Total: ${_tasks.length} | Completed: $_completedCount").
- A `Row` of filter buttons (TextButtons or choice chips): "All", "Completed", "Incomplete". [cite_start]Changing these updates `_filterType` via `setState()` [cite: 54-57].

**Part C: Task List (`Expanded` -> `ListView.builder`)**
- [cite_start]Use `ListView.builder` iterating over `_filteredAndSortedTasks`[cite: 8, 41].
- [cite_start]Build each item using a custom Container or `ListTile` with a light green background[cite: 9, 42].
- **Leading:** `Checkbox` or `IconButton` bound to `task.isCompleted`. [cite_start]`onChanged` triggers `_toggleTaskStatus`[cite: 19].
- **Title/Subtitle:**
  - Display Title (Bold). [cite_start]If `isCompleted` is true, apply `TextDecoration.lineThrough` and change text color to grey[cite: 24, 25, 26].
  - Display Content, Date, and Type underneath.
- **Trailing:** A `Row` (using `mainAxisSize: MainAxisSize.min`) containing:
  - [cite_start]Edit `IconButton` (Green Pencil icon) -> calls `_startEditing(task)`.
  - [cite_start]Delete `IconButton` (Red Cross icon) -> calls `_deleteTask(task.id)`[cite: 20, 28].

## 6. Execution Instructions for Agent
Generate ONLY the valid Dart code for `main.dart`. Ensure the UI closely resembles the provided image logic (Input fields at the top, green full-width add button, list of light-green task cards below). [cite_start]Strictly adhere to the "No State Management Libraries" rule.