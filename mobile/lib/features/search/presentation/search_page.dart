import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/application/api_providers.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, required this.query});

  final String query;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  Map<String, List<Map<String, String>>>? _results;

  @override
  void initState() {
    super.initState();
    if (widget.query.isNotEmpty) _search(widget.query);
  }

  Future<void> _search(String q) async {
    final data = await ref.read(campusApiProvider).search(q);
    setState(() => _results = data);
  }

  void _openItem(Map<String, String> item) {
    switch (item['type']) {
      case 'course':
        context.push('/course/${item['id']}');
      case 'book':
        context.push('/book/${item['id']}');
      default:
        context.push('/market/${item['id']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('搜索：${widget.query}')),
      body: _results == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (_results!['courses']!.isNotEmpty) ...[
                  const ListTile(title: Text('课程', style: TextStyle(fontWeight: FontWeight.bold))),
                  ..._results!['courses']!.map(
                    (e) => ListTile(title: Text(e['title']!), onTap: () => _openItem(e)),
                  ),
                ],
                if (_results!['books']!.isNotEmpty) ...[
                  const ListTile(title: Text('图书', style: TextStyle(fontWeight: FontWeight.bold))),
                  ..._results!['books']!.map(
                    (e) => ListTile(title: Text(e['title']!), onTap: () => _openItem(e)),
                  ),
                ],
                if (_results!['market']!.isNotEmpty) ...[
                  const ListTile(title: Text('二手', style: TextStyle(fontWeight: FontWeight.bold))),
                  ..._results!['market']!.map(
                    (e) => ListTile(title: Text(e['title']!), onTap: () => _openItem(e)),
                  ),
                ],
                if (_results!['courses']!.isEmpty &&
                    _results!['books']!.isEmpty &&
                    _results!['market']!.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('无结果'))),
              ],
            ),
    );
  }
}
