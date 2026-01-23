import 'package:flutter/material.dart';
import '../services/daily_tips_service.dart';
import '../services/achievements_service.dart';
import '../models/tip_model.dart';

class DailyTipsScreen extends StatefulWidget {
  const DailyTipsScreen({super.key});

  @override
  State<DailyTipsScreen> createState() => _DailyTipsScreenState();
}

class _DailyTipsScreenState extends State<DailyTipsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    DailyTipsService.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips & Tantangan'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Daily Tips', icon: Icon(Icons.lightbulb_outline)),
            Tab(text: 'Challenges', icon: Icon(Icons.emoji_events)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyTipTab(theme),
          _buildChallengesTab(theme),
        ],
      ),
    );
  }

  Widget _buildDailyTipTab(ThemeData theme) {
    final tip = DailyTipsService.getDailyTip();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.primary.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.wb_sunny, size: 60, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                'Tip Hari Ini',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateTime.now().toString().split(' ')[0],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tip Card
        ValueListenableBuilder<Set<String>>(
          valueListenable: DailyTipsService.completedTipsNotifier,
          builder: (context, completedTips, _) {
            final isCompleted = completedTips.contains(tip.id);

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(tip.category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(tip.category),
                          color: _getCategoryColor(tip.category),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getCategoryName(tip.category),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getCategoryColor(tip.category),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCompleted)
                        const Icon(Icons.check_circle, color: Colors.green, size: 32),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tip.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.stars, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '+${tip.points} Points',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (!isCompleted)
                        ElevatedButton.icon(
                          onPressed: () async {
                            await DailyTipsService.completeTip(tip.id);
                            await AchievementsService.completeTip(tip.points);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text('Selamat! +${tip.points} points'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Selesai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Motivational Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.eco, color: Colors.green, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Setiap aksi kecil membuat perbedaan besar untuk planet kita! 🌍',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChallengesTab(ThemeData theme) {
    final challenges = DailyTipsService.getAvailableChallenges();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: challenges.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Header
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Tantang Diri Anda!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final challenge = challenges[index - 1];
        return ValueListenableBuilder<List<ChallengeProgress>>(
          valueListenable: DailyTipsService.activeChallengesNotifier,
          builder: (context, activeList, _) {
            final progress = activeList.firstWhere(
              (p) => p.challengeId == challenge.id,
              orElse: () => ChallengeProgress(
                challengeId: challenge.id,
                startDate: DateTime.now(),
              ),
            );
            
            final isActive = activeList.any((p) => p.challengeId == challenge.id);
            final isCompleted = progress.isCompleted;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Colors.green.withOpacity(0.1)
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted 
                      ? Colors.green 
                      : theme.colorScheme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        challenge.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${challenge.durationDays} hari · ${challenge.difficulty}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getDifficultyColor(challenge.difficulty),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCompleted)
                        const Icon(Icons.verified, color: Colors.green, size: 28),
                    ],
                  ),
                  const SizedBox(height: 12),
                    Text(challenge.description),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.stars, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '+${challenge.points} Points',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        if (!isActive && !isCompleted)
                          ElevatedButton(
                            onPressed: () async {
                              await DailyTipsService.startChallenge(challenge.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Challenge dimulai! Good luck! 🚀'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Mulai'),
                          ),
                        if (isActive && !isCompleted)
                          ElevatedButton(
                            onPressed: () async {
                              await DailyTipsService.completeChallenge(challenge.id);
                              await AchievementsService.completeChallenge(challenge.points);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.emoji_events, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text('Challenge selesai! +${challenge.points} points'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Selesai'),
                          ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'energy':
        return Colors.orange;
      case 'waste':
        return Colors.green;
      case 'water':
        return Colors.blue;
      case 'transport':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'energy':
        return Icons.bolt;
      case 'waste':
        return Icons.recycling;
      case 'water':
        return Icons.water_drop;
      case 'transport':
        return Icons.directions_car;
      default:
        return Icons.eco;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'energy':
        return 'Energi';
      case 'waste':
        return 'Sampah';
      case 'water':
        return 'Air';
      case 'transport':
        return 'Transportasi';
      default:
        return 'Lainnya';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
