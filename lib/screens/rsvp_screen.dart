import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/wedding_data_source.dart';
import '../services/auth_service.dart';
import '../services/guest_service.dart';
import '../services/email_service.dart';
import '../models/guest.dart';
import '../widgets/auth_modal.dart';
import '../widgets/drawer_opener.dart';
import '../constants/drinks.dart';

class RSVPScreen extends StatefulWidget {
  const RSVPScreen({super.key});

  @override
  State<RSVPScreen> createState() => _RSVPScreenState();
}

class _RSVPScreenState extends State<RSVPScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dietaryController = TextEditingController();
  String? _selectedDrink;
  bool _attending = true;
  int _guestCount = 1;
  Guest? _currentGuest;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dietaryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGuestData();
    });
  }

  Future<void> _loadGuestData() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.isAuthenticated) {
      final guestService = Provider.of<GuestService>(context, listen: false);
      
      // Try to find current guest by email
      final guest = await guestService.getGuestByEmail(authService.currentUser!.email ?? '');
      
      if (guest != null) {
        setState(() {
          _currentGuest = guest;
          _attending = guest.rsvpStatus == 'confirmed';
          _guestCount = guest.numberOfGuests;
          _firstNameController.text = guest.fullName.split(' ').first;
          if (guest.fullName.split(' ').length > 1) {
            _lastNameController.text = guest.fullName.split(' ').skip(1).join(' ');
          }
          _dietaryController.text = guest.dietaryRestrictions ?? '';
          _selectedDrink = guest.preferredDrink;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Check authentication
    if (!authService.isAuthenticated) {
      // Show AuthModal for unauthenticated users
      showDialog(
        context: context,
        builder: (context) => AuthModal(
          action: 'rsvp',
          onAuthenticated: () {
            Navigator.pop(context);
            _submitForm();
          },
        ),
      );
      return;
    }

    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Show loading indicator
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final guestService = Provider.of<GuestService>(context, listen: false);

      // Get or create guest based on email
      final guestEmail = authService.currentUser!.email ?? '';
      final existingGuest = await guestService.getGuestByEmail(guestEmail);

      String guestId;
      if (existingGuest != null) {
        guestId = existingGuest.id;
      } else {
        // Create new guest if doesn't exist
        final fullName = '${_firstNameController.text} ${_lastNameController.text}';
        final success = await guestService.addGuest(
          email: guestEmail,
          fullName: fullName,
          dietaryRestrictions: _dietaryController.text.isEmpty ? null : _dietaryController.text,
          preferredDrink: _selectedDrink,
        );

        if (!success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(guestService.error ?? 'Erreur lors de la soumission'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }

        // Reload to get the new guest
        await guestService.refreshGuests();
        final newGuest = await guestService.getGuestByEmail(guestEmail);
        guestId = newGuest!.id;
      }

      // Update RSVP
      final success = await guestService.updateRSVP(
        guestId: guestId,
        attending: _attending,
        numberOfGuests: _guestCount,
        dietaryRestrictions: _dietaryController.text.isEmpty ? null : _dietaryController.text,
        preferredDrink: _selectedDrink,
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(guestService.error ?? 'Erreur lors de la soumission'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Merci pour votre réponse !'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Send confirmation email
        final emailService = Provider.of<EmailService>(context, listen: false);
        final guestEmail = authService.currentUser!.email ?? '';
        final guestName = '${_firstNameController.text} ${_lastNameController.text}';
        emailService.sendRsvpConfirmation(
          to: guestEmail,
          guestName: guestName,
          attending: _attending,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildForm(),
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
          'Réponse Souhaitée',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'NotoSerif',
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        if (_currentGuest != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Bonjour ${_currentGuest!.fullName} ! Merci de nous confirmer votre présence.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (_currentGuest == null)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Nous avons hâte de célébrer ce moment unique avec vous. Merci de nous confirmer votre présence avant le ${WeddingData.rsvpDeadline}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        const SizedBox(height: 24),
        Container(
          height: 300,
          width: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?w=400',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Le Grand Jour',
          style: TextStyle(
            fontFamily: 'NotoSerif',
            fontSize: 24,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${WeddingData.weddingDate.toUpperCase()} • ${WeddingData.city.split(',').first.toUpperCase()}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
            color: AppColors.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'Prénom',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre prénom';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'Nom',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Serez-vous présent ?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Oui, avec joie'),
                    value: true,
                    groupValue: _attending,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _attending = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Non, à regret'),
                    value: false,
                    groupValue: _attending,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _attending = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDropdownField(
              label: 'Nombre d\'invités (y compris vous)',
              value: _guestCount.toString(),
              items: ['1', '2', '3', '4'],
              onChanged: (value) {
                setState(() {
                  _guestCount = int.parse(value!);
                });
              },
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _dietaryController,
              label: 'Préférences alimentaires',
              maxLines: 2,
              hintText: 'Ex: végétarien, sans gluten, sans lactose...',
            ),
            const SizedBox(height: 24),
            _buildDrinkDropdown(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('CONFIRMER MA PRÉSENCE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDrinkDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BOISSON PRÉFÉRÉE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDrink,
          decoration: const InputDecoration(
            hintText: 'Choisissez votre boisson',
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          items: availableDrinks.map((drink) {
            return DropdownMenuItem(
              value: drink,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: getDrinkColor(drink),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(drink),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDrink = value;
            });
          },
        ),
      ],
    );
  }
}
