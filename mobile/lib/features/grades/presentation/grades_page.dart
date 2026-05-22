import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/gpa_utils.dart';
import '../../../data/models/models.dart';
import '../../shared/application/api_providers.dart';

class GradesPage extends ConsumerStatefulWidget {
  const GradesPage({super.key});

  @override
  ConsumerState<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends ConsumerState<GradesPage> {
  List<String>? _terms;
  List<GradeItem>? _grades;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ref.read(campusApiProvider).getGrades();
    setState(() {
      _terms = data.terms;
      _grades = data.grades;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('成绩查询')),
      body: _terms == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (_grades != null && _grades!.isNotEmpty)
                  ListTile(
                    title: const Text('全部学期加权 GPA'),
                    trailing: Text(
                      calcGpa(_grades!).toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ...?_terms?.map(
                  (t) {
                    final items = _grades!.where((g) => g.term == t).toList();
                    return ListTile(
                      title: Text(t),
                      subtitle: Text('${items.length} 门 · GPA ${calcGpa(items).toStringAsFixed(2)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/grades/${Uri.encodeComponent(t)}'),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
