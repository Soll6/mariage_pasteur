import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wedding_data.dart';

class GalleryPostService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  List<GalleryPost> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<GalleryPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  GalleryPostService() {
    loadPosts();
  }

  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to load posts, but handle gracefully if table doesn't exist yet
      final response = await _client
          .from('gallery_posts')
          .select()
          .order('created_at', ascending: false)
          .catchError((e) {
            debugPrint('Erreur chargement posts: $e');
            // Return empty list if there's an error
            return [];
          });

      if (response is List) {
        _posts = response
            .map((json) => GalleryPost.fromMap(json))
            .toList();
      } else {
        _posts = [];
      }
      _error = null; // Clear any previous errors
    } catch (e) {
      debugPrint('Erreur chargement posts: $e');
      // Don't set error if it's the first load (table might not exist yet)
      // Just show empty state
      _posts = [];
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String content,
    required String mediaType,
    String? mediaUrl,
    String? thumbnailUrl,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        _error = 'Utilisateur non authentifié';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final userProfile = await _client
          .from('user_profiles')
          .select('guest_id, display_name, avatar_url')
          .eq('user_id', currentUser.id)
          .maybeSingle()
          .catchError((e) {
            debugPrint('Erreur récupération profil: $e');
            return null;
          });

      await _client.from('gallery_posts').insert({
        'user_id': currentUser.id,
        'guest_id': userProfile?['guest_id'],
        'content': content,
        'media_type': mediaType,
        'media_url': mediaUrl,
        'thumbnail_url': thumbnailUrl,
        'status': 'published',
      });

      await loadPosts();
      return true;
    } catch (e) {
      debugPrint('Erreur création post: $e');
      _error = 'Erreur lors de la création du post';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> uploadMedia(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (file == null) return;

      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return;

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final filePath = 'gallery/$fileName';

      await _client.storage
          .from('wedding-photos')
          .upload(filePath, File(file.path));

      final publicUrl = _client.storage
          .from('wedding-photos')
          .getPublicUrl(filePath);

      // Create a post with the uploaded image
      await createPost(
        content: '',
        mediaType: 'image',
        mediaUrl: publicUrl,
      );
    } catch (e) {
      debugPrint('Erreur upload media: $e');
      _error = 'Erreur lors de l\'upload du média';
    }
  }

  Future<void> likePost(String postId) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return;

      // Check if already liked
      final existingLike = await _client
          .from('post_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (existingLike == null) {
        // Add like
        await _client.from('post_likes').insert({
          'post_id': postId,
          'user_id': currentUser.id,
        });

        // Update likes count
        final post = await _client
            .from('gallery_posts')
            .select('likes_count')
            .eq('id', postId)
            .single();
        await _client
            .from('gallery_posts')
            .update({
              'likes_count': (post['likes_count'] ?? 0) + 1,
            })
            .eq('id', postId);

        await loadPosts();
      }
    } catch (e) {
      debugPrint('Erreur like: $e');
    }
  }

  Future<void> unlikePost(String postId) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return;

      await _client
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', currentUser.id);

      final post = await _client
          .from('gallery_posts')
          .select('likes_count')
          .eq('id', postId)
          .single();
      await _client
          .from('gallery_posts')
          .update({
            'likes_count': (post['likes_count'] ?? 1) - 1,
          })
          .eq('id', postId);

      await loadPosts();
    } catch (e) {
      debugPrint('Erreur unlike: $e');
    }
  }

  Future<bool> addComment(String postId, String comment) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return false;

      await _client.from('post_comments').insert({
        'post_id': postId,
        'user_id': currentUser.id,
        'comment': comment,
        'status': 'published',
      });

      // Update comments count
      final post = await _client
          .from('gallery_posts')
          .select('comments_count')
          .eq('id', postId)
          .single();
      await _client
          .from('gallery_posts')
          .update({
            'comments_count': (post['comments_count'] ?? 0) + 1,
          })
          .eq('id', postId);

      await loadPosts();
      return true;
    } catch (e) {
      debugPrint('Erreur commentaire: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}