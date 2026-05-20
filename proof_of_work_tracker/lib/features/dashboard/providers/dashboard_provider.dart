import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/dashboard.dart';
import '../../../services/session_service.dart';

final sessionServiceProvider = Provider<SessionService>(
  (ref) => SessionService(),
);

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((
  ref,
) async {
  final service = ref.read(sessionServiceProvider);
  return service.getDashboard();
});
