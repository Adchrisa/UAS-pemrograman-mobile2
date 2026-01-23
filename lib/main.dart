import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'core/env.dart';
import 'services/bookmark_service.dart';
import 'services/settings_service.dart';
import 'services/api_service.dart';
import 'services/daily_tips_service.dart';
import 'services/achievements_service.dart';
import 'bloc/article_bloc.dart';
import 'bloc/article_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with error handling
  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('⚠️ Gagal inisialisasi Supabase: $e');
    // App tetap bisa jalan tanpa Supabase (menggunakan local data)
  }

  // Jika debugResetBookmarks true, lakukan reset sekali pada startup.
  if (AppConstants.debugResetBookmarks) {
    // Use a one-time request flag to avoid accidental repeated clears.
    final spRequested = await BookmarkService.resetIfRequested();
    // Jika tidak ada request di SharedPreferences, kita set langsung true lalu panggil clear.
    // Ini membuat proses reset berjalan sekali segera setelah pertama kali dijalankan.
    // Setelah reset, BookmarkService akan menonaktifkan flag.
    if (!spRequested) {
      // set request and call reset
      final sp = await SharedPreferences.getInstance();
      await sp.setBool('eco_reset_bookmarks_request', true);
      await BookmarkService.resetIfRequested();
    }
  }

  // init settings (dark mode)
  try {
    await SettingsService.init();
  } catch (e) {
    debugPrint('⚠️ Gagal inisialisasi Settings: $e');
  }

  // init daily tips service
  try {
    await DailyTipsService.init();
  } catch (e) {
    debugPrint('⚠️ Gagal inisialisasi Daily Tips: $e');
  }

  // init achievements service
  try {
    await AchievementsService.init();
  } catch (e) {
    debugPrint('⚠️ Gagal inisialisasi Achievements: $e');
  }

  // Add error handler untuk mencegah white screen
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('❌ Flutter Error: ${details.exception}');
    debugPrint('${details.stack}');
  };

  runApp(const EcoHelperApp());
}

class EcoHelperApp extends StatelessWidget {
  const EcoHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🚀 EcoHelperApp building...');
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ArticleBloc(apiService: ApiService())
            ..add(const LoadArticlesEvent()),
        ),
      ],
      child: ValueListenableBuilder<bool>(
        valueListenable: SettingsService.notifier,
        builder: (context, isDark, _) {
          try {
            debugPrint('📱 Building MaterialApp with theme mode: ${isDark ? "dark" : "light"}');
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: AppConstants.appName,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              home: const SplashScreen(),
            );
          } catch (e) {
            debugPrint('❌ Error building MaterialApp: $e');
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Error: $e'),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
