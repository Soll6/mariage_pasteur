import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mariage_pasteur/services/guest_service.dart';
import 'package:mariage_pasteur/models/guest.dart';
import 'package:mariage_pasteur/widgets/wedding_app_bar.dart';

class GuestManagementScreen extends StatefulWidget {
  const GuestManagementScreen({super.key});

  @override
  State<GuestManagementScreen> createState() =>
      _GuestManagementScreenState();
}

class _GuestManagementScreenState extends State<GuestManagementScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  late GuestService _guestService;

  final List<String> _filterOptions = [
    'all',
    'confirmed',
    'declined',
    'pending',
  ];

  @override
  void initState() {
    super.initState();
    _guestService = context.read<GuestService>();
  }

  List<Guest> _getFilteredGuests() {
    List<Guest> guests = _guestService.guests;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      guests = guests.where((guest) {
        return guest.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            guest.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'all') {
      guests = guests.where((guest) => guest.rsvpStatus == _selectedFilter).toList();
    }

    return guests;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WeddingAppBar(title: 'Gestion des invités', showBackButton: true),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _filterOptions.map((status) {
                final isSelected = _selectedFilter == status;
                return FilterChip(
                  label: Text(status.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? status : 'all';
                    });
                  },
                );
              }).toList(),
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un invité...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Add guest button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddGuestDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un invité'),
              ),
            ),
          ),
          // Guest list
          Expanded(
            child: Consumer<GuestService>(
              builder: (context, guestService, child) {
                if (guestService.isLoading && guestService.guests.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final guests = _getFilteredGuests();

                if (guests.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun invité trouvé',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: guests.length,
                  itemBuilder: (context, index) {
                    final guest = guests[index];
                    return _GuestListItem(guest: guest);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGuestDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController dietaryController = TextEditingController();
    final TextEditingController allergiesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un invité'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom complet'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: dietaryController,
                decoration: const InputDecoration(labelText: 'Restrictions alimentaires'),
              ),
              TextField(
                controller: allergiesController,
                decoration: const InputDecoration(labelText: 'Allergies'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();

              if (name.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le nom et l\'email sont requis'),
                  ),
                );
                return;
              }

              final success = await _guestService.addGuest(
                email: email,
                fullName: name,
                dietaryRestrictions: dietaryController.text.isEmpty ? null : dietaryController.text,
                allergies: allergiesController.text.isEmpty ? null : allergiesController.text,
              );

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invité ajouté avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_guestService.error ?? 'Erreur inconnue'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class _GuestListItem extends StatelessWidget {
  final Guest guest;

  const _GuestListItem({required this.guest});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (guest.rsvpStatus) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'declined':
        statusColor = Colors.red;
        statusIcon = Icons.close;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(guest.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(guest.email),
            Text(
              '${guest.numberOfGuests} invité(s) • ${guest.rsvpStatus.toUpperCase()}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirm(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final guestService = context.read<GuestService>();
    final TextEditingController nameController = TextEditingController(text: guest.fullName);
    final TextEditingController dietaryController = TextEditingController(text: guest.dietaryRestrictions ?? '');
    final TextEditingController allergiesController = TextEditingController(text: guest.allergies ?? '');
    String currentStatus = guest.rsvpStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'invité'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom complet'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: currentStatus,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: ['pending', 'confirmed', 'declined'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  currentStatus = value!;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dietaryController,
                decoration: const InputDecoration(labelText: 'Restrictions alimentaires'),
              ),
              TextField(
                controller: allergiesController,
                decoration: const InputDecoration(labelText: 'Allergies'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final dietary = dietaryController.text.isEmpty ? null : dietaryController.text;
              final allergies = allergiesController.text.isEmpty ? null : allergiesController.text;

              final success = await guestService.updateRSVP(
                guestId: guest.id,
                attending: currentStatus == 'confirmed',
                dietaryRestrictions: dietary,
                allergies: allergies,
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invité mis à jour avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(guestService.error ?? 'Erreur inconnue'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Voulez-vous vraiment supprimer ${guest.fullName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<GuestService>().deleteGuest(guest.id);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invité supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.read<GuestService>().error ?? 'Erreur inconnue'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
