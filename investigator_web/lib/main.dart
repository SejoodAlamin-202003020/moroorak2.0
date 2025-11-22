import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/investigator_auth_provider.dart';
import 'providers/investigator_report_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://eumjbckvwpjdrdoyajhr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV1bWpiY2t2d3BqZHJkb3lhamhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxODAzMDgsImV4cCI6MjA3NDc1NjMwOH0.owuuLsybPbrxE-Rjslb2nCXXIYpTRTt2IK0UHoDEVoQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InvestigatorAuthProvider()),
        ChangeNotifierProvider(create: (_) => InvestigatorReportProvider()),
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
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
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
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
