import 'package:flutter_test/flutter_test.dart';

import 'package:campus_life/core/utils/gpa_utils.dart';
import 'package:campus_life/core/utils/schedule_utils.dart';
import 'package:campus_life/data/models/models.dart';

void main() {
  test('GPA calculation', () {
    final items = [
      GradeItem(id: '1', term: 't', courseName: 'A', score: 90, credit: 4),
      GradeItem(id: '2', term: 't', courseName: 'B', score: 80, credit: 2),
    ];
    expect(calcGpa(items), closeTo(3.47, 0.01));
  });

  test('week course filter', () {
    final courses = [
      CourseModel(
        id: '1',
        name: 'Math',
        teacher: 'T',
        room: 'R',
        dayOfWeek: 1,
        startPeriod: 1,
        endPeriod: 2,
        weeks: [1, 2, 3],
      ),
    ];
    expect(coursesForWeek(courses, 2).length, 1);
    expect(coursesForWeek(courses, 5).length, 0);
  });
}
