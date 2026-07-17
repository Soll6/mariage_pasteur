import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/gallery_post_service.dart';
import '../widgets/gallery_post_card.dart';
import '../widgets/create_post_sheet.dart';
import '../widgets/drawer_opener.dart';

class GalerieScreen extends StatelessWidget {
  const GalerieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GalleryPostService(),
      child: const _GalerieScreenContent(),
    );
  }
}

class _GalerieScreenContent extends StatelessWidget {
  const _GalerieScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.surfaceBright.withOpacity(0.8),
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.menu, color: AppColors.primary),
              onPressed: () => DrawerOpener.of(context)?.openDrawer(),
            ),
            title: const Text(
              'Sonia & Aimé',
              style: TextStyle(
                fontFamily: 'NotoSerif',
                fontSize: 24,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.favorite, color: AppColors.primary),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeader(context),
                _buildCreatePostButton(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _buildPostsList(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Fil d\'actualités',
            style: TextStyle(
              fontFamily: 'NotoSerif',
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Partagez vos moments précieux avec les mariés et les invités',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _showCreatePostSheet(context),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                'Qu\'avez-vous en tête ?',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Icon(Icons.photo_library_outlined, color: Colors.green[600]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return Consumer<GalleryPostService>(
      builder: (context, service, child) {
        if (service.isLoading && service.posts.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Only show error if there's actually an error
        if (service.error != null && service.posts.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    service.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      service.clearError();
                      // Reload posts
                      service.loadPosts();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        if (service.posts.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune publication pour le moment',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Soyez le premier à partager !',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = service.posts[index];
              return GalleryPostCard(
                post: post,
                service: service,
              );
            },
            childCount: service.posts.length,
          ),
        );
      },
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    final service = context.read<GalleryPostService>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: CreatePostSheet(
          onSubmit: (content, mediaType, mediaUrl) async {
            return await service.createPost(
              content: content,
              mediaType: mediaType,
              mediaUrl: mediaUrl,
            );
          },
          onUploadMedia: (file) => service.uploadFileAndGetUrl(file),
        ),
      ),
    );
  }
}