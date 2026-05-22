import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../shared/application/api_providers.dart';

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage> {
  List<MarketItem>? _items;
  final _search = TextEditingController();

  Future<void> _load({String? q}) async {
    final list = await ref.read(campusApiProvider).getMarket(q: q);
    setState(() => _items = list);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('二手市场'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/market/publish')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: '搜索商品',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: () => _load(q: _search.text.trim())),
              ),
              onSubmitted: (v) => _load(q: v.trim()),
            ),
          ),
          Expanded(
            child: _items == null
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _items!.length,
                    itemBuilder: (_, i) {
                      final m = _items![i];
                      return ListTile(
                        leading: m.favorited ? const Icon(Icons.favorite, color: Colors.red) : null,
                        title: Text(m.title),
                        subtitle: Text('${m.category} · ${m.sellerName}'),
                        trailing: Text('¥${m.price.toStringAsFixed(0)}'),
                        onTap: () => context.push('/market/${m.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
