import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/application/api_providers.dart';

class MarketDetailPage extends ConsumerStatefulWidget {
  const MarketDetailPage({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<MarketDetailPage> createState() => _MarketDetailPageState();
}

class _MarketDetailPageState extends ConsumerState<MarketDetailPage> {
  dynamic _item;

  Future<void> _load() async {
    final item = await ref.read(campusApiProvider).getMarketItem(widget.itemId);
    setState(() => _item = item);
  }

  Future<void> _toggleFavorite() async {
    if (_item == null) return;
    if (_item.favorited) {
      await ref.read(campusApiProvider).unfavoriteMarket(widget.itemId);
    } else {
      await ref.read(campusApiProvider).favoriteMarket(widget.itemId);
    }
    await _load();
  }

  Future<void> _report() async {
    await ref.read(campusApiProvider).reportMarket(widget.itemId);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('举报已提交')));
  }

  void _chat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('联系卖家'),
        content: Text('Mock 聊天：已向 ${_item?.sellerName ?? ''} 发送消息'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定'))],
      ),
    );
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
        title: const Text('商品详情'),
        actions: [
          IconButton(icon: const Icon(Icons.flag), onPressed: _report),
        ],
      ),
      body: _item == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_item.title, style: Theme.of(context).textTheme.headlineSmall),
                  Text('¥${_item.price} · ${_item.category}'),
                  Text('卖家：${_item.sellerName}'),
                  const SizedBox(height: 12),
                  if (_item.description.isNotEmpty) Text(_item.description),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_item.favorited ? Icons.favorite : Icons.favorite_border),
                        onPressed: _toggleFavorite,
                      ),
                      Expanded(
                        child: FilledButton(onPressed: _chat, child: const Text('联系卖家')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
