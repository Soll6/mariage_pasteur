import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'theme/app_theme.dart';
import 'screens/enveloppe_screen.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'services/auth_service.dart';
import 'services/guest_service.dart';
import 'services/admin_service.dart';
import 'services/email_service.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/guest_management_screen.dart';
import 'screens/admin/photo_moderation_screen.dart';
import 'screens/couple/couple_login_screen.dart';
import 'screens/couple/couple_dashboard_screen.dart';
import 'widgets/auth_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MariageApp());
}

class MariageApp extends StatelessWidget {
  const MariageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => GuestService()),
        Provider(create: (_) => AdminService()),
        ChangeNotifierProvider(create: (_) => EmailService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          // Listen to auth state changes automatically
          return MaterialApp(
            title: 'Sonia & Aimé - Mariage',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: '/',
            routes: {
              // Public routes (invitation)
              '/': (context) => const AuthStateListener(child: EnveloppeScreen()),
              '/home': (context) => const AuthStateListener(child: HomeScreen()),
              '/setup': (context) => const SetupScreen(),

              // Protected admin routes
              '/admin/login': (context) => const AdminLoginScreen(),
              '/admin': (context) => AuthGuard(
                requiredRoles: ['admin'],
                child: const AdminDashboardScreen(),
              ),
              '/admin/guests': (context) => AuthGuard(
                requiredRoles: ['admin', 'couple'],
                child: const GuestManagementScreen(),
              ),
              '/admin/photos': (context) => AuthGuard(
                requiredRoles: ['admin', 'couple'],
                child: const PhotoModerationScreen(),
              ),

              // Protected couple routes
              '/couple/login': (context) => const CoupleLoginScreen(),
              '/couple': (context) => AuthGuard(
                requiredRoles: ['couple'],
                child: const CoupleDashboardScreen(),
              ),
            },
          );
        },
      ),
    );
  }
}

/// Widget to listen to authentication state changes
class AuthStateListener extends StatefulWidget {
  final Widget child;

  const AuthStateListener({super.key, required this.child});

  @override
  State<AuthStateListener> createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends State<AuthStateListener> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // Listen to Supabase auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Trigger auth service to update when state changes
      if (data.event == AuthChangeEvent.signedIn) {
        // Auto-login successful
        authService.ensureUserProfile();
      } else if (data.event == AuthChangeEvent.signedOut) {
        // User signed out
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
