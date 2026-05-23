import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_init.dart';
import '../../../data/models/models.dart';
import '../../shared/application/api_providers.dart';

class AuthState {
  AuthState({required this.token, required this.user});

  final String token;
  final UserModel user;
}

class AuthNotifier extends Notifier<AuthState?> {
  @override
  AuthState? build() {
    final box = Hive.box<String>(HiveInit.authBox);
    final token = box.get('token');
    final raw = box.get('user');
    if (token != null && raw != null) {
      try {
        final user = UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        ref.read(apiClientProvider).setToken(token);
        return AuthState(token: token, user: user);
      } catch (_) {
        box.clear();
        ref.read(apiClientProvider).setToken(null);
      }
    }
    return null;
  }

  Future<void> _persist(String token, UserModel user) async {
    final box = Hive.box<String>(HiveInit.authBox);
    await box.put('token', token);
    await box.put('user', jsonEncode(user.toJson()));
    ref.read(apiClientProvider).setToken(token);
    state = AuthState(token: token, user: user);
  }

  Future<void> login(String studentId, String password) async {
    if (studentId.trim().isEmpty) throw Exception('请输入学号');
    final result = await ref.read(campusApiProvider).login(studentId, password);
    await _persist(result.token, result.user);
  }

  Future<void> logout() async {
    try {
      await ref.read(campusApiProvider).logout();
    } catch (_) {}
    await Hive.box<String>(HiveInit.authBox).clear();
    ref.read(apiClientProvider).setToken(null);
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState?>(AuthNotifier.new);

final campusCardBalanceProvider = StateProvider<double>((ref) => 0);
