import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/schedule_utils.dart';
import '../../../data/models/models.dart';
import '../../shared/application/api_providers.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  var _week = currentWeekOfSemester(DateTime.now());
  List<CourseModel>? _courses;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ref.read(campusApiProvider).getCourses();
    setState(() => _courses = list);
  }

  Future<void> _addCourse() async {
    final nameCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加自定义课程'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: '课程名称'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('添加')),
        ],
      ),
    );
    if (ok != true || nameCtrl.text.trim().isEmpty) return;
    await ref.read(campusApiProvider).addCourse({
      'name': nameCtrl.text.trim(),
      'teacher': '待定',
      'room': '待定',
      'dayOfWeek': DateTime.now().weekday,
      'startPeriod': 1,
      'endPeriod': 2,
      'weeks': [_week],
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final weekCourses = _courses == null ? <CourseModel>[] : coursesForWeek(_courses!, _week);

    return Scaffold(
      appBar: AppBar(
        title: Text('第 $_week 周课表'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addCourse),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _week > 1 ? () => setState(() => _week--) : null,
              ),
              Text('第 $_week 周'),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _week++)),
            ],
          ),
          Expanded(
            child: _courses == null
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: 7,
                    itemBuilder: (context, i) {
                      final day = i + 1;
                      final dayCourses = coursesForDay(weekCourses, day);
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ExpansionTile(
                          title: Text(weekDays[day]),
                          subtitle: Text('${dayCourses.length} 节课'),
                          children: dayCourses.isEmpty
                              ? [const ListTile(title: Text('无课'))]
                              : dayCourses
                                  .map(
                                    (c) => ListTile(
                                      title: Text(c.name),
                                      subtitle: Text(
                                        '${periodLabel(c.startPeriod, c.endPeriod)} · ${c.teacher} · ${c.room}',
                                      ),
                                      onTap: () => context.push('/course/${c.id}'),
                                    ),
                                  )
                                  .toList(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
