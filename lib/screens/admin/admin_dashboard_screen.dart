import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mariage_pasteur/services/auth_service.dart';
import 'package:mariage_pasteur/services/guest_service.dart';
import 'package:mariage_pasteur/widgets/wedding_app_bar.dart';
import 'package:mariage_pasteur/widgets/drink_pie_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final guestService = context.read<GuestService>();
      guestService.refreshGuests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final guestService = context.watch<GuestService>();
    final authService = context.watch<AuthService>();
    final stats = guestService.getRSVPStats();

    return Scaffold(
      appBar: const WeddingAppBar(title: 'Tableau de bord'),
      body: RefreshIndicator(
        onRefresh: () async {
          await guestService.refreshGuests();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    Text(
                      'Bienvenue, ${authService.isAdmin ? 'Admin' : 'Marié'}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    // Statistics cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Confirmés',
                            stats['confirmed'].toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Déclinés',
                            stats['declined'].toString(),
                            Icons.close,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'En attente',
                            stats['pending'].toString(),
                            Icons.schedule,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            stats['total_guests'].toString(),
                            Icons.people,
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Drink preferences chart
                    DrinkPieChart(drinkStats: guestService.getDrinkStats()),
                    const SizedBox(height: 32),
                    // Quick actions
                    const Text(
                      'Actions rapides',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Action buttons
                    _buildActionCard(
                      context,
                      'Gestion des invités',
                      Icons.people_alt,
                      Colors.blue,
                      () {
                        Navigator.of(context).pushNamed('/admin/guests');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      context,
                      'Modération photos',
                      Icons.photo_album,
                      Colors.purple,
                      () {
                        Navigator.of(context).pushNamed('/admin/photos');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: color,
        ),
        onTap: onTap,
      ),
    );
  }
}
