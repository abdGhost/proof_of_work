import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/stats.dart';
import '../../dashboard/providers/dashboard_provider.dart';

final weeklyStatsProvider = FutureProvider.autoDispose<WeeklyStats>((
  ref,
) async {
  final service = ref.read(sessionServiceProvider);
  return service.getWeeklyStats();
});

final monthlyStatsProvider = FutureProvider.autoDispose<MonthlyStats>((
  ref,
) async {
  final service = ref.read(sessionServiceProvider);
  return service.getMonthlyStats();
});
