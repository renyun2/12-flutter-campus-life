import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../auth/application/auth_provider.dart';
import '../../shared/application/api_providers.dart';

class CampusCardPage extends ConsumerStatefulWidget {
  const CampusCardPage({super.key});

  @override
  ConsumerState<CampusCardPage> createState() => _CampusCardPageState();
}

class _CampusCardPageState extends ConsumerState<CampusCardPage> {
  double _balance = 0;
  dynamic _transactions;
  var _days = 7;

  Future<void> _load() async {
    final data = await ref.read(campusApiProvider).getCampusCard(days: _days);
    ref.read(campusCardBalanceProvider.notifier).state = data.balance;
    setState(() {
      _balance = data.balance;
      _transactions = data.transactions;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider)?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('校园卡'),
        actions: [
          IconButton(icon: const Icon(Icons.add_card), onPressed: () => context.push('/campus-card/topup')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('余额', style: Theme.of(context).textTheme.titleMedium),
                    Text('¥${_balance.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    if (user != null)
                      QrImageView(
                        data: 'CAMPUS:${user.studentId}:${_balance.toStringAsFixed(2)}',
                        size: 120,
                      ),
                    const SizedBox(height: 8),
                    const Text('付款码（Mock）'),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('近7天'),
                  selected: _days == 7,
                  onSelected: (_) {
                    _days = 7;
                    _load();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('近30天'),
                  selected: _days == 30,
                  onSelected: (_) {
                    _days = 30;
                    _load();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('消费流水', style: Theme.of(context).textTheme.titleMedium),
            if (_transactions == null)
              const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
            else if (_transactions.isEmpty)
              const ListTile(title: Text('暂无记录'))
            else
              ..._transactions.map<Widget>(
                (t) => ListTile(
                  title: Text(t.description),
                  subtitle: Text(t.createdAt),
                  trailing: Text(
                    '${t.amount >= 0 ? '+' : ''}${t.amount.toStringAsFixed(2)}',
                    style: TextStyle(color: t.amount >= 0 ? Colors.green : Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
