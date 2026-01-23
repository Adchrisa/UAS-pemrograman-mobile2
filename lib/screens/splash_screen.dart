import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main_nav.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 Splash Screen initialized');

    Future.delayed(const Duration(seconds: 2), () async {
      debugPrint('🔄 Splash Screen checking session...');
      
      if (!mounted) {
        debugPrint('⚠️ Widget not mounted, returning');
        return;
      }

      try {
        final session = Supabase.instance.client.auth.currentSession;
        debugPrint('🔄 Current session: ${session != null ? session.user.email : "null"}');

        if (!mounted) return;

        if (session != null) {
          debugPrint('✅ User logged in, navigating to MainNav');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNav()),
          );
        } else {
          debugPrint('📝 No session, navigating to LoginScreen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } catch (e) {
        debugPrint('❌ Error in splash: $e');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'EcoHelper',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
