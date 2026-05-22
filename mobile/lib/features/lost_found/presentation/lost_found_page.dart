import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../shared/application/api_providers.dart';

class LostFoundPage extends ConsumerStatefulWidget {
  const LostFoundPage({super.key});

  @override
  ConsumerState<LostFoundPage> createState() => _LostFoundPageState();
}

class _LostFoundPageState extends ConsumerState<LostFoundPage> {
  List<LostFoundItem>? _items;

  Future<void> _load() async {
    final list = await ref.read(campusApiProvider).getLostFound();
    setState(() => _items = list);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('失物招领'),
          bottom: const TabBar(tabs: [Tab(text: '寻物'), Tab(text: '招领')]),
          actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/lost-found/publish')),
          ],
        ),
        body: _items == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: ['lost', 'found'].map((type) {
                  final filtered = _items!.where((e) => e.type == type).toList();
                  if (filtered.isEmpty) return const Center(child: Text('暂无记录'));
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      return ListTile(
                        title: Text(item.title),
                        subtitle: Text('${item.description} · ${item.status == 'open' ? '进行中' : '已解决'}'),
                      );
                    },
                  );
                }).toList(),
              ),
      ),
    );
  }
}
