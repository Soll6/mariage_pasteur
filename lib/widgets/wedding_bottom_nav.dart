import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../screens/home_screen.dart';
import '../screens/programme_screen.dart';
import '../screens/galerie_screen.dart';
import '../screens/carte_screen.dart';
import '../screens/rsvp_screen.dart';
import '../screens/profil_screen.dart';
import '../services/auth_service.dart';
import 'drawer_opener.dart';

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _labels = [
    'Accueil',
    'Programme',
    'Galerie',
    'Carte',
    'RSVP',
  ];
  static const _icons = [
    Icons.home_outlined,
    Icons.event_note_outlined,
    Icons.photo_library_outlined,
    Icons.map_outlined,
    Icons.mail_lock_outlined,
  ];

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
    final auth = context.watch<AuthService>();

    return DrawerOpener(
      openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(auth),
        body: _screens[_currentIndex],
      ),
    );
  }

  Widget _buildDrawer(AuthService auth) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                auth.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                auth.currentUser?.email ?? '',
                style: const TextStyle(fontSize: 13),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                backgroundImage: auth.currentProfile?.avatarUrl != null
                    ? NetworkImage(auth.currentProfile!.avatarUrl!)
                    : null,
                child: auth.currentProfile?.avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 32,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
            ),
            ...List.generate(_screens.length, (index) {
              return ListTile(
                leading: Icon(
                  _icons[index],
                  color: _currentIndex == index
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                ),
                title: Text(
                  _labels[index],
                  style: TextStyle(
                    fontWeight: _currentIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _currentIndex == index
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                  ),
                ),
                selected: _currentIndex == index,
                selectedTileColor: AppColors.primary.withOpacity(0.08),
                onTap: () {
                  Navigator.of(context).pop();
                  switchToTab(index);
                },
              );
            }),
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Mon Profil'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilScreen()),
                );
              },
            ),
            const Spacer(),
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Voulez-vous vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text(
                          'Déconnexion',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/');
                  }
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
