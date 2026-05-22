import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/campus_api.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final campusApiProvider = Provider<CampusApi>(
  (ref) => CampusApi(ref.watch(apiClientProvider)),
);
