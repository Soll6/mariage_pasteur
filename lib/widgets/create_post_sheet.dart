import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';

class CreatePostSheet extends StatefulWidget {
  final Function(String content, String mediaType, String? mediaUrl) onSubmit;

  const CreatePostSheet({
    super.key,
    required this.onSubmit,
  });

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Nouvelle publication',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _isLoading ? null : _submitPost,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Publier'),
                ),
              ],
            ),
          ),
          
          // Text input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Partagez un moment...',
                border: InputBorder.none,
              ),
              autofocus: true,
            ),
          ),
          
          // Media options
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                _MediaOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Photo',
                  onTap: () => _pickMedia(ImageSource.gallery),
                ),
                const SizedBox(width: 24),
                _MediaOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Caméra',
                  onTap: () => _pickMedia(ImageSource.camera),
                ),
                const SizedBox(width: 24),
                _MediaOption(
                  icon: Icons.videocam_outlined,
                  label: 'Vidéo',
                  onTap: () => _pickVideo(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        // TODO: Upload and get URL
        // For now, just show success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo sélectionnée')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
      
      if (video != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vidéo sélectionnée')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _submitPost() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un message')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    widget.onSubmit(
      _textController.text.trim(),
      'text',
      null,
    );

    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }
}

class _MediaOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MediaOption({
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
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
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