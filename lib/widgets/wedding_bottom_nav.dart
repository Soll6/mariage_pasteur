import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/home_screen.dart';
import '../screens/programme_screen.dart';
import '../screens/galerie_screen.dart';
import '../screens/carte_screen.dart';
import '../screens/rsvp_screen.dart';

class WeddingBottomNav extends StatefulWidget {
  final int currentIndex;

  const WeddingBottomNav({
    super.key,
    this.currentIndex = 0,
  });

  @override
  State<WeddingBottomNav> createState() => WeddingBottomNavState();
}

class WeddingBottomNavState extends State<WeddingBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProgrammeScreen(),
    GalerieScreen(),
    CarteScreen(),
    RSVPScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceBright.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  label: 'Accueil',
                  isSelected: _currentIndex == 0,
                  onTap: () => _onItemTapped(0),
                ),
                _NavItem(
                  icon: Icons.event_note_outlined,
                  label: 'Programme',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onItemTapped(1),
                ),
                _NavItem(
                  icon: Icons.photo_library_outlined,
                  label: 'Galerie',
                  isSelected: _currentIndex == 2,
                  onTap: () => _onItemTapped(2),
                ),
                _NavItem(
                  icon: Icons.map_outlined,
                  label: 'Carte',
                  isSelected: _currentIndex == 3,
                  onTap: () => _onItemTapped(3),
                ),
                _NavItem(
                  icon: Icons.mail_lock_outlined,
                  label: 'RSVP',
                  isSelected: _currentIndex == 4,
                  onTap: () => _onItemTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    switchToTab(index);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
