/// hh:mm dd/MM/yyyy
String formatDateTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final mo = dt.month.toString().padLeft(2, '0');
  return '$h:$m $d/$mo/${dt.year}';
}

/// dd/MM/yyyy
String formatDate(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final mo = dt.month.toString().padLeft(2, '0');
  return '$d/$mo/${dt.year}';
}

/// Weekday abbreviation: T2, T3, T4, T5, T6, T7, CN
String formatDayShort(DateTime dt) {
  const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  return labels[dt.weekday - 1]; // weekday: 1=Mon ... 7=Sun
}

/// minutes → "30 phút" | "2 giờ" | "1 giờ 30 phút"
String formatDuration(int minutes) {
  if (minutes < 60) return '$minutes phút';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h giờ' : '$h giờ $m phút';
}

/// daysUntilDue → human-readable relative label
String dueDateLabel(int? days) {
  if (days == null) return '';
  if (days < 0) return 'Quá hạn ${-days} ngày';
  if (days == 0) return 'Hết hạn hôm nay!';
  if (days == 1) return 'Còn 1 ngày';
  return 'Còn $days ngày';
}
