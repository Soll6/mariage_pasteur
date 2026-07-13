class ActivityLog {
  static const String actionLogin = 'login';
  static const String actionRsvp = 'rsvp';
  static const String actionUpload = 'upload';
  static const String actionModerate = 'moderate';
  static const String actionComment = 'comment';
  static const String actionLike = 'like';

  final String id;
  final String userId;
  final String actionType;
  final String? metadata;
  final DateTime createdAt;

  const ActivityLog({
    required this.id,
    required this.userId,
    required this.actionType,
    this.metadata,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      actionType: json['action_type'] as String? ?? '',
      metadata: json['metadata'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'action_type': actionType,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ActivityLog copyWith({
    String? id,
    String? userId,
    String? actionType,
    String? metadata,
    DateTime? createdAt,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      actionType: actionType ?? this.actionType,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
