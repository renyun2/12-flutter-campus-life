import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../shared/application/api_providers.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  List<MarketItem>? _market;
  List<ClubModel>? _clubs;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final api = ref.read(campusApiProvider);
    final market = await api.getMarket();
    final clubs = await api.getClubs();
    setState(() {
      _market = market;
      _clubs = clubs;
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: '二手市场'), Tab(text: '社团活动')],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (_tab.index == 0) {
                context.push('/market/publish');
              } else {
                context.push('/clubs');
              }
            },
          ),
        ],
      ),
      body: _market == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [
                RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _market!.length,
                    itemBuilder: (_, i) {
                      final m = _market![i];
                      return ListTile(
                        title: Text(m.title),
                        subtitle: Text('${m.category} · ¥${m.price.toStringAsFixed(0)}'),
                        onTap: () => context.push('/market/${m.id}'),
                      );
                    },
                  ),
                ),
                RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _clubs!.length,
                    itemBuilder: (_, i) {
                      final c = _clubs![i];
                      return ListTile(
                        title: Text(c.name),
                        subtitle: Text('${c.eventDate} · ${c.location}'),
                        onTap: () => context.push('/club/${c.id}'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
