import 'package:flutter/material.dart';
import '../services/achievements_service.dart';
import '../models/achievement_model.dart' as achievement;

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header
            Text('🌿 EcoHelper', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Aplikasi edukasi dan aksi lingkungan.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),

            // Live Stats
            Text('📊 Statistik Anda', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            
            // Trees Planted
            ValueListenableBuilder<achievement.UserStats>(
              valueListenable: AchievementsService.statsNotifier,
              builder: (context, stats, _) {
                return _StatCard(
                  icon: '🌳',
                  title: 'Pohon Ditanam',
                  value: '${stats.treesPlanted}',
                  subtitle: 'total pohon virtual',
                );
              },
            ),
            const SizedBox(height: 8),

            // Total Points
            ValueListenableBuilder<achievement.UserStats>(
              valueListenable: AchievementsService.statsNotifier,
              builder: (context, stats, _) {
                return _StatCard(
                  icon: '⭐',
                  title: 'Total Poin',
                  value: '${stats.totalPoints}',
                  subtitle: 'dari tips & challenges',
                );
              },
            ),
            const SizedBox(height: 8),

            // Badges Unlocked
            ValueListenableBuilder<achievement.UserStats>(
              valueListenable: AchievementsService.statsNotifier,
              builder: (context, stats, _) {
                return _StatCard(
                  icon: '🏆',
                  title: 'Streak Terbaik',
                  value: '${stats.longestStreak}',
                  subtitle: 'hari berturut-turut',
                );
              },
            ),
            const SizedBox(height: 8),

            // Tips Completed
            ValueListenableBuilder<achievement.UserStats>(
              valueListenable: AchievementsService.statsNotifier,
              builder: (context, stats, _) {
                return _StatCard(
                  icon: '✅',
                  title: 'Tips Selesai',
                  value: '${stats.completedTips}',
                  subtitle: 'daily tips yang sudah dikerjakan',
                );
              },
            ),
            const SizedBox(height: 20),

            // Tech Stack
            Text('🛠️ Teknologi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _TechItem(label: 'Framework', value: 'Flutter 3.9.2+'),
            _TechItem(label: 'Language', value: 'Dart'),
            _TechItem(label: 'Backend', value: 'Supabase'),
            _TechItem(label: 'State Mgmt', value: 'flutter_bloc + ValueNotifier'),
            _TechItem(label: 'Design', value: 'Material Design 3'),
            const SizedBox(height: 20),

            // Features
            Text('✨ Fitur Utama', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _FeatureItem('📚 Artikel & Learning'),
            _FeatureItem('🎯 Daily Tips & Challenges'),
            _FeatureItem('🌱 Virtual Garden (Tracker)'),
            _FeatureItem('🏅 Achievements & Badges'),
            _FeatureItem('🔥 Carbon Calculator'),
            _FeatureItem('🎨 Event & Community'),
            const SizedBox(height: 20),

            // Footer
            Center(
              child: Column(
                children: [
                  Text('Versi 1.0.0', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('UAS Pemrograman Mobile 2', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Bergabunglah dalam gerakan keberlanjutan! 🌍', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.green[700])),
          ],
        ),
      ),
    );
  }
}

class _TechItem extends StatelessWidget {
  final String label;
  final String value;

  const _TechItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
          Text(value, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
