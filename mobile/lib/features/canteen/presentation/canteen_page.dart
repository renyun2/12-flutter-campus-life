import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../shared/application/api_providers.dart';

class CanteenPage extends ConsumerStatefulWidget {
  const CanteenPage({super.key});

  @override
  ConsumerState<CanteenPage> createState() => _CanteenPageState();
}

class _CanteenPageState extends ConsumerState<CanteenPage> {
  List<Map<String, String>>? _canteens;
  List<DishModel>? _dishes;
  String? _filter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ref.read(campusApiProvider).getCanteen();
    setState(() {
      _canteens = data.canteens;
      _dishes = data.dishes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dishes = _filter == null
        ? _dishes
        : _dishes?.where((d) => d.canteenId == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('食堂菜单')),
      body: _dishes == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: const Text('全部'),
                          selected: _filter == null,
                          onSelected: (_) => setState(() => _filter = null),
                        ),
                      ),
                      ...?_canteens?.map(
                        (c) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(c['name']!),
                            selected: _filter == c['id'],
                            onSelected: (_) => setState(() => _filter = c['id']),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: dishes?.length ?? 0,
                    itemBuilder: (_, i) {
                      final d = dishes![i];
                      return ListTile(
                        title: Text(d.name),
                        subtitle: Text('¥${d.price.toStringAsFixed(1)} · 评分 ${d.rating}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/dish/${d.id}'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
