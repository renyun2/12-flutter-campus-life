import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../shared/application/api_providers.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  List<BookModel>? _books;
  int _borrowed = 0;
  int _max = 5;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String? q}) async {
    final data = await ref.read(campusApiProvider).getBooks(q: q);
    setState(() {
      _books = data.books;
      _borrowed = data.borrowedCount;
      _max = data.maxBorrow;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('图书馆'),
          bottom: const TabBar(tabs: [Tab(text: '馆藏'), Tab(text: '在借')]),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => context.push('/library/records'),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      decoration: const InputDecoration(
                        hintText: '搜索书名/作者',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (v) => _load(q: v.trim()),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.search), onPressed: () => _load(q: _search.text.trim())),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('在借 $_borrowed / $_max 本'),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _books == null
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _books!.length,
                          itemBuilder: (_, i) {
                            final b = _books![i];
                            return ListTile(
                              title: Text(b.title),
                              subtitle: Text('${b.author} · 可借 ${b.available}/${b.total}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push('/book/${b.id}'),
                            );
                          },
                        ),
                  FutureBuilder<List<BorrowRecord>>(
                    future: ref.read(campusApiProvider).getBorrowRecords(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                      final records = snap.data!.where((r) => r.status == 'active').toList();
                      if (records.isEmpty) return const Center(child: Text('暂无在借'));
                      return ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (_, i) {
                          final r = records[i];
                          return ListTile(
                            title: Text(r.title),
                            subtitle: Text('应还 ${r.dueDate}${r.renewed ? ' · 已续借' : ''}'),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
