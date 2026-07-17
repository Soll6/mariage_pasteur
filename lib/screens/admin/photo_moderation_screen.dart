import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mariage_pasteur/services/admin_service.dart';
import 'package:mariage_pasteur/widgets/wedding_app_bar.dart';

class PhotoModerationScreen extends StatefulWidget {
  const PhotoModerationScreen({super.key});

  @override
  State<PhotoModerationScreen> createState() => _PhotoModerationScreenState();
}

class _PhotoModerationScreenState extends State<PhotoModerationScreen> {
  List<dynamic> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final adminService = context.read<AdminService>();

      await adminService.getGalleryStats();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WeddingAppBar(title: 'Modération photos', showBackButton: true),
      body: Column(
        children: [
          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<AdminService>(
              builder: (context, adminService, child) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = adminService.getGalleryStats();

                return FutureBuilder<Map<String, dynamic>>(
                  future: stats,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }

                    final data = snapshot.data!;

                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'En attente',
                            data['pending'].toString(),
                            Icons.pending,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Approuvées',
                            data['approved'].toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Rejetées',
                            data['rejected'].toString(),
                            Icons.close,
                            Colors.red,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          // Photo grid
          Expanded(
            child: Consumer<AdminService>(
              builder: (context, adminService, child) {
                return FutureBuilder<Map<String, dynamic>>(
                  future: adminService.getGalleryStats(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(snapshot.error.toString()),
                        ),
                      );
                    }

                    final data = snapshot.data!;
                    if (data['pending'] == 0) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Toutes les photos sont approuvées',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _photos.length,
                      itemBuilder: (context, index) {
                        final photo = _photos[index];
                        return _PhotoCard(
                          photo: photo,
                          onApprove: () async {
                            await adminService.moderatePhoto(
                              photoId: photo['id'] as String,
                              status: 'approved',
                            );
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          onReject: () async {
                            await adminService.moderatePhoto(
                              photoId: photo['id'] as String,
                              status: 'rejected',
                            );
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final dynamic photo;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PhotoCard({
    required this.photo,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Photo preview
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              photo['photo_url'] as String,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey,
                  child: const Center(
                    child: Icon(Icons.broken_image),
                  ),
                );
              },
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text('Rejeter', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Approuver', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
