import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/schedule_utils.dart';
import '../../shared/application/api_providers.dart';

class CourseDetailPage extends ConsumerStatefulWidget {
  const CourseDetailPage({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends ConsumerState<CourseDetailPage> {
  dynamic _course;

  @override
  void initState() {
    super.initState();
    ref.read(campusApiProvider).getCourse(widget.courseId).then((c) => setState(() => _course = c));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('课程详情')),
      body: _course == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(_course.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                ListTile(title: const Text('教师'), subtitle: Text(_course.teacher)),
                ListTile(title: const Text('教室'), subtitle: Text(_course.room)),
                ListTile(
                  title: const Text('时间'),
                  subtitle: Text('${weekDays[_course.dayOfWeek]} ${periodLabel(_course.startPeriod, _course.endPeriod)}'),
                ),
                ListTile(title: const Text('作业提醒'), subtitle: Text(_course.homework.isEmpty ? '暂无' : _course.homework)),
              ],
            ),
    );
  }
}
