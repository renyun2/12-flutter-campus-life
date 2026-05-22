import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../../shared/application/api_providers.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  List<MessageModel>? _messages;

  Future<void> _load() async {
    final list = await ref.read(campusApiProvider).getMessages();
    setState(() => _messages = list);
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
          title: const Text('消息中心'),
          bottom: const TabBar(tabs: [Tab(text: '系统通知'), Tab(text: '交易消息')]),
        ),
        body: _messages == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: ['system', 'library'].map((type) {
                  final filtered = _messages!.where((m) => m.type == type || (type == 'system' && m.type != 'trade')).toList();
                  if (type == 'library') {
                    final trade = _messages!.where((m) => m.type == 'trade').toList();
                    final items = [...trade, ...filtered.where((m) => m.type == 'library')];
                    if (items.isEmpty) return const Center(child: Text('暂无消息'));
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, i) => ListTile(
                        title: Text(items[i].title),
                        subtitle: Text(items[i].body),
                        leading: Icon(items[i].read ? Icons.mark_email_read : Icons.mark_email_unread),
                      ),
                    );
                  }
                  final sys = _messages!.where((m) => m.type == 'system').toList();
                  if (sys.isEmpty) return const Center(child: Text('暂无消息'));
                  return ListView.builder(
                    itemCount: sys.length,
                    itemBuilder: (_, i) => ListTile(
                      title: Text(sys[i].title),
                      subtitle: Text(sys[i].body),
                      leading: Icon(sys[i].read ? Icons.notifications : Icons.notifications_active),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
