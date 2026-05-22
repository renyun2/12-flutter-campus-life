import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/schedule_utils.dart';
import '../../../data/models/models.dart';
import '../../shared/application/api_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<CourseModel>? _todayCourses;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    final api = ref.read(campusApiProvider);
    final courses = await api.getCourses();
    final week = currentWeekOfSemester(DateTime.now());
    final weekCourses = coursesForWeek(courses, week);
    final today = DateTime.now().weekday;
    setState(() => _todayCourses = coursesForDay(weekCourses, today));
  }

  void _search() {
    final q = _searchCtrl.text.trim();
    if (q.isNotEmpty) context.push('/search?q=${Uri.encodeComponent(q)}');
  }

  @override
  Widget build(BuildContext context) {
    final entries = [
      ('课表', Icons.calendar_month, '/schedule'),
      ('成绩', Icons.grade, '/grades'),
      ('图书馆', Icons.menu_book, '/library'),
      ('食堂', Icons.restaurant, '/canteen'),
      ('校园卡', Icons.credit_card, '/campus-card'),
      ('失物招领', Icons.search, '/lost-found'),
      ('社团活动', Icons.groups, '/clubs'),
      ('校园地图', Icons.map, '/map'),
      ('二手市场', Icons.store, '/market'),
      ('消息', Icons.notifications, '/messages'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('校园生活'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _search),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadToday,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '搜索课程、图书、二手…',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _search),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            Text('今日课表', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_todayCourses == null)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_todayCourses!.isEmpty)
              const Card(child: ListTile(title: Text('今天没有课')))
            else
              ..._todayCourses!.map(
                (c) => Card(
                  child: ListTile(
                    title: Text(c.name),
                    subtitle: Text('${periodLabel(c.startPeriod, c.endPeriod)} · ${c.room}'),
                    onTap: () => context.push('/course/${c.id}'),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text('功能入口', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              children: entries
                  .map(
                    (e) => InkWell(
                      onTap: () => context.push(e.$3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(e.$2, size: 28),
                          const SizedBox(height: 4),
                          Text(e.$1, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
