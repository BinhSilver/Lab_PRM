import 'dart:io';

// ============================================================
//  ABSTRACT BASE CLASS
// ============================================================
abstract class Employee {
  final String _id;
  String _fullName;
  double _baseSalary;

  Employee(this._id, this._fullName, this._baseSalary);

  String get id => _id;
  String get fullName => _fullName;
  double get baseSalary => _baseSalary;

  set fullName(String value) => _fullName = value;
  set baseSalary(double value) => _baseSalary = value;

  double getIncome();

  double getTax() {
    final income = getIncome();
    if (income < 9000000) {
      return 0.0;
    } else if (income <= 15000000) {
      return income * 0.10;
    } else {
      return income * 0.12;
    }
  }

  void displayInfo();
}

// ============================================================
//  SUBCLASS 1: AdministrativeEmployee
// ============================================================
class AdministrativeEmployee extends Employee {
  AdministrativeEmployee(String id, String fullName, double baseSalary)
      : super(id, fullName, baseSalary);

  @override
  double getIncome() => baseSalary;

  @override
  void displayInfo() {
    print('┌─────────────────────────────────────────────┐');
    print('│ Loại     : Nhân viên Hành chính              │');
    print('│ ID       : $_id');
    print('│ Họ tên   : $_fullName');
    print('│ Lương CB : ${_formatCurrency(baseSalary)}');
    print('│ Thu nhập : ${_formatCurrency(getIncome())}');
    print('│ Thuế     : ${_formatCurrency(getTax())}');
    print('└─────────────────────────────────────────────┘');
  }
}

// ============================================================
//  SUBCLASS 2: SalesEmployee
// ============================================================
class SalesEmployee extends Employee {
  double _salesRevenue;
  double _commissionRate;

  SalesEmployee(
    String id,
    String fullName,
    double baseSalary,
    this._salesRevenue,
    this._commissionRate,
  ) : super(id, fullName, baseSalary);

  double get salesRevenue => _salesRevenue;
  double get commissionRate => _commissionRate;

  set salesRevenue(double value) => _salesRevenue = value;
  set commissionRate(double value) => _commissionRate = value;

  @override
  double getIncome() => baseSalary + (_salesRevenue * _commissionRate);

  @override
  void displayInfo() {
    print('┌─────────────────────────────────────────────┐');
    print('│ Loại     : Nhân viên Kinh doanh              │');
    print('│ ID       : $_id');
    print('│ Họ tên   : $_fullName');
    print('│ Lương CB : ${_formatCurrency(baseSalary)}');
    print('│ Doanh thu: ${_formatCurrency(_salesRevenue)}');
    print('│ Hoa hồng : ${(_commissionRate * 100).toStringAsFixed(1)}%');
    print('│ Thu nhập : ${_formatCurrency(getIncome())}');
    print('│ Thuế     : ${_formatCurrency(getTax())}');
    print('└─────────────────────────────────────────────┘');
  }
}

// ============================================================
//  SUBCLASS 3: Manager
// ============================================================
class Manager extends Employee {
  double _responsibilityAllowance;

  Manager(
    String id,
    String fullName,
    double baseSalary,
    this._responsibilityAllowance,
  ) : super(id, fullName, baseSalary);

  double get responsibilityAllowance => _responsibilityAllowance;
  set responsibilityAllowance(double value) => _responsibilityAllowance = value;

  @override
  double getIncome() => baseSalary + _responsibilityAllowance;

  @override
  void displayInfo() {
    print('┌─────────────────────────────────────────────┐');
    print('│ Loại     : Quản lý                           │');
    print('│ ID       : $_id');
    print('│ Họ tên   : $_fullName');
    print('│ Lương CB : ${_formatCurrency(baseSalary)}');
    print('│ Phụ cấp  : ${_formatCurrency(_responsibilityAllowance)}');
    print('│ Thu nhập : ${_formatCurrency(getIncome())}');
    print('│ Thuế     : ${_formatCurrency(getTax())}');
    print('└─────────────────────────────────────────────┘');
  }
}

// ============================================================
//  UTILITY FUNCTIONS
// ============================================================
String _formatCurrency(double amount) {
  final parts = amount.toStringAsFixed(0).split('');
  final buffer = StringBuffer();
  int count = 0;
  for (int i = parts.length - 1; i >= 0; i--) {
    buffer.write(parts[i]);
    count++;
    if (count % 3 == 0 && i != 0) buffer.write('.');
  }
  return '${buffer.toString().split('').reversed.join('')} VNĐ';
}

String _readLine(String prompt) {
  stdout.write(prompt);
  return stdin.readLineSync()?.trim() ?? '';
}

double _readDouble(String prompt) {
  while (true) {
    final input = _readLine(prompt);
    final value = double.tryParse(input);
    if (value != null && value >= 0) return value;
    print('  [!] Vui lòng nhập số hợp lệ (>= 0).');
  }
}

