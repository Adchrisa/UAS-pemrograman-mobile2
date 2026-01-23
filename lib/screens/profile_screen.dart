import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/settings_service.dart';
import '../services/bookmark_service.dart';
import '../services/achievements_service.dart';
import '../services/read_articles_service.dart';
import '../services/profile_service.dart';
import 'about_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  String name = 'Pengguna EcoHelper';
  String email = 'user@example.com';
  bool isLoading = true;
  int articlesRead = 0;
  int bookmarkCount = 0;
  int greenActionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Listen to achievement stats changes
    AchievementsService.statsNotifier.addListener(_onStatsChanged);
    // Listen to bookmark changes
    BookmarkService.notifier.addListener(_onBookmarksChanged);
    // Listen to read articles changes
    ReadArticlesService.notifier.addListener(_onReadArticlesChanged);
    // Listen to app lifecycle
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    AchievementsService.statsNotifier.removeListener(_onStatsChanged);
    BookmarkService.notifier.removeListener(_onBookmarksChanged);
    ReadArticlesService.notifier.removeListener(_onReadArticlesChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh bookmark count when returning to profile
      _refreshBookmarks();
    }
  }

  void _refreshBookmarks() async {
    final bookmarks = await BookmarkService.getAll();
    setState(() {
      bookmarkCount = bookmarks.length;
    });
  }

  void _onStatsChanged() {
    setState(() {
      greenActionCount = AchievementsService.statsNotifier.value.totalPoints;
    });
  }

  void _onBookmarksChanged() {
    setState(() {
      bookmarkCount = BookmarkService.notifier.value.length;
    });
  }

  void _onReadArticlesChanged() {
    setState(() {
      articlesRead = ReadArticlesService.notifier.value.length;
    });
  }

  void _loadProfile() async {
    setState(() => isLoading = true);
    
    // Get email from Supabase auth
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      email = user.email ?? 'user@example.com';
    }
    
    // Get name from ProfileService (Supabase or local cache)
    name = await ProfileService.loadDisplayName();
    
    // Load bookmarks
    final bookmarks = await BookmarkService.getAll();
    bookmarkCount = bookmarks.length;
    
    // Load read articles count
    final readArticles = await ReadArticlesService.getAll();
    articlesRead = readArticles.length;
    // Load stats from achievements
    greenActionCount = AchievementsService.statsNotifier.value.totalPoints;
    
    setState(() => isLoading = false);
  }

  void _editProfile() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final nameCtrl = TextEditingController(text: name);
        return AlertDialog(
          title: const Text('Edit Nama'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, nameCtrl.text),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        name = result;
      });
      // Use ProfileService to save (syncs to Supabase + local cache)
      await ProfileService.saveDisplayName(result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama berhasil diperbarui')),
        );
      }
    }
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.primary.withOpacity(0.08),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // Dark Mode Toggle (left side of edit)
          ValueListenableBuilder<bool>(
            valueListenable: SettingsService.notifier,
            builder: (context, isDark, _) {
              return IconButton(
                icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                onPressed: () => SettingsService.setDark(!isDark),
                tooltip: isDark ? 'Light Mode' : 'Dark Mode',
              );
            },
          ),
          // Edit Profile (right side)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
            tooltip: 'Edit Nama',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card - Centered Layout
            Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                          size: 56,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Name
                      Text(
                        name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Email with icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.email,
                            size: 18,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              email,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Eco Guardian',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Section
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.article,
                    label: 'Artikel Dibaca',
                    value: '$articlesRead',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.bookmark,
                    label: 'Bookmark',
                    value: '$bookmarkCount',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.eco,
                    label: 'Aksi Hijau',
                    value: '$greenActionCount',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Menu Items
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    title: const Text('About'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
