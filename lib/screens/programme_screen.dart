import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/wedding_data_source.dart';
import '../widgets/drawer_opener.dart';
import '../widgets/wedding_bottom_nav.dart';

class ProgrammeScreen extends StatelessWidget {
  const ProgrammeScreen({super.key});

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
                  ...WeddingData.timeline.asMap().entries.map(
                        (entry) => _TimelineEventCard(
                          event: entry.value,
                          isReversed: entry.key.isOdd,
                        ),
                      ),
                  const SizedBox(height: 40),
                  _buildCTASection(context),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Notre Union',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Programme du Grand Jour',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'NotoSerif',
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Célébrons ensemble l\'amour, la tradition et notre engagement éternel sous le soleil de Libreville.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              WeddingData.weddingDate,
              style: TextStyle(
                fontFamily: 'NotoSerif',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Nous avons hâte de vous voir',
            style: TextStyle(
              fontFamily: 'NotoSerif',
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Votre présence à nos côtés pour ces différentes étapes est le plus beau des cadeaux. Merci de confirmer votre venue avant le ${WeddingData.rsvpDeadline}.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WeddingBottomNav(currentIndex: 4),
                  ),
                ),
                child: const Text('RÉPONDRE À L\'INVITATION'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WeddingBottomNav(currentIndex: 3),
                  ),
                ),
                child: const Text('DÉTAILS PRATIQUES'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineEventCard extends StatelessWidget {
  final dynamic event;
  final bool isReversed;

  const _TimelineEventCard({
    required this.event,
    required this.isReversed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAsset = event.imageUrl.startsWith('assets/');

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: isAsset
                  ? DecorationImage(
                      image: AssetImage(event.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: NetworkImage(event.imageUrl),
                      fit: BoxFit.cover,
                    ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${event.time} — ${event.location}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'NotoSerif',
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _getIconForEvent(event.icon),
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  event.location,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'NotoSerif',
                    fontSize: 14,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForEvent(String icon) {
    switch (icon) {
      case 'gavel':
        return Icons.gavel_outlined;
      case 'groups':
        return Icons.groups_outlined;
      case 'church':
        return Icons.church_outlined;
      default:
        return Icons.celebration_outlined;
    }
  }
}