int _readInt(String prompt, {int min = 1, int max = 10}) {
  while (true) {
    final input = _readLine(prompt);
    final value = int.tryParse(input);
    if (value != null && value >= min && value <= max) return value;
    print('  [!] Vui lòng nhập số nguyên từ $min đến $max.');
  }
}

void _pressEnterToContinue() {
  stdout.write('\n  Nhấn Enter để tiếp tục...');
  stdin.readLineSync();
}

// ============================================================
//  EMPLOYEE MANAGEMENT SYSTEM
// ============================================================
class EmployeeManagementSystem {
  final List<Employee> _employees = [];

  // ── MENU DISPLAY ──────────────────────────────────────────
  void _printMenu() {
    print('\n');
    print('╔══════════════════════════════════════════════════╗');
    print('║     HỆ THỐNG QUẢN LÝ LƯƠNG NHÂN VIÊN            ║');
    print('╠══════════════════════════════════════════════════╣');
    print('║  1. Thêm nhân viên                               ║');
    print('║  2. Hiển thị danh sách nhân viên                 ║');
    print('║  3. Tìm kiếm nhân viên theo ID                   ║');
    print('║  4. Xóa nhân viên theo ID                        ║');
    print('║  5. Cập nhật thông tin nhân viên                 ║');
    print('║  6. Tìm kiếm theo khoảng thu nhập               ║');
    print('║  7. Sắp xếp theo họ tên                          ║');
    print('║  8. Sắp xếp theo tổng thu nhập                   ║');
    print('║  9. Top 5 nhân viên thu nhập cao nhất            ║');
    print('║  0. Thoát                                        ║');
    print('╚══════════════════════════════════════════════════╝');
  }

  // ── 1. ADD EMPLOYEE ───────────────────────────────────────
  void _addEmployee() {
    print('\n--- THÊM NHÂN VIÊN ---');
    print('  Chọn loại nhân viên:');
    print('    1. Nhân viên Hành chính');
    print('    2. Nhân viên Kinh doanh');
    print('    3. Quản lý');
    final type = _readInt('  Loại (1-3): ', min: 1, max: 3);

    final id = _readLine('  Nhập ID       : ');
    if (id.isEmpty) { print('  [!] ID không được để trống.'); return; }
    if (_employees.any((e) => e.id == id)) {
      print('  [!] ID "$id" đã tồn tại.');
      return;
    }

    final fullName = _readLine('  Nhập họ tên   : ');
    if (fullName.isEmpty) { print('  [!] Họ tên không được để trống.'); return; }

    final baseSalary = _readDouble('  Lương cơ bản  : ');

    switch (type) {
      case 1:
        _employees.add(AdministrativeEmployee(id, fullName, baseSalary));
        break;
      case 2:
        final salesRevenue  = _readDouble('  Doanh thu     : ');
        final commissionRate = _readDouble('  Hoa hồng (0-1): ');
        _employees.add(SalesEmployee(id, fullName, baseSalary, salesRevenue, commissionRate));
        break;
      case 3:
        final allowance = _readDouble('  Phụ cấp trách nhiệm: ');
        _employees.add(Manager(id, fullName, baseSalary, allowance));
        break;
    }
    print('  [✓] Thêm nhân viên thành công!');
  }

  // ── 2. DISPLAY ALL ────────────────────────────────────────
  void _displayAll() {
    print('\n--- DANH SÁCH NHÂN VIÊN (${_employees.length} người) ---');
    if (_employees.isEmpty) {
      print('  Danh sách trống.');
      return;
    }
    for (final e in _employees) {
      e.displayInfo();
    }
  }

  // ── 3. SEARCH BY ID ───────────────────────────────────────
  void _searchById() {
    print('\n--- TÌM KIẾM THEO ID ---');
    final id = _readLine('  Nhập ID cần tìm: ');
    final found = _findById(id);
    if (found == null) {
      print('  [!] Không tìm thấy nhân viên có ID "$id".');
    } else {
      found.displayInfo();
    }
  }

