class Ceremony {
  final String title;
  final String description;
  final String time;
  final String location;
  final String icon;
  final double latitude;
  final double longitude;

  const Ceremony({
    required this.title,
    required this.description,
    required this.time,
    required this.location,
    required this.icon,
    required this.latitude,
    required this.longitude,
  });
}

class GalleryPhoto {
  final String photoUrl;
  final String caption;

  const GalleryPhoto({
    required this.photoUrl,
    required this.caption,
  });
}

class GalleryPost {
  final String id;
  final String userId;
  final String? guestId;
  final String content;
  final String mediaType;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final int likesCount;
  final int commentsCount;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? displayName;
  final String? avatarUrl;

  const GalleryPost({
    required this.id,
    required this.userId,
    this.guestId,
    required this.content,
    required this.mediaType,
    this.mediaUrl,
    this.thumbnailUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.displayName,
    this.avatarUrl,
  });

  factory GalleryPost.fromMap(Map<String, dynamic> map) {
    // Handle nested user_profiles from Supabase join
    final userProfile = map['user_profiles'] is Map ? map['user_profiles'] as Map<String, dynamic> : null;

    // Generate a fallback display name from user_id
    String? displayName = userProfile?['display_name'] ?? map['display_name'];
    if (displayName == null || displayName.isEmpty) {
      final userId = map['user_id'] ?? '';
      if (userId.isNotEmpty) {
        displayName = 'Invité ${userId.substring(0, 6).toUpperCase()}';
      } else {
        displayName = 'Invité';
      }
    }

    return GalleryPost(
      id: map['id'],
      userId: map['user_id'],
      guestId: map['guest_id'],
      content: map['content'] ?? '',
      mediaType: map['media_type'] ?? 'image',
      mediaUrl: map['media_url'],
      thumbnailUrl: map['thumbnail_url'],
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      status: map['status'] ?? 'published',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      displayName: displayName,
      avatarUrl: userProfile?['avatar_url'] ?? map['avatar_url'],
    );
  }
}

class PostComment {
  final String id;
  final String postId;
  final String userId;
  final String comment;
  final String status;
  final DateTime createdAt;
  final String? displayName;

  const PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.comment,
    required this.status,
    required this.createdAt,
    this.displayName,
  });

  factory PostComment.fromMap(Map<String, dynamic> map) {
    return PostComment(
      id: map['id'],
      postId: map['post_id'],
      userId: map['user_id'],
      comment: map['comment'],
      status: map['status'] ?? 'published',
      createdAt: DateTime.parse(map['created_at']),
      displayName: map['display_name'],
    );
  }
}

class PostLike {
  final String id;
  final String postId;
  final String userId;
  final DateTime createdAt;

  const PostLike({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  factory PostLike.fromMap(Map<String, dynamic> map) {
    return PostLike(
      id: map['id'],
      postId: map['post_id'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class RSVPResponse {
  final String firstName;
  final String lastName;
  final bool attending;
  final int guestCount;
  final String dietaryRequirements;

  RSVPResponse({
    required this.firstName,
    required this.lastName,
    required this.attending,
    required this.guestCount,
    this.dietaryRequirements = '',
  });
}

class TimelineEvent {
  final String title;
  final String description;
  final String time;
  final String location;
  final String icon;
  final String imageUrl;

  const TimelineEvent({
    required this.title,
    required this.description,
    required this.time,
    required this.location,
    required this.icon,
    required this.imageUrl,
  });
}
