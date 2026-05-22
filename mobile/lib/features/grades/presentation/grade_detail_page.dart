import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/application/api_providers.dart';

class GradeDetailPage extends ConsumerStatefulWidget {
  const GradeDetailPage({super.key, required this.termId});

  final String termId;

  @override
  ConsumerState<GradeDetailPage> createState() => _GradeDetailPageState();
}

class _GradeDetailPageState extends ConsumerState<GradeDetailPage> {
  dynamic _data;

  @override
  void initState() {
    super.initState();
    ref.read(campusApiProvider).getTermGrades(widget.termId).then((d) => setState(() => _data = d));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_data?.term ?? widget.termId)),
      body: _data == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  title: const Text('学期 GPA'),
                  trailing: Text(_data.gpa.toStringAsFixed(2)),
                ),
                ListTile(
                  title: const Text('总学分'),
                  trailing: Text('${_data.totalCredit}'),
                ),
                const Divider(),
                ..._data.items.map<Widget>(
                  (g) => ListTile(
                    title: Text(g.courseName),
                    subtitle: Text('学分 ${g.credit}'),
                    trailing: Text('${g.score}'),
                  ),
                ),
              ],
            ),
    );
  }
}
