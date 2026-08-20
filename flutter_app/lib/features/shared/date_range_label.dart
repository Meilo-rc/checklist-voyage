String compactDateRangeLabel(DateTime? start, DateTime? end) {
  final localStart = start?.toLocal();
  final localEnd = end?.toLocal();

  if (localStart == null && localEnd == null) return '';
  if (localStart == null) {
    return 'Jusqu’au ${_fullDate(localEnd!)}';
  }
  if (localEnd == null) {
    return 'Dès le ${_fullDate(localStart)}';
  }
  if (_isSameDay(localStart, localEnd)) {
    return _fullDate(localStart);
  }
  if (localStart.year == localEnd.year) {
    return '${_dayMonth(localStart)} — ${_dayMonth(localEnd)} ${localEnd.year}';
  }
  return '${_fullDate(localStart)} — ${_fullDate(localEnd)}';
}

String compactTripPeriodLabel(DateTime? start, DateTime? end) {
  final range = compactDateRangeLabel(start, end);
  if (start == null || end == null || end.isBefore(start)) return range;
  final nights = _dateOnly(end).difference(_dateOnly(start)).inDays;
  return '$range · ${nights + 1}j / ${nights}n';
}

const _months = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

String _dayMonth(DateTime value) => '${value.day} ${_months[value.month - 1]}';

String _fullDate(DateTime value) => '${_dayMonth(value)} ${value.year}';

bool _isSameDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
