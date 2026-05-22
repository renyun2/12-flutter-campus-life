import '../../data/models/models.dart';

const periodTimes = [
  '08:00',
  '08:55',
  '10:00',
  '10:55',
  '14:00',
  '14:55',
  '16:00',
  '16:55',
  '19:00',
  '19:55',
];

const weekDays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];

int currentWeekOfSemester(DateTime now) {
  final start = DateTime(now.year, 2, 17);
  final diff = now.difference(start).inDays;
  if (diff < 0) return 1;
  return (diff ~/ 7) + 1;
}

List<CourseModel> coursesForWeek(List<CourseModel> all, int week) {
  return all.where((c) => c.weeks.isEmpty || c.weeks.contains(week)).toList();
}

List<CourseModel> coursesForDay(List<CourseModel> weekCourses, int day) {
  return weekCourses.where((c) => c.dayOfWeek == day).toList()
    ..sort((a, b) => a.startPeriod.compareTo(b.startPeriod));
}

String periodLabel(int start, int end) {
  if (start == end) return '第$start节';
  return '第$start-$end节';
}
