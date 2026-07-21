import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../models/wedding_data_source.dart';
import '../widgets/drawer_opener.dart';

class CarteScreen extends StatelessWidget {
  const CarteScreen({super.key});

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildMapSection(),
                  const SizedBox(height: 24),
                  _buildLocationCards(context),
                  const SizedBox(height: 32),
                  _buildPracticalInfo(),
                  const SizedBox(height: 32),
                  _buildPhotosSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Localisation',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Le Chemin vers Nous',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'NotoSerif',
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Nous avons hâte de vous retrouver à Libreville pour célébrer notre union. Voici tous les détails pour faciliter votre venue.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(0.4630312692460624, 9.436918339513689),
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.mariage.pasteur',
            ),
            MarkerLayer(
              markers: WeddingData.ceremonies
                  .map(
                    (ceremony) => Marker(
                      point: LatLng(ceremony.latitude, ceremony.longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCards(BuildContext context) {
    return Column(
      children: WeddingData.ceremonies.map((ceremony) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    _getIconForCeremony(ceremony.icon),
                    color: AppColors.primary,
                    size: 32,
                  ),
                  Text(
                    ceremony.time,
                    style: const TextStyle(
                      fontFamily: 'NotoSerif',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ceremony.title,
                style: const TextStyle(
                  fontFamily: 'NotoSerif',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ceremony.location,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _openGoogleMaps(ceremony.latitude, ceremony.longitude),
                icon: const Text(
                  'OBTENIR L\'ITINÉRAIRE',
                  style: TextStyle(fontSize: 12),
                ),
                label: const Icon(Icons.arrow_forward, size: 16),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForCeremony(String icon) {
    switch (icon) {
      case 'church':
        return Icons.church_outlined;
      case 'gavel':
        return Icons.gavel_outlined;
      case 'groups':
        return Icons.groups_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      default:
        return Icons.celebration_outlined;
    }
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildPracticalInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.tertiaryFixed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations Pratiques',
            style: TextStyle(
              fontFamily: 'NotoSerif',
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppColors.onTertiaryFixed,
            ),
          ),
          const SizedBox(height: 20),
          ...WeddingData.practicalInfo.map((info) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _getIconFromString(info['icon'] as String),
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info['title'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                            color: AppColors.onTertiaryFixedVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          info['description'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.onTertiaryFixed,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const Divider(color: AppColors.onTertiaryFixedVariant, height: 32),
          const Text(
            '"Chaque kilomètre parcouru est un cadeau pour nous."',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: AppColors.onTertiaryFixedVariant,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sonia & Aimé',
            style: TextStyle(
              fontFamily: 'NotoSerif',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconFromString(String icon) {
    switch (icon) {
      case 'local_parking':
        return Icons.local_parking_outlined;
      case 'local_taxi':
        return Icons.local_taxi_outlined;
      case 'hotel':
        return Icons.hotel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildPhotosSection() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildPhotoCard(
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
          'Le bord de mer',
        ),
        _buildPhotoCard(
          'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=400',
          'Ambiance Tropicale',
        ),
        _buildPhotoCard(
          'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400',
          'L\'élégance du soir',
        ),
      ],
    );
  }

  Widget _buildPhotoCard(String imageUrl, String caption) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Text(
                caption,
                style: const TextStyle(
                  fontFamily: 'NotoSerif',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
