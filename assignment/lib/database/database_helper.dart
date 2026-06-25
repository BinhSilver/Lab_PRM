import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

// ★ Conditional import (compile-time):
//   Web   → db_platform_helper_web.dart  (dùng databaseFactoryFfiWeb)
//   Mobile → db_platform_helper_stub.dart (no-op)
import 'db_platform_helper_stub.dart'
    if (dart.library.html) 'db_platform_helper_web.dart';

import '../models/task.dart';

// ═══════════════════════════════════════════════════════
// DATABASE HELPER  –  Singleton, Cross-platform SQLite
// Hỗ trợ: Android/iOS (sqflite native) + Web (sqflite_ffi_web)
//
// Bảng dữ liệu:
//   users  – lưu tài khoản (id, username, password)
//   tasks  – lưu task, có cột userId để phân biệt từng user
// ═══════════════════════════════════════════════════════
class DatabaseHelper {
  // ── Singleton ──────────────────────────────────────
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  static Database? _db;

  // ── Constants ──────────────────────────────────────
  static const String _dbName    = 'task_manager.db';
  static const int    _dbVersion = 2; // tăng version để trigger onUpgrade

  // ── Table: users ───────────────────────────────────
  static const String tableUser    = 'users';
  static const String colUserId    = 'id';
  static const String colUsername  = 'username';
  static const String colPassword  = 'password';

  // ── Table: tasks ───────────────────────────────────
  static const String tableTask          = 'tasks';
  static const String colId              = 'id';
  static const String colTaskUserId      = 'userId';        // FK → users.id
  static const String colTitle           = 'title';
  static const String colIsCompleted     = 'isCompleted';
  static const String colCreatedAt       = 'createdAt';
  static const String colScheduledDate   = 'scheduledDate';
  static const String colDueDate         = 'dueDate';
  static const String colEstimatedMinutes = 'estimatedMinutes';
  static const String colPriority        = 'priority';

  // ── Database getter ────────────────────────────────
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // ── Init database ──────────────────────────────────
  Future<Database> _initDatabase() async {
    await initializeDatabaseFactory(); // web: set databaseFactoryFfiWeb

    if (kIsWeb) {
      return await openDatabase(
        _dbName,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } else {
      final dbPath  = await getDatabasesPath();
      final fullPath = p.join(dbPath, _dbName);
      return await openDatabase(
        fullPath,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
  }

  // ── Create schema ──────────────────────────────────
  Future<void> _onCreate(Database db, int version) async {
    // Bảng users
    await db.execute('''
      CREATE TABLE $tableUser (
        $colUserId   INTEGER PRIMARY KEY AUTOINCREMENT,
        $colUsername TEXT NOT NULL UNIQUE,
        $colPassword TEXT NOT NULL
      )
    ''');

    // Bảng tasks (có cột userId)
    // Giải thích: Bảng tasks có thêm trường userId làm khóa ngoại (FOREIGN KEY).
    // Khi thêm task, ứng dụng sẽ lưu luôn userId của người tạo để không bị lẫn với người khác.
    await db.execute('''
      CREATE TABLE $tableTask (
        $colId                INTEGER PRIMARY KEY AUTOINCREMENT,
        $colTaskUserId        INTEGER NOT NULL DEFAULT 0,
        $colTitle             TEXT    NOT NULL,
        $colIsCompleted       INTEGER NOT NULL DEFAULT 0,
        $colCreatedAt         TEXT    NOT NULL,
        $colScheduledDate     TEXT,
        $colDueDate           TEXT,
        $colEstimatedMinutes  INTEGER,
        $colPriority          INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY ($colTaskUserId) REFERENCES $tableUser($colUserId)
      )
    ''');
  }

  // ── Upgrade schema (v1 → v2) ───────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Thêm bảng users nếu chưa có
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableUser (
          $colUserId   INTEGER PRIMARY KEY AUTOINCREMENT,
          $colUsername TEXT NOT NULL UNIQUE,
          $colPassword TEXT NOT NULL
        )
      ''');

      // Thêm cột userId vào bảng tasks nếu chưa có
      try {
        await db.execute(
          'ALTER TABLE $tableTask ADD COLUMN $colTaskUserId INTEGER NOT NULL DEFAULT 0',
        );
      } catch (_) {
        // Column đã tồn tại — bỏ qua
      }
    }
  }

  // ══════════════════════════════════════════════════
  // USER AUTHENTICATION
  // ══════════════════════════════════════════════════

  /// Đăng nhập: kiểm tra username + password.
  /// - Trả về Map user nếu đúng.
  /// - Trả về null nếu username không tồn tại.
  /// - Ném [WrongPasswordException] nếu sai mật khẩu.
  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await database;
    // BƯỚC 1: Tìm kiếm tài khoản trong Database bằng Username
    final rows = await db.query(
      tableUser,
      where: '$colUsername = ?',
      whereArgs: [username.trim()],
    );

    if (rows.isEmpty) {
      // BƯỚC 2A (Đăng ký tự động): Nếu không tìm thấy Username,
      // hệ thống tự động tạo luôn tài khoản (tự động lưu vào DB)
      // và cho phép đăng nhập thành công.
      final newId = await db.insert(tableUser, {
        colUsername: username.trim(),
        colPassword: password,
      });
      return {colUserId: newId, colUsername: username.trim()};
    }

    // BƯỚC 2B (Kiểm tra mật khẩu): Nếu Username ĐÃ TỒN TẠI, 
    // lấy dữ liệu từ DB lên và kiểm tra password.
    final stored = rows.first;
    if (stored[colPassword] != password) {
      // BƯỚC 3: Mật khẩu sai thì chủ động ném ra Exception
      throw WrongPasswordException();
    }
    return stored;
  }

  // ══════════════════════════════════════════════════
  // TASK CRUD  (lọc theo userId)
  // ══════════════════════════════════════════════════

  /// Thêm task mới. Trả về id được tạo.
  Future<int> insertTask(Task task, int userId) async {
    final db  = await database;
    final map = task.toMap()..['userId'] = userId;
    return await db.insert(
      tableTask,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lấy danh sách task của một user cụ thể.
  Future<List<Task>> getTasks(int userId) async {
    final db   = await database;
    // Giải thích: Chỉ SELECT những task có cột userId bằng với userId truyền vào.
    // Điều này giúp cách ly dữ liệu: user nào chỉ nhìn thấy task của user đó.
    final maps = await db.query(
      tableTask,
      where:    '$colTaskUserId = ?',
      whereArgs: [userId],
      orderBy:  '$colCreatedAt DESC',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  /// Cập nhật trạng thái hoàn thành của task.
  Future<int> updateTaskStatus(int id, bool isCompleted) async {
    final db = await database;
    return await db.update(
      tableTask,
      {colIsCompleted: isCompleted ? 1 : 0},
      where:    '$colId = ?',
      whereArgs: [id],
    );
  }

  /// Cập nhật toàn bộ thông tin task.
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      tableTask,
      task.toMap(),
      where:    '$colId = ?',
      whereArgs: [task.id],
    );
  }

  /// Xóa task theo id.
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      tableTask,
      where:    '$colId = ?',
      whereArgs: [id],
    );
  }

  /// Đóng kết nối DB.
  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}

// ── Custom exception ──────────────────────────────────
class WrongPasswordException implements Exception {
  const WrongPasswordException();
  @override
  String toString() => 'Mật khẩu không chính xác';
}
