import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/guest_service.dart';
import '../theme/app_colors.dart';
import '../services/gallery_post_service.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  bool _isSaving = false;
  XFile? _pickedFile;
  Uint8List? _pickedBytes;
  int? _guestNumber;
  String? _rsvpStatus;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    _nameController.text = auth.displayName;
    _loadGuestInfo();
  }

  Future<void> _loadGuestInfo() async {
    final auth = context.read<AuthService>();
    final guestId = auth.currentProfile?.guestId;
    if (guestId == null) return;

    try {
      final guestService = context.read<GuestService>();
      final guest = await guestService.getGuestById(guestId);
      if (mounted && guest != null) {
        setState(() {
          _guestNumber = guest.guestNumber;
          _rsvpStatus = guest.rsvpStatus;
        });
      }
    } catch (e) {
      // Silently fail - guest info is optional
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (result != null) {
      final bytes = await result.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pickedFile = result;
        _pickedBytes = bytes;
      });
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning, color: Colors.red, size: 48),
        title: const Text('Supprimer mon compte ?'),
        content: const Text(
          'Cette action est irréversible. Votre profil sera supprimé.\n\n'
          'Votre place d\'invité sera conservée si vous vous réinscrivez avec le même email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isSaving = true);
      final auth = context.read<AuthService>();
      final success = await auth.deleteAccount();
      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          Navigator.of(context).pushReplacementNamed('/');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(auth.errorMessage ?? 'Erreur lors de la suppression'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _save() async {
    final auth = context.read<AuthService>();
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom ne peut pas être vide')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? avatarUrl;

      if (_pickedFile != null) {
        final service = GalleryPostService();
        avatarUrl = await service.uploadFileAndGetUrl(_pickedFile!);
      }

      final success = await auth.updateProfile(
        displayName: name,
        avatarUrl: avatarUrl,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la sauvegarde')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final profile = auth.currentProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primaryContainer,
                    backgroundImage: _pickedBytes != null
                        ? MemoryImage(_pickedBytes!)
                        : (profile?.avatarUrl != null
                                ? NetworkImage(profile!.avatarUrl!)
                                : null)
                            as ImageProvider?,
                    child: (_pickedBytes == null && profile?.avatarUrl == null)
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _pickAvatar,
              child: const Text('Changer la photo'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Votre nom',
                hintText: 'Ex: Jean Dupont',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            if (profile?.role != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Rôle'),
                  trailing: Text(
                    profile!.role.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            if (profile?.guestId != null) ...[
              if (_guestNumber != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.tag),
                    title: const Text('Numéro d\'invité'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_guestNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      _rsvpStatus == 'confirmed' ? 'Placé pour le dîner' : 'En attente de confirmation',
                      style: TextStyle(
                        color: _rsvpStatus == 'confirmed' ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.mail_outline),
                  title: const Text('Invité'),
                  subtitle: Text('ID: ${profile!.guestId}'),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Enregistrer',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 48),
            // Danger zone
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Zone de danger',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSaving ? null : _confirmDeleteAccount,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  'Supprimer mon compte',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre compte sera supprimé. Votre place d\'invité sera conservée si vous vous réinscrivez avec le même email.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
