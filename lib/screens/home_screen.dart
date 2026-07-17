import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/wedding_data_source.dart';
import '../widgets/ceremony_card.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/drawer_opener.dart';
import '../widgets/wedding_bottom_nav.dart';
import '../services/auth_service.dart';
import '../widgets/auth_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late ScrollController _scrollController;
  double _scrollOffset = 0;

  // Staggered entry animations
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _nameFade;
  late Animation<double> _nameScale;
  late Animation<double> _dividerWidth;
  late Animation<double> _ctaFade;
  late Animation<Offset> _ctaSlide;
  late Animation<double> _shimmer;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)),
    );
    _nameFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.35, 0.65, curve: Curves.easeOut)),
    );
    _nameScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.35, 0.7, curve: Curves.easeOutBack)),
    );
    _dividerWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.55, 0.75, curve: Curves.easeOut)),
    );
    _ctaFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.65, 0.9, curve: Curves.easeOut)),
    );
    _ctaSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _masterController, curve: const Interval(0.65, 0.95, curve: Curves.easeOutCubic)),
    );
    _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _masterController.forward();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
  }

  void _navigateToTab(int index) {
    final navState = context.findAncestorStateOfType<WeddingBottomNavState>();
    navState?.switchToTab(index);
  }

  @override
  void dispose() {
    _masterController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAnimatedAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeroSection(context),
                _buildCountdownSection(),
                _buildCeremoniesSection(context),
                _buildRSVPSection(context),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return AnimatedBuilder(
      animation: _masterController,
      builder: (_, __) {
        return SliverAppBar(
          backgroundColor: AppColors.surfaceBright.withOpacity(0.92 * _heroFade.value),
          elevation: 0,
          pinned: true,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: FadeTransition(
              opacity: _heroFade,
              child: IconButton(
                icon: Icon(Icons.menu, color: AppColors.primary),
                onPressed: () => DrawerOpener.of(context)?.openDrawer(),
              ),
            ),
          ),
          title: FadeTransition(
            opacity: _nameFade,
            child: ScaleTransition(
              scale: _nameScale,
              child: ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  colors: const [Color(0xFFB8860B), Color(0xFFDAA520), Color(0xFFFFD700), Color(0xFFDAA520)],
                  stops: [0, _shimmer.value.clamp(0.0, 0.4), _shimmer.value.clamp(0.4, 0.7), 1],
                ).createShader(b),
                child: const Text(
                  'Sonia & Aimé',
                  style: TextStyle(
                    fontFamily: 'NotoSerif',
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: FadeTransition(
                opacity: _ctaFade,
                child: Consumer<AuthService>(
                  builder: (context, authService, child) {
                    return PopupMenuButton<String>(
                      onSelected: (value) => _handleProfileAction(context, value, authService),
                      icon: Icon(
                        authService.isAuthenticated 
                          ? Icons.account_circle 
                          : Icons.account_circle_outlined,
                        color: AppColors.primary,
                      ),
                      itemBuilder: (context) {
                        if (authService.isAuthenticated) {
                          return [
                            PopupMenuItem(
                              value: 'profile',
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 20),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        authService.currentUser?.email ?? '',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        authService.userRole == 'couple' 
                                          ? 'Couple'
                                          : authService.userRole == 'admin'
                                          ? 'Admin'
                                          : 'Invité',
                                        style: const TextStyle(fontSize: 10, color: AppColors.outline),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout, size: 20),
                                  SizedBox(width: 12),
                                  Text('Se déconnecter'),
                                ],
                              ),
                            ),
                          ];
                        } else {
                          return [
                            const PopupMenuItem(
                              value: 'login',
                              child: Row(
                                children: [
                                  Icon(Icons.login, size: 20),
                                  SizedBox(width: 12),
                                  Text('Se connecter'),
                                ],
                              ),
                            ),
                          ];
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleProfileAction(BuildContext context, String action, AuthService authService) {
    switch (action) {
      case 'login':
        showDialog(
          context: context,
          builder: (context) => AuthModal(
            action: 'general',
            onAuthenticated: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Connexion réussie !'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        );
        break;
      case 'logout':
        _showLogoutConfirmation(context, authService);
        break;
      case 'profile':
        // Optionally navigate to a profile screen
        break;
    }
  }

  void _showLogoutConfirmation(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Déconnexion réussie'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final heroHeight = isMobile ? 652.0 : 580.0;
    final nameFontSize = isMobile ? 32.0 : 42.0;

    return AnimatedBuilder(
      animation: _masterController,
      builder: (_, __) {
        return FadeTransition(
          opacity: _heroFade,
          child: SlideTransition(
            position: _heroSlide,
            child: Stack(
              children: [
                // Photo bg with Parallax
                Container(
                  height: heroHeight,
                  width: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: Transform.translate(
                    offset: Offset(0, _scrollOffset * 0.4),
                    child: Image.asset(
                      'assets/images/couple_photo.jpg',
                      fit: BoxFit.cover,
                      height: heroHeight,
                    ),
                  ),
                ),
                // Particle overlay
                SizedBox(
                  height: heroHeight,
                  child: AnimatedBuilder(
                    animation: _particleController,
                    builder: (_, __) => CustomPaint(
                      painter: _ParticlePainter(_particleController.value),
                      size: Size(double.infinity, heroHeight),
                    ),
                  ),
                ),
                // Gradient overlay - brume sur toute la photo
                Container(
                  height: heroHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.4),
                        AppColors.surface.withOpacity(0.7),
                        AppColors.surface,
                      ],
                      stops: const [0, 0.2, 0.45, 0.65, 0.85, 1],
                    ),
                  ),
                ),
                // Content
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Names with shimmer
                        FadeTransition(
                          opacity: _nameFade,
                          child: ScaleTransition(
                            scale: _nameScale,
                            child: ShaderMask(
                              shaderCallback: (b) => LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: const [
                                  Color(0xFF914630),
                                  Color(0xFFDAA520),
                                  Color(0xFFFFD700),
                                  Color(0xFFDAA520),
                                  Color(0xFF914630),
                                ],
                                stops: [
                                  0,
                                  (_shimmer.value - 0.5).clamp(0.0, 1.0),
                                  _shimmer.value.clamp(0.0, 1.0),
                                  (_shimmer.value + 0.5).clamp(0.0, 1.0),
                                  1,
                                ],
                              ).createShader(b),
                              child: Text(
                                WeddingData.coupleName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'NotoSerif',
                                  fontSize: nameFontSize,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Animated divider
                        AnimatedBuilder(
                          animation: _dividerWidth,
                          builder: (_, __) => Center(
                            child: Container(
                              width: 200 * _dividerWidth.value,
                              height: 1.5,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFFDAA520),
                                    Color(0xFFFFD700),
                                    Color(0xFFDAA520),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subtitle
                        FadeTransition(
                          opacity: _ctaFade,
                          child: SlideTransition(
                            position: _ctaSlide,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Vous invitent à leur mariage religieux, coutumier et civil à Libreville.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // CTA Button
                        FadeTransition(
                          opacity: _ctaFade,
                          child: SlideTransition(
                            position: _ctaSlide,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (_, child) => Transform.scale(
                                scale: _pulse.value,
                                child: child,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF914630), Color(0xFFAF5E46)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF914630).withOpacity(0.45),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _navigateToTab(4),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                  ),
                                  child: const Text(
                                    'RÉSERVER MA PLACE',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountdownSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final dateFontSize = isMobile ? 24.0 : 32.0;

    return AnimatedBuilder(
      animation: _masterController,
      builder: (_, child) => FadeTransition(opacity: _ctaFade, child: child),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF3EC), Color(0xFFF5E6DB)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFDAA520).withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF914630).withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFFB8860B), Color(0xFFDAA520), Color(0xFFB8860B)],
                    ).createShader(b),
                    child: Text(
                      WeddingData.weddingDate,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'NotoSerif',
                        fontSize: dateFontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    WeddingData.city.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CountdownTimer(targetDate: WeddingData.targetDate),
          ],
        ),
      ),
    );
  }

  Widget _buildCeremoniesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          _buildSectionHeader('Les Célébrations', 'Trois moments uniques pour sceller notre union, entourés de nos familles et amis les plus chers.'),
          const SizedBox(height: 32),
          ...WeddingData.ceremonies.map((ceremony) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CeremonyCard(
              ceremony: ceremony,
              headerColor: AppColors.secondaryFixed,
              iconData: _getIconForCeremony(ceremony.icon),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'NotoSerif',
            fontSize: 28,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 80,
          height: 1.5,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Color(0xFFDAA520), Color(0xFFFFD700), Color(0xFFDAA520), Colors.transparent],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForCeremony(String icon) {
    switch (icon) {
      case 'church': return Icons.church_outlined;
      case 'groups': return Icons.groups_outlined;
      case 'gavel': return Icons.gavel_outlined;
      default: return Icons.celebration_outlined;
    }
  }

  Widget _buildRSVPSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF3EC), Color(0xFFF5E6DB)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFDAA520).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF914630).withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF914630), Color(0xFFAF5E46)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF914630).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.mail_lock_outlined, size: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              'Confirmez votre présence',
              'Nous avons hâte de célébrer ce nouveau chapitre avec vous.\nMerci de confirmer avant le ${WeddingData.rsvpDeadline}.',
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF914630), Color(0xFFAF5E46)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF914630).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _navigateToTab(4),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    child: const Text('RSVP EN LIGNE', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _navigateToTab(3),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text('INFOS PRATIQUES', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfaceVariant.withOpacity(0.2), AppColors.surfaceContainer],
        ),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFB8860B), Color(0xFFDAA520), Color(0xFFB8860B)],
            ).createShader(b),
            child: const Text(
              'Sonia & Aimé Francis',
              style: TextStyle(
                fontFamily: 'NotoSerif',
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '© 2026 · Fait avec amour à Libreville',
            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.outline),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Mentions Légales', style: TextStyle(fontSize: 11, color: AppColors.outline)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/admin/login');
                },
                child: const Text('Admin', style: TextStyle(fontSize: 11, color: AppColors.outline)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/couple/login');
                },
                child: const Text('Couple', style: TextStyle(fontSize: 11, color: AppColors.outline)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Floating petals / particles ───────────────────────────────────────────────
class _Particle {
  final double x, startY, size, speed, phase, opacity;
  const _Particle(this.x, this.startY, this.size, this.speed, this.phase, this.opacity);
}

class _ParticlePainter extends CustomPainter {
  final double t;
  static final List<_Particle> _particles = List.generate(22, (i) {
    final r = Random(i * 7 + 3);
    return _Particle(
      r.nextDouble(),
      r.nextDouble(),
      r.nextDouble() * 6 + 3,
      r.nextDouble() * 0.4 + 0.15,
      r.nextDouble() * pi * 2,
      r.nextDouble() * 0.25 + 0.08,
    );
  });

  _ParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final y = (p.startY - p.speed * t) % 1.0;
      final x = p.x + sin(t * pi * 2 * p.speed + p.phase) * 0.04;
      final paint = Paint()
        ..color = const Color(0xFFDAA520).withOpacity(p.opacity * (0.5 + 0.5 * sin(t * pi * 2 + p.phase)))
        ..style = PaintingStyle.fill;
      // Draw small petal shape
      final cx = x.clamp(0.0, 1.0) * size.width;
      final cy = y * size.height;
      final path = Path()
        ..moveTo(cx, cy - p.size)
        ..quadraticBezierTo(cx + p.size * 0.7, cy, cx, cy + p.size)
        ..quadraticBezierTo(cx - p.size * 0.7, cy, cx, cy - p.size);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}
