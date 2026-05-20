class WeeklyStats {
  final double totalHours;
  final int totalSessions;
  final Map<String, dynamic> dailyBreakdown;

  WeeklyStats({
    required this.totalHours,
    required this.totalSessions,
    required this.dailyBreakdown,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      totalHours: (json['total_hours'] ?? 0).toDouble(),
      totalSessions: json['total_sessions'] ?? 0,
      dailyBreakdown: json['daily_breakdown'] ?? {},
    );
  }
}

class MonthlyStats {
  final double totalHours;
  final int totalSessions;
  final Map<String, dynamic> categoryBreakdown;

  MonthlyStats({
    required this.totalHours,
    required this.totalSessions,
    required this.categoryBreakdown,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    return MonthlyStats(
      totalHours: (json['total_hours'] ?? 0).toDouble(),
      totalSessions: json['total_sessions'] ?? 0,
      categoryBreakdown: json['category_breakdown'] ?? {},
    );
  }
}
