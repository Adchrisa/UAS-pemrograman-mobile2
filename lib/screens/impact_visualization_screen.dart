import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ImpactVisualizationScreen extends StatefulWidget {
  const ImpactVisualizationScreen({super.key});

  @override
  State<ImpactVisualizationScreen> createState() => _ImpactVisualizationScreenState();
}

class _ImpactVisualizationScreenState extends State<ImpactVisualizationScreen> {
  List<Map<String, dynamic>> _carbonHistory = [];
  int _streakDays = 0;
  double _totalCO2Saved = 0;
  double _avgDailyCO2 = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('carbon_history') ?? [];
    final trackerData = prefs.getStringList('tracker') ?? [];
    
    final parsedHistory = history.map((e) {
      try {
        return jsonDecode(e) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).toList();

    // Calculate streak
    int streak = 0;
    for (var i = trackerData.length - 1; i >= 0; i--) {
      if (trackerData[i] == 'true') {
        streak++;
      } else {
        break;
      }
    }

    // Calculate CO2 metrics
    double totalCO2 = 0;
    for (var entry in parsedHistory) {
      if (entry['co2'] != null) {
        totalCO2 += (entry['co2'] as num).toDouble();
      }
    }

    // Baseline CO2: 15kg/day (rata-rata Indonesia)
    final baselineCO2 = 15.0 * parsedHistory.length;
    final saved = baselineCO2 - totalCO2;
    final avgDaily = parsedHistory.isNotEmpty ? totalCO2 / parsedHistory.length : 0;

    setState(() {
      _carbonHistory = parsedHistory;
      _streakDays = streak;
      _totalCO2Saved = saved > 0 ? saved : 0;
      _avgDailyCO2 = avgDaily.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualisasi Dampak'),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Hero Stats
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.analytics,
                    size: 56,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Dampak Positif Anda',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tracking ${_carbonHistory.length} hari terakhir',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.trending_down,
                    value: '${_totalCO2Saved.toStringAsFixed(1)} kg',
                    label: 'CO₂ Dikurangi',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    value: '$_streakDays hari',
                    label: 'Streak Kebiasaan',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.eco,
                    value: (_totalCO2Saved / 21.77).toStringAsFixed(1),
                    label: 'Setara Pohon',
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.speed,
                    value: '${_avgDailyCO2.toStringAsFixed(1)} kg',
                    label: 'Rata-rata/Hari',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Chart
            _buildProgressChart(),
            const SizedBox(height: 24),

            // Equivalent Impacts
            _buildEquivalentImpacts(),
            const SizedBox(height: 24),

            // Weekly Comparison
            _buildWeeklyComparison(),
            const SizedBox(height: 24),

            // Achievement Section
            _buildAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: Colors.purple),
              const SizedBox(width: 8),
              const Text(
                'Tren Jejak Karbon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: _carbonHistory.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada data.\nMulai gunakan kalkulator karbon!',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _buildBars(),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegend(Colors.green, 'Baik'),
              _buildLegend(Colors.orange, 'Sedang'),
              _buildLegend(Colors.red, 'Tinggi'),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBars() {
    final lastSevenDays = _carbonHistory.length > 7
        ? _carbonHistory.sublist(_carbonHistory.length - 7)
        : _carbonHistory;

    return lastSevenDays.map((entry) {
      final co2 = (entry['co2'] as num?)?.toDouble() ?? 0;
      final height = (co2 / 30 * 100).clamp(20.0, 100.0);
      final color = co2 < 10 ? Colors.green : co2 < 20 ? Colors.orange : Colors.red;

      return Flexible(
        child: Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildEquivalentImpacts() {
    final treesPlanted = (_totalCO2Saved / 21.77).toInt();
    final kmsWalked = (_totalCO2Saved / 0.21).toInt();
    final lightsOff = (_totalCO2Saved / 0.5).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Setara Dengan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEquivalentItem(
            icon: '🌳',
            title: '$treesPlanted pohon ditanam',
            subtitle: 'Menyerap CO₂ selama 1 tahun',
          ),
          const Divider(),
          _buildEquivalentItem(
            icon: '🚶',
            title: '$kmsWalked km jalan kaki',
            subtitle: 'Dibanding naik mobil',
          ),
          const Divider(),
          _buildEquivalentItem(
            icon: '💡',
            title: '$lightsOff jam lampu dimatikan',
            subtitle: 'Penghematan listrik rumah',
          ),
        ],
      ),
    );
  }

  Widget _buildEquivalentItem({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyComparison() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.purple),
              const SizedBox(width: 8),
              const Text(
                'Perbandingan Mingguan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Target',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '< 70 kg',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Text(
                      'CO₂/minggu',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Aktual Anda',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_avgDailyCO2 * 7).toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _avgDailyCO2 * 7 < 70 ? Colors.green : Colors.orange,
                      ),
                    ),
                    const Text(
                      'CO₂/minggu',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: ((_avgDailyCO2 * 7) / 70).clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _avgDailyCO2 * 7 < 70 ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {
        'icon': Icons.eco,
        'title': 'Eco Warrior',
        'desc': 'Kurangi 50kg CO₂',
        'unlocked': _totalCO2Saved >= 50,
      },
      {
        'icon': Icons.local_fire_department,
        'title': 'Streak Master',
        'desc': '7 hari berturut-turut',
        'unlocked': _streakDays >= 7,
      },
      {
        'icon': Icons.forest,
        'title': 'Tree Planter',
        'desc': 'Setara 5 pohon',
        'unlocked': _totalCO2Saved >= 108.85,
      },
      {
        'icon': Icons.star,
        'title': 'Carbon Hero',
        'desc': 'Rata-rata <10kg/hari',
        'unlocked': _avgDailyCO2 < 10 && _carbonHistory.length >= 7,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'Pencapaian',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: achievements.map((achievement) {
              final unlocked = achievement['unlocked'] as bool;
              return Container(
                width: (MediaQuery.of(context).size.width - 64) / 2,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: unlocked
                      ? Colors.amber.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: unlocked
                        ? Colors.amber.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      achievement['icon'] as IconData,
                      size: 32,
                      color: unlocked ? Colors.amber : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: unlocked ? Colors.amber[800] : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['desc'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
