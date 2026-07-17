import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/guest.dart';

class GuestService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  List<Guest> _guests = [];
  Guest? _currentGuest;
  bool _isLoading = false;
  String? _error;

  List<Guest> get guests => _guests;
  Guest? get currentGuest => _currentGuest;
  bool get isLoading => _isLoading;
  String? get error => _error;

  GuestService() {
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client
          .from('guests')
          .select()
          .order('full_name', ascending: true);

      _guests = (response as List)
          .map((json) => Guest.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading guests: $e');
      }
      _error = 'Erreur lors du chargement des invités';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reload guests from database
  Future<void> refreshGuests() => _loadGuests();

  /// Get guest by email
  Future<Guest?> getGuestByEmail(String email) async {
    try {
      final response = await _client
          .from('guests')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) return null;

      return Guest.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting guest by email: $e');
      }
      return null;
    }
  }

  /// Update RSVP status
  Future<bool> updateRSVP({
    required String guestId,
    required bool attending,
    int numberOfGuests = 1,
    String? dietaryRestrictions,
    String? allergies,
  }) async {
    try {
      await _client.from('guests').update({
        'rsvp_status': attending ? 'confirmed' : 'declined',
        'number_of_guests': numberOfGuests,
        'dietary_restrictions': dietaryRestrictions,
        'allergies': allergies,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', guestId);

      // Refresh guests list
      await _loadGuests();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating RSVP: $e');
      }
      _error = 'Erreur lors de la mise à jour du RSVP';
      notifyListeners();
      return false;
    }
  }

  /// Get RSVP statistics
  Map<String, int> getRSVPStats() {
    int confirmed = 0, declined = 0, pending = 0, totalGuests = 0;

    for (final guest in _guests) {
      switch (guest.rsvpStatus) {
        case 'confirmed':
          confirmed++;
          totalGuests += guest.numberOfGuests;
          break;
        case 'declined':
          declined++;
          break;
        case 'pending':
          pending++;
          break;
      }
    }

    return {
      'confirmed': confirmed,
      'declined': declined,
      'pending': pending,
      'total_guests': totalGuests,
    };
  }

  /// Add new guest (admin/couple only)
  Future<bool> addGuest({
    required String email,
    required String fullName,
    String? dietaryRestrictions,
    String? allergies,
  }) async {
    try {
      await _client.from('guests').insert({
        'email': email,
        'full_name': fullName,
        'rsvp_status': 'pending',
        'number_of_guests': 1,
        'dietary_restrictions': dietaryRestrictions,
        'allergies': allergies,
      });

      // Refresh guests list
      await _loadGuests();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding guest: $e');
      }
      _error = 'Erreur lors de l\'ajout de l\'invité';
      notifyListeners();
      return false;
    }
  }

  /// Self-register as guest (when user signs up via social auth or email)
  Future<bool> selfRegister({
    required String email,
    required String fullName,
  }) async {
    try {
      // Check if guest already exists
      final existingGuest = await getGuestByEmail(email);
      if (existingGuest != null) {
        // Guest already exists, just update if needed
        if (kDebugMode) {
          print('Guest already exists: $email');
        }
        return true;
      }

      // Create new guest with pending status
      await _client.from('guests').insert({
        'email': email,
        'full_name': fullName,
        'rsvp_status': 'pending',
        'number_of_guests': 1,
      });

      // Refresh guests list
      await _loadGuests();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error self-registering guest: $e');
      }
      _error = 'Erreur lors de l\'inscription';
      notifyListeners();
      return false;
    }
  }

  /// Link guest to authenticated user
  Future<bool> linkGuestToUser({
    required String userId,
    required String guestEmail,
  }) async {
    try {
      // Find guest by email
      final guest = await getGuestByEmail(guestEmail);
      if (guest == null) {
        if (kDebugMode) {
          print('Guest not found for email: $guestEmail');
        }
        return false;
      }

      // Update user profile with guest_id
      await _client
          .from('user_profiles')
          .update({'guest_id': guest.id})
          .eq('user_id', userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error linking guest to user: $e');
      }
      _error = 'Erreur lors de la liaison invité-utilisateur';
      notifyListeners();
      return false;
    }
  }

  /// Delete guest
  Future<bool> deleteGuest(String guestId) async {
    try {
      await _client.from('guests').delete().eq('id', guestId);

      // Refresh guests list
      await _loadGuests();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting guest: $e');
      }
      _error = 'Erreur lors de la suppression de l\'invité';
      notifyListeners();
      return false;
    }
  }

  /// Filter guests by RSVP status
  List<Guest> filterByRSVPStatus(String status) {
    return _guests.where((guest) => guest.rsvpStatus == status).toList();
  }

  /// Export guests as CSV
  String exportToCSV() {
    final lines = <String>['email,nom,statut,invités,restrictions,allergies'];
    for (final guest in _guests) {
      lines.add(
        '${guest.email},${guest.fullName},${guest.rsvpStatus},${guest.numberOfGuests},${guest.dietaryRestrictions ?? ''},${guest.allergies ?? ''}',
      );
    }
    return lines.join('\n');
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
