import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';

class CreatePostSheet extends StatefulWidget {
  final Future<bool> Function(String content, String mediaType, String? mediaUrl) onSubmit;
  final Future<String?> Function(XFile file)? onUploadMedia;

  const CreatePostSheet({
    super.key,
    required this.onSubmit,
    this.onUploadMedia,
  });

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  XFile? _selectedFile;
  String _mediaType = 'text';
  Uint8List? _selectedFileBytes;

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

          // Media preview
          if (_selectedFile != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _mediaType == 'image' && _selectedFileBytes != null
                        ? Image.memory(
                            _selectedFileBytes!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.videocam, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Vidéo sélectionnée', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedFile = null;
                        _mediaType = 'text';
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_selectedFile != null) const SizedBox(height: 12),
          
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
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedFile = image;
          _selectedFileBytes = bytes;
          _mediaType = 'image';
        });
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
        setState(() {
          _selectedFile = video;
          _selectedFileBytes = null;
          _mediaType = 'video';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _submitPost() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un message ou sélectionner un média')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? mediaUrl;
      String mediaType = _selectedFile != null ? _mediaType : 'text';

      if (_selectedFile != null && widget.onUploadMedia != null) {
        mediaUrl = await widget.onUploadMedia!(_selectedFile!).timeout(
          const Duration(seconds: 30),
          onTimeout: () => null,
        );
        if (mediaUrl == null) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Échec de l\'upload. Vérifiez votre connexion.')),
            );
          }
          return;
        }
      }
      
      final success = await widget.onSubmit(text, mediaType, mediaUrl);

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la publication')),
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur submit: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
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