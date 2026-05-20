import '../core/constants/api_constants.dart';
import '../models/dashboard.dart';
import '../models/session.dart';
import '../models/stats.dart';
import 'api_service.dart';

class SessionService {
  final ApiService _api = ApiService();

  Future<SessionModel> createSession({
    required String category,
    required String taskName,
    required int duration,
    String notes = '',
  }) async {
    final res = await _api.post(
      ApiConstants.sessions,
      data: {
        'category': category,
        'task_name': taskName,
        'duration': duration,
        'notes': notes,
      },
    );
    return SessionModel.fromJson(res.data);
  }

  Future<List<SessionModel>> getSessions() async {
    final res = await _api.get(ApiConstants.sessions);
    return (res.data as List).map((s) => SessionModel.fromJson(s)).toList();
  }

  Future<void> deleteSession(int id) async {
    await _api.delete('${ApiConstants.sessions}/$id');
  }

  Future<DashboardData> getDashboard() async {
    final res = await _api.get(ApiConstants.dashboard);
    return DashboardData.fromJson(res.data);
  }

  Future<WeeklyStats> getWeeklyStats() async {
    final res = await _api.get(ApiConstants.weeklyStats);
    return WeeklyStats.fromJson(res.data);
  }

  Future<MonthlyStats> getMonthlyStats() async {
    final res = await _api.get(ApiConstants.monthlyStats);
    return MonthlyStats.fromJson(res.data);
  }
}