  Employee? _findById(String id) {
    try {
      return _employees.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── 4. DELETE BY ID ───────────────────────────────────────
  void _deleteById() {
    print('\n--- XÓA NHÂN VIÊN THEO ID ---');
    final id = _readLine('  Nhập ID cần xóa: ');
    final found = _findById(id);
    if (found == null) {
      print('  [!] Không tìm thấy nhân viên có ID "$id".');
      return;
    }
    found.displayInfo();
    final confirm = _readLine('  Xác nhận xóa? (y/n): ');
    if (confirm.toLowerCase() == 'y') {
      _employees.remove(found);
      print('  [✓] Đã xóa nhân viên "$id".');
    } else {
      print('  [i] Hủy thao tác xóa.');
    }
  }

  // ── 5. UPDATE EMPLOYEE ────────────────────────────────────
  void _updateEmployee() {
    print('\n--- CẬP NHẬT THÔNG TIN NHÂN VIÊN ---');
    final id = _readLine('  Nhập ID nhân viên cần cập nhật: ');
    final found = _findById(id);
    if (found == null) {
      print('  [!] Không tìm thấy nhân viên có ID "$id".');
      return;
    }
    print('  Thông tin hiện tại:');
    found.displayInfo();

    final newName = _readLine('  Họ tên mới (Enter để giữ nguyên): ');
    if (newName.isNotEmpty) found.fullName = newName;

    final newSalaryStr = _readLine('  Lương CB mới  (Enter để giữ nguyên): ');
    if (newSalaryStr.isNotEmpty) {
      final v = double.tryParse(newSalaryStr);
      if (v != null && v >= 0) found.baseSalary = v;
    }

    if (found is SalesEmployee) {
      final revStr = _readLine('  Doanh thu mới (Enter để giữ nguyên): ');
      if (revStr.isNotEmpty) {
        final v = double.tryParse(revStr);
        if (v != null && v >= 0) found.salesRevenue = v;
      }
      final rateStr = _readLine('  Hoa hồng mới  (Enter để giữ nguyên): ');
      if (rateStr.isNotEmpty) {
        final v = double.tryParse(rateStr);
        if (v != null && v >= 0) found.commissionRate = v;
      }
    } else if (found is Manager) {
      final allowStr = _readLine('  Phụ cấp mới   (Enter để giữ nguyên): ');
      if (allowStr.isNotEmpty) {
        final v = double.tryParse(allowStr);
        if (v != null && v >= 0) found.responsibilityAllowance = v;
      }
    }

    print('  [✓] Cập nhật thành công!');
    found.displayInfo();
  }

  // ── 6. SEARCH BY INCOME RANGE ─────────────────────────────
  void _searchByIncomeRange() {
    print('\n--- TÌM KIẾM THEO KHOẢNG THU NHẬP ---');
    final min = _readDouble('  Thu nhập tối thiểu: ');
    final max = _readDouble('  Thu nhập tối đa   : ');
    if (min > max) {
      print('  [!] Thu nhập tối thiểu không được lớn hơn tối đa.');
      return;
    }
    final result = _employees.where((e) => e.getIncome() >= min && e.getIncome() <= max).toList();
    print('  Tìm thấy ${result.length} nhân viên:');
    if (result.isEmpty) {
      print('  Không có nhân viên nào trong khoảng thu nhập này.');
    } else {
      for (final e in result) e.displayInfo();
    }
  }

  // ── 7. SORT BY FULL NAME ──────────────────────────────────
  void _sortByName() {
    print('\n--- SẮP XẾP THEO HỌ TÊN ---');
    if (_employees.isEmpty) { print('  Danh sách trống.'); return; }
    _employees.sort((a, b) => a.fullName.compareTo(b.fullName));
    print('  [✓] Đã sắp xếp. Danh sách hiện tại:');
    for (final e in _employees) e.displayInfo();
  }

  // ── 8. SORT BY INCOME ─────────────────────────────────────
  void _sortByIncome() {
    print('\n--- SẮP XẾP THEO THU NHẬP ---');
    if (_employees.isEmpty) { print('  Danh sách trống.'); return; }
    _employees.sort((a, b) => b.getIncome().compareTo(a.getIncome()));
    print('  [✓] Đã sắp xếp (giảm dần). Danh sách hiện tại:');
    for (final e in _employees) e.displayInfo();
  }

  // ── 9. TOP 5 HIGHEST INCOME ───────────────────────────────
  void _showTop5() {
    print('\n--- TOP 5 NHÂN VIÊN THU NHẬP CAO NHẤT ---');
    if (_employees.isEmpty) { print('  Danh sách trống.'); return; }
    final sorted = List<Employee>.from(_employees)
      ..sort((a, b) => b.getIncome().compareTo(a.getIncome()));
    final top = sorted.take(5).toList();
    print('  Hiển thị top ${top.length} nhân viên:');
    for (int i = 0; i < top.length; i++) {
      print('  ★ Hạng ${i + 1}');
      top[i].displayInfo();
    }
  }

  // ── MAIN LOOP ─────────────────────────────────────────────
  void run() {
    print('  Chào mừng đến với Hệ thống Quản lý Lương Nhân viên!');
    int choice = -1;
    do {
      _printMenu();
      choice = _readInt('  Chọn chức năng (0-9): ', min: 0, max: 9);
      switch (choice) {
        case 1:  _addEmployee();         break;
        case 2:  _displayAll();          break;
        case 3:  _searchById();          break;
        case 4:  _deleteById();          break;
        case 5:  _updateEmployee();      break;
        case 6:  _searchByIncomeRange(); break;
        case 7:  _sortByName();          break;
        case 8:  _sortByIncome();        break;
        case 9:  _showTop5();            break;
        case 0:
          print('\n  [✓] Thoát chương trình. Tạm biệt!');
          break;
      }
      if (choice != 0) _pressEnterToContinue();
    } while (choice != 0);
  }
}

// ============================================================
//  ENTRY POINT
// ============================================================
void main() {
  EmployeeManagementSystem().run();
}
