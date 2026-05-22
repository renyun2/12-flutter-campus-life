import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_provider.dart';
import '../../shared/application/api_providers.dart';

class TopupPage extends ConsumerStatefulWidget {
  const TopupPage({super.key});

  @override
  ConsumerState<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends ConsumerState<TopupPage> {
  final _amount = TextEditingController(text: '50');
  var _loading = false;

  Future<void> _submit() async {
    final v = double.tryParse(_amount.text);
    if (v == null || v <= 0) return;
    setState(() => _loading = true);
    try {
      final balance = await ref.read(campusApiProvider).topup(v);
      ref.read(campusCardBalanceProvider.notifier).state = balance;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('充值成功，余额 ¥${balance.toStringAsFixed(2)}')));
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
      appBar: AppBar(title: const Text('校园卡充值')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '充值金额', border: OutlineInputBorder(), prefixText: '¥'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [20, 50, 100, 200]
                  .map((a) => ActionChip(label: Text('¥$a'), onPressed: () => _amount.text = '$a'))
                  .toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('确认充值（Mock）'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
