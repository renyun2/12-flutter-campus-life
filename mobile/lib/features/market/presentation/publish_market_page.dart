import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/application/api_providers.dart';

class PublishMarketPage extends ConsumerStatefulWidget {
  const PublishMarketPage({super.key});

  @override
  ConsumerState<PublishMarketPage> createState() => _PublishMarketPageState();
}

class _PublishMarketPageState extends ConsumerState<PublishMarketPage> {
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _category = TextEditingController(text: '数码');
  final _desc = TextEditingController();
  var _loading = false;

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty || _price.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(campusApiProvider).publishMarket({
        'title': _title.text.trim(),
        'price': double.parse(_price.text),
        'category': _category.text.trim(),
        'description': _desc.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('发布成功')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发布二手')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: '标题', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '价格', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(controller: _category, decoration: const InputDecoration(labelText: '分类', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 3,
            decoration: const InputDecoration(labelText: '描述', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('发布'),
          ),
        ],
      ),
    );
  }
}
