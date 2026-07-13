import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/wedding_data.dart';
import '../services/gallery_post_service.dart';

class GalleryPostCard extends StatelessWidget {
  final GalleryPost post;
  final GalleryPostService service;
  final VoidCallback? onTap;

  const GalleryPostCard({
    super.key,
    required this.post,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          // Content
          if (post.content.isNotEmpty) _buildContent(),
          // Media
          if (post.mediaUrl != null) _buildMedia(),
          // Actions
          _buildActions(),
          // Stats
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: post.avatarUrl != null
                ? NetworkImage(post.avatarUrl!)
                : null,
            child: post.avatarUrl == null
                ? Text(
                    post.displayName?.substring(0, 1).toUpperCase() ?? '?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.displayName ?? 'Invité',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  _formatTime(post.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        post.content,
        style: const TextStyle(fontSize: 15, height: 1.4),
      ),
    );
  }

  Widget _buildMedia() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 400),
        child: Image.network(
          post.mediaUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(
            icon: Icons.favorite_border,
            label: 'J\'aime',
            onTap: () => service.likePost(post.id),
          ),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Commenter',
            onTap: () => _showCommentsSheet(),
          ),
          _ActionButton(
            icon: Icons.share_outlined,
            label: 'Partager',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (post.likesCount > 0)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likesCount}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          const Spacer(),
          if (post.commentsCount > 0)
            Text(
              '${post.commentsCount} commentaire${post.commentsCount > 1 ? 's' : ''}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
        ],
      ),
    );
  }

  void _showCommentsSheet() {
    // TODO: Implement comments bottom sheet
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    
    return DateFormat('d MMM').format(time);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}