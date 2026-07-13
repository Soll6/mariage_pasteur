import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mariage_pasteur/services/guest_service.dart';
import 'package:mariage_pasteur/models/guest.dart';

@GenerateMocks([SupabaseClient])
void main() {
  group('GuestService Tests', () {
    late GuestService guestService;

    setUp(() {
      guestService = GuestService();
      // Override the _client with a mock
    });

    test('GuestService can get RSVP stats', () {
      // Test the method exists and returns expected structure
      final stats = guestService.getRSVPStats();
      
      expect(stats.containsKey('confirmed'), isTrue);
      expect(stats.containsKey('declined'), isTrue);
      expect(stats.containsKey('pending'), isTrue);
      expect(stats.containsKey('total_guests'), isTrue);
    });

    test('GuestService can filter guests by RSVP status', () {
      // Test that the method exists
      final filtered = guestService.filterByRSVPStatus('pending');
      expect(filtered, isA<List<Guest>>());
    });

    test('GuestService can export to CSV', () {
      // Test that the method exists and returns a string
      final csv = guestService.exportToCSV();
      expect(csv, isA<String>());
    });
  });
}
