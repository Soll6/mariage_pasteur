import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> sendRsvpConfirmation({
    required String to,
    required String guestName,
    required bool attending,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'send-wedding-email',
        body: {
          'type': 'rsvp_confirmation',
          'to': to,
          'guestName': guestName,
          'attending': attending,
        },
      );

      if (response.status != 200) {
        if (kDebugMode) {
          print('Email error: ${response.data}');
        }
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending RSVP confirmation email: $e');
      }
      return false;
    }
  }

  Future<bool> sendReminder({
    required String to,
    required String guestName,
    required int daysUntilWedding,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'send-wedding-email',
        body: {
          'type': 'reminder',
          'to': to,
          'guestName': guestName,
          'daysUntilWedding': daysUntilWedding,
        },
      );

      if (response.status != 200) {
        if (kDebugMode) {
          print('Email error: ${response.data}');
        }
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending reminder email: $e');
      }
      return false;
    }
  }

  Future<bool> sendCustomEmail({
    required String to,
    required String guestName,
    required String subject,
    required String html,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'send-wedding-email',
        body: {
          'type': 'custom',
          'to': to,
          'guestName': guestName,
          'subject': subject,
          'customHtml': html,
        },
      );

      if (response.status != 200) {
        if (kDebugMode) {
          print('Email error: ${response.data}');
        }
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending custom email: $e');
      }
      return false;
    }
  }
}
