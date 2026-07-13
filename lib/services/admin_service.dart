import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity_log.dart';

class AdminService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ActivityLog>> getLogs({
    String? actionType,
    String? userId,
    int limit = 50,
  }) async {
    try {
      var query = _client.from('activity_logs').select();

      if (actionType != null) {
        query = query.eq('action_type', actionType);
      }

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => ActivityLog.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des logs: $e');
    }
  }

  Future<Map<String, dynamic>> getGalleryStats() async {
    try {
      final photosResponse = await _client
          .from('gallery_photos')
          .select('status, photo_url');

      int pending = 0, approved = 0, rejected = 0;
      for (final photo in photosResponse) {
        final status = (photo as Map<String, dynamic>)['status'] as String? ?? 'pending';
        switch (status) {
          case 'pending':
            pending++;
            break;
          case 'approved':
            approved++;
            break;
          case 'rejected':
            rejected++;
            break;
        }
      }

      return {
        'total_photos': photosResponse.length,
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
      };
    } catch (e) {
      throw Exception('Erreur lors du chargement des statistiques: $e');
    }
  }

  Future<bool> moderatePhoto({
    required String photoId,
    required String status,
  }) async {
    try {
      if (status != 'approved' && status != 'rejected') {
        throw Exception('Status must be "approved" or "rejected"');
      }

      await _client
          .from('gallery_photos')
          .update({'status': status})
          .eq('id', photoId);

      return true;
    } catch (e) {
      throw Exception('Erreur lors de la modération: $e');
    }
  }

  Future<bool> logActivity({
    required String userId,
    required String actionType,
    String? metadata,
  }) async {
    try {
      await _client.from('activity_logs').insert({
        'user_id': userId,
        'action_type': actionType,
        'metadata': metadata,
      });
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la création du log: $e');
    }
  }

  Future<List<dynamic>> getGuestsList({
    String? rsvpStatus,
    String? searchQuery,
  }) async {
    try {
      var query = _client.from('guests').select();

      if (rsvpStatus != null) {
        query = query.eq('rsvp_status', rsvpStatus);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'full_name.ilike.%$searchQuery%,email.ilike.%$searchQuery%',
        );
      }

      final response = await query;
      return response as List;
    } catch (e) {
      throw Exception('Erreur lors du chargement des invités: $e');
    }
  }
}
