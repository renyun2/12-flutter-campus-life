import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/application/api_providers.dart';

class ClubDetailPage extends ConsumerStatefulWidget {
  const ClubDetailPage({super.key, required this.clubId});

  final String clubId;

  @override
  ConsumerState<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends ConsumerState<ClubDetailPage> {
  dynamic _club;
  var _loading = false;

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      await ref.read(campusApiProvider).registerClub(widget.clubId);
      _club = await ref.read(campusApiProvider).getClub(widget.clubId);
      setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('报名成功')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    ref.read(campusApiProvider).getClub(widget.clubId).then((c) => setState(() => _club = c));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('活动详情')),
      body: _club == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_club.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('时间：${_club.eventDate}'),
                  Text('地点：${_club.location}'),
                  Text('报名：${_club.registeredCount}/${_club.maxMembers}'),
                  const SizedBox(height: 12),
                  Text(_club.description),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _club.registered || _loading ? null : _register,
                      child: Text(_club.registered ? '已报名' : '立即报名'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
