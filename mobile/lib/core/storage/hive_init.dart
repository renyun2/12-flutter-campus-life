import 'package:hive_flutter/hive_flutter.dart';

class HiveInit {
  static const authBox = 'auth';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(authBox);
  }
}
