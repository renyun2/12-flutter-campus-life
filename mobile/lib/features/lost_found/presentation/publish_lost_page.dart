import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/application/api_providers.dart';

class PublishLostPage extends ConsumerStatefulWidget {
  const PublishLostPage({super.key});

  @override
  ConsumerState<PublishLostPage> createState() => _PublishLostPageState();
}

class _PublishLostPageState extends ConsumerState<PublishLostPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  var _type = 'lost';
  var _loading = false;

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(campusApiProvider).publishLostFound({
        'type': _type,
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'imageUrl': 'placeholder',
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
      appBar: AppBar(title: const Text('发布失物信息')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'lost', label: Text('寻物')),
              ButtonSegment(value: 'found', label: Text('招领')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),
          TextField(controller: _title, decoration: const InputDecoration(labelText: '标题', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 4,
            decoration: const InputDecoration(labelText: '描述', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
            child: const Text('图片占位（后续可上传）'),
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
