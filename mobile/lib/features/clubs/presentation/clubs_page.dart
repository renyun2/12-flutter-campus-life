import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../shared/application/api_providers.dart';

class ClubsPage extends ConsumerStatefulWidget {
  const ClubsPage({super.key});

  @override
  ConsumerState<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends ConsumerState<ClubsPage> {
  List<ClubModel>? _clubs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ref.read(campusApiProvider).getClubs();
    setState(() => _clubs = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('社团活动')),
      body: _clubs == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _clubs!.length,
                itemBuilder: (_, i) {
                  final c = _clubs![i];
                  return ListTile(
                    title: Text(c.name),
                    subtitle: Text('${c.eventDate} · ${c.location} · ${c.registeredCount}/${c.maxMembers}人'),
                    trailing: c.registered ? const Text('已报名') : const Icon(Icons.chevron_right),
                    onTap: () => context.push('/club/${c.id}'),
                  );
                },
              ),
            ),
    );
  }
}
