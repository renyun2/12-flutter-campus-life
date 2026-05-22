import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth?.user;

    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: ListView(
        children: [
          if (user != null)
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user.name),
              subtitle: Text('${user.studentId} · ${user.major} · ${user.grade}'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('校园卡'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/campus-card'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('消息中心'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/messages'),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('校园地图'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/map'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置'),
            subtitle: const Text('后续可扩展'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('退出登录', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
