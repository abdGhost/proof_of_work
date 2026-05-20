class SessionModel {
  final int id;
  final int userId;
  final String category;
  final String taskName;
  final int duration;
  final String notes;
  final String createdAt;

  SessionModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.taskName,
    required this.duration,
    required this.notes,
    required this.createdAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      category: json['category'] ?? '',
      taskName: json['task_name'] ?? '',
      duration: json['duration'] ?? 0,
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'task_name': taskName,
    'duration': duration,
    'notes': notes,
  };

  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
