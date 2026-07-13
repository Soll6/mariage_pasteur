import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wedding_data.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

class GalleryService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  List<GalleryPhoto> _photos = [];
  bool _isLoading = false;
  String? _error;

  List<GalleryPhoto> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  GalleryService() {
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('gallery_photos')
          .select()
          .order('created_at', ascending: false);

      _photos = (response as List).map((json) => GalleryPhoto(
        photoUrl: json['photo_url'] as String,
        caption: json['caption'] as String? ?? '',
      )).toList();
    } catch (e) {
      debugPrint('Erreur chargement photos: $e');
      _error = 'Erreur lors du chargement des photos';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickAndUploadPhoto(ImageSource source, BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      _showAuthModal(context);
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      _isLoading = true;
      _error = null;
      notifyListeners();

      final file = File(image.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final filePath = 'gallery/$fileName';

      await _client.storage
          .from('wedding-photos')
          .upload(filePath, file);

      final publicUrl = _client.storage
          .from('wedding-photos')
          .getPublicUrl(filePath);

      final userProfile = await _client
          .from('user_profiles')
          .select('guest_id')
          .eq('user_id', authService.currentUser!.id)
          .maybeSingle();

      await _client.from('gallery_photos').insert({
        'photo_url': publicUrl,
        'caption': '',
        'guest_id': userProfile?['guest_id'],
        'status': 'pending',
      });

      await _loadPhotos();
    } catch (e) {
      debugPrint('Erreur ajout photo: $e');
      _error = 'Erreur lors de l\'ajout de la photo';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showAuthModal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AuthModalPage(action: 'upload'),
      ),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class _AuthModalPage extends StatelessWidget {
  final String action;

  const _AuthModalPage({required this.action});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentification')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Veuillez vous identifier pour $action',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Recevoir un lien de connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
