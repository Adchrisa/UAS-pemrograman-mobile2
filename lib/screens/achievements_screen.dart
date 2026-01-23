import 'package:flutter/material.dart';
import '../services/achievements_service.dart';
import '../models/achievement_model.dart' as achievement;

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _leaderboard = [];
  bool _loadingLeaderboard = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    AchievementsService.init();
    AchievementsService.dailyCheckIn();
    _loadLeaderboard();
    
    // Listen to stats changes and refresh leaderboard
    AchievementsService.statsNotifier.addListener(_onStatsChanged);
  }

  void _onStatsChanged() {
    // Reload leaderboard when stats change
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final data = await AchievementsService.getLeaderboard();
    if (mounted) {
      setState(() {
        _leaderboard = data;
        _loadingLeaderboard = false;
      });
    }
  }

  @override
  void dispose() {
    AchievementsService.statsNotifier.removeListener(_onStatsChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Stats', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Badges', icon: Icon(Icons.military_tech)),
            Tab(text: 'Leaderboard', icon: Icon(Icons.leaderboard)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(theme),
          _buildBadgesTab(theme),
          _buildLeaderboardTab(theme),
        ],
      ),
    );
  }

  Widget _buildStatsTab(ThemeData theme) {
    return ValueListenableBuilder<achievement.UserStats?>(
      valueListenable: AchievementsService.statsNotifier,
      builder: (context, stats, _) {
        if (stats == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Total Points Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars, size: 60, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    '${stats.totalPoints}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total Eco Points',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Streak Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_fire_department, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stats.currentStreak} Hari',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'Streak saat ini',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${stats.longestStreak}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Terlama',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  icon: Icons.emoji_events,
                  value: '${stats.completedChallenges}',
                  label: 'Challenges',
                  color: Colors.purple,
                  theme: theme,
                ),
                _buildStatCard(
                  icon: Icons.lightbulb,
                  value: '${stats.completedTips}',
                  label: 'Tips Completed',
                  color: Colors.amber,
                  theme: theme,
                ),
                _buildStatCard(
                  icon: Icons.park,
                  value: '${stats.treesPlanted}',
                  label: 'Trees Planted',
                  color: Colors.green,
                  theme: theme,
                ),
                _buildStatCard(
                  icon: Icons.co2,
                  value: '${stats.co2Saved.toStringAsFixed(1)}kg',
                  label: 'CO₂ Saved',
                  color: Colors.blue,
                  theme: theme,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesTab(ThemeData theme) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: AchievementsService.unlockedBadgesNotifier,
      builder: (context, unlockedBadges, _) {
        final badges = AchievementsService.getAllBadges();
        final unlockedCount = badges.where((b) => b.isUnlocked).length;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Progress Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.military_tech, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$unlockedCount / ${badges.length} Badges',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: unlockedCount / badges.length,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Badges Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                return _buildBadgeCard(badge, theme);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadgeCard(achievement.Badge badge, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badge.isUnlocked 
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badge.isUnlocked 
              ? theme.colorScheme.primary.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.icon,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              height: 1.1,
              color: badge.isUnlocked ? null : Colors.grey.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: badge.isUnlocked 
                  ? theme.textTheme.bodySmall?.color 
                  : Colors.grey[600],
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!badge.isUnlocked && badge.requiredPoints > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${badge.requiredPoints} pts',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(ThemeData theme) {
    if (_loadingLeaderboard) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _leaderboard.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Top Eco Warriors 🏆',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final item = _leaderboard[index - 1];
        final isCurrentUser = item['isCurrentUser'] == true;
        final rank = item['rank'];

        Color? rankColor;
        if (rank == 1) rankColor = Colors.amber;
        if (rank == 2) rankColor = Colors.grey[400];
        if (rank == 3) rankColor = Colors.brown[300];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentUser 
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: isCurrentUser 
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: rankColor ?? Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: rank <= 3 ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                item['avatar'],
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${item['points']} points',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (rank <= 3)
                Icon(
                  Icons.emoji_events,
                  color: rankColor,
                  size: 32,
                ),
            ],
          ),
        );
      },
    );
  }
}
