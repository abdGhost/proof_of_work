import 'session.dart';

class DashboardData {
  final double todayHours;
  final double weeklyHours;
  final double monthlyHours;
  final int currentStreak;
  final int bestStreak;
  final int proofScore;
  final List<SessionModel> recentSessions;

  DashboardData({
    required this.todayHours,
    required this.weeklyHours,
    required this.monthlyHours,
    required this.currentStreak,
    required this.bestStreak,
    required this.proofScore,
    required this.recentSessions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      todayHours: (json['today_hours'] ?? 0).toDouble(),
      weeklyHours: (json['weekly_hours'] ?? 0).toDouble(),
      monthlyHours: (json['monthly_hours'] ?? 0).toDouble(),
      currentStreak: json['current_streak'] ?? 0,
      bestStreak: json['best_streak'] ?? 0,
      proofScore: json['proof_score'] ?? 0,
      recentSessions: (json['recent_sessions'] as List? ?? [])
          .map((s) => SessionModel.fromJson(s))
          .toList(),
    );
  }
}
