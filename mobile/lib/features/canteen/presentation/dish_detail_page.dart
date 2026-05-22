import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/application/api_providers.dart';

class DishDetailPage extends ConsumerStatefulWidget {
  const DishDetailPage({super.key, required this.dishId});

  final String dishId;

  @override
  ConsumerState<DishDetailPage> createState() => _DishDetailPageState();
}

class _DishDetailPageState extends ConsumerState<DishDetailPage> {
  dynamic _dish;
  var _favorited = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dish = await ref.read(campusApiProvider).getDish(widget.dishId);
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('dish_favorites') ?? [];
    setState(() {
      _dish = dish;
      _favorited = favs.contains(widget.dishId);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('dish_favorites') ?? [];
    if (_favorited) {
      favs.remove(widget.dishId);
    } else {
      favs.add(widget.dishId);
    }
    await prefs.setStringList('dish_favorites', favs);
    setState(() => _favorited = !_favorited);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('菜品详情'),
        actions: [
          IconButton(
            icon: Icon(_favorited ? Icons.favorite : Icons.favorite_border),
            onPressed: _dish == null ? null : _toggleFavorite,
          ),
        ],
      ),
      body: _dish == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(_dish.name, style: Theme.of(context).textTheme.headlineSmall),
                Text('¥${_dish.price} · 评分 ${_dish.rating}'),
                const SizedBox(height: 12),
                if (_dish.description.isNotEmpty) Text(_dish.description),
                const SizedBox(height: 12),
                const Text('营养信息'),
                ..._dish.nutrition.entries.map((e) => ListTile(title: Text('${e.key}: ${e.value}'))),
              ],
            ),
    );
  }
}
