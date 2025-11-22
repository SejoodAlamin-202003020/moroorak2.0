import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils/const.dart';
import 'providers/auth_provider.dart';
import 'services/push_notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/new_report_screen.dart';
import 'screens/my_reports_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'package:investigator_web/providers/investigator_auth_provider.dart';
import 'package:investigator_web/screens/login_screen.dart'
    as investigator_login;
import 'package:investigator_web/screens/dashboard_screen.dart'
    as investigator_dashboard;
import 'package:investigator_web/screens/new_reports_screen.dart'
    as investigator_new_reports;
import 'package:investigator_web/screens/under_review_reports_screen.dart'
    as investigator_under_review;
import 'package:investigator_web/screens/closed_reports_screen.dart'
    as investigator_closed;
import 'package:investigator_web/screens/notifications_screen.dart'
    as investigator_notifications;
import 'package:investigator_web/screens/profile_screen.dart'
    as investigator_profile;
import 'package:investigator_web/screens/report_details_screen.dart'
    as investigator_report_details;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://eumjbckvwpjdrdoyajhr.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV1bWpiY2t2d3BqZHJkb3lhamhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxODAzMDgsImV4cCI6MjA3NDc1NjMwOH0.owuuLsybPbrxE-Rjslb2nCXXIYpTRTt2IK0UHoDEVoQ',
    );
  } catch (e) {
    print('Error initializing Supabase: $e');
  }

  // Initialize push notifications for mobile app
  if (!(kIsWeb && isWebPlatform)) {
    try {
      await PushNotificationService().initialize();
    } catch (e) {
      print('Error initializing push notifications: $e');
    }
  }

  if (kIsWeb && isWebPlatform) {
    // Run investigator web app
    runApp(const WebApp());
  } else {
    // Run mobile app
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Moroorak',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.poppinsTextTheme(),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/new_report': (context) => const NewReportScreen(),
          '/my_reports': (context) => const MyReportsScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InvestigatorAuthProvider()),
      ],
      child: MaterialApp(
        title: 'Moroorak - Traffic Investigation',
        locale: const Locale('en', 'US'), // Force English locale
        supportedLocales: const [
          Locale('en', 'US'),
        ],
        localeResolutionCallback: (locale, supportedLocales) =>
            const Locale('en', 'US'), // Always use English
        theme: ThemeData(
          colorScheme: const ColorScheme(
            primary: Color(0xFF556B2F), // Olive
            secondary: Color(0xFF8FBC8F), // Light olive
            surface: Colors.white,
            background: Color(0xFFF5F5F5), // Light gray background
            error: Color(0xFFD32F2F),
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Colors.black,
            onBackground: Colors.black,
            onError: Colors.white,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.robotoTextTheme(),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF556B2F), // Olive
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF556B2F)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF556B2F)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF556B2F), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(color: Color(0xFF556B2F)),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF556B2F), // Olive
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const investigator_login.LoginScreen(),
          '/dashboard': (context) =>
              const investigator_dashboard.DashboardScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InvestigatorAuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          return const investigator_dashboard.DashboardScreen();
        }

        return const investigator_login.LoginScreen();
      },
    );
  }
}
