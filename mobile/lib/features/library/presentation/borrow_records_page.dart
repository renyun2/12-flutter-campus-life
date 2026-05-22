import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/application/api_providers.dart';

class BorrowRecordsPage extends ConsumerStatefulWidget {
  const BorrowRecordsPage({super.key});

  @override
  ConsumerState<BorrowRecordsPage> createState() => _BorrowRecordsPageState();
}

class _BorrowRecordsPageState extends ConsumerState<BorrowRecordsPage> {
  dynamic _records;

  Future<void> _load() async {
    final list = await ref.read(campusApiProvider).getBorrowRecords();
    setState(() => _records = list);
  }

  Future<void> _renew(String id) async {
    try {
      await ref.read(campusApiProvider).renewBook(id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('续借成功')));
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('借阅记录')),
      body: _records == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _records.length,
                itemBuilder: (_, i) {
                  final r = _records[i];
                  return ListTile(
                    title: Text(r.title),
                    subtitle: Text('应还 ${r.dueDate} · ${r.status}'),
                    trailing: r.status == 'active' && !r.renewed
                        ? TextButton(onPressed: () => _renew(r.id), child: const Text('续借'))
                        : null,
                  );
                },
              ),
            ),
    );
  }
}
