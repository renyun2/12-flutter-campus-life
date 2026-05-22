import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/application/api_providers.dart';

class BookDetailPage extends ConsumerStatefulWidget {
  const BookDetailPage({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  dynamic _book;
  var _loading = false;

  Future<void> _borrow() async {
    setState(() => _loading = true);
    try {
      await ref.read(campusApiProvider).borrowBook(widget.bookId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('借阅成功')));
        _book = await ref.read(campusApiProvider).getBook(widget.bookId);
        setState(() {});
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    ref.read(campusApiProvider).getBook(widget.bookId).then((b) => setState(() => _book = b));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图书详情')),
      body: _book == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_book.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('作者：${_book.author}'),
                  Text('馆藏位置：${_book.location}'),
                  Text('可借：${_book.available}/${_book.total}'),
                  if (_book.summary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_book.summary),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _book.available > 0 && !_loading ? _borrow : null,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('借阅'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
