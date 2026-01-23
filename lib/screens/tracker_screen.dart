import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/tree_service.dart';
import '../models/tree_model.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> with TickerProviderStateMixin {
  late AnimationController _treeAnimationController;
  late AnimationController _waterAnimationController;
  bool _showWaterAnimation = false;

  @override
  void initState() {
    super.initState();
    TreeService.init();
    TreeService.dailyCheckIn();
    
    _treeAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _waterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _treeAnimationController.dispose();
    _waterAnimationController.dispose();
    super.dispose();
  }

  void _showPlantTreeDialog() {
    final nameController = TextEditingController();
    TreeSpecies selectedSpecies = TreeSpecies.oak;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('🌱 Tanam Pohon Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pohon',
                  hintText: 'Contoh: Si Hijau',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TreeSpecies>(
                initialValue: selectedSpecies,
                decoration: const InputDecoration(
                  labelText: 'Jenis Pohon',
                  border: OutlineInputBorder(),
                ),
                items: [TreeSpecies.oak, TreeSpecies.bamboo].map((species) {
                  return DropdownMenuItem(
                    value: species,
                    child: Text(species.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedSpecies = value);
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                selectedSpecies.description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama pohon tidak boleh kosong')),
                  );
                  return;
                }
                
                final success = await TreeService.plantTree(
                  nameController.text.trim(),
                  selectedSpecies,
                );
                
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🌱 Pohon berhasil ditanam! Jangan lupa siram ya!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {});
                }
              },
              child: const Text('Tanam'),
            ),
          ],
        ),
      ),
    );
  }

  void _waterTree() async {
    final message = await TreeService.waterTree();
    
    if (mounted) {
      setState(() {
        _showWaterAnimation = true;
      });
      
      _waterAnimationController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            _showWaterAnimation = false;
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains('berhasil') ? Colors.blue : Colors.orange,
        ),
      );
    }
  }

  void _fertilizeTree() async {
    final message = await TreeService.fertilizeTree();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains('berhasil') ? Colors.green : Colors.orange,
        ),
      );
      setState(() {});
    }
  }

  void _showShop() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🛒 Toko Eco'),
        content: ValueListenableBuilder<int>(
          valueListenable: TreeService.ecoPointsNotifier,
          builder: (context, points, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('💰', style: TextStyle(fontSize: 32)),
                title: const Text('Poin Kamu'),
                subtitle: Text('$points poin'),
              ),
              const Divider(),
              ListTile(
                leading: const Text('🌿', style: TextStyle(fontSize: 24)),
                title: const Text('Pupuk'),
                subtitle: const Text('10 poin per buah'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final message = await TreeService.buyFertilizer(1);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    }
                  },
                  child: const Text('Beli'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeVisualization(TreeModel tree) {
    final growthProgress = TreeService.getGrowthProgress();
    
    return AnimatedBuilder(
      animation: _treeAnimationController,
      builder: (context, child) {
        final sway = math.sin(_treeAnimationController.value * 2 * math.pi) * 5;
        
        return Transform.translate(
          offset: Offset(sway, 0),
          child: _buildTreeStage(tree, growthProgress),
        );
      },
    );
  }

  Widget _buildTreeStage(TreeModel tree, double progress) {
    // Different visual for each growth stage
    switch (tree.growthStage) {
      case 0: // Seed
        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.brown[300],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🌰', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 8),
            Text('Benih', style: TextStyle(color: Colors.grey[600])),
          ],
        );
      
      case 1: // Sprout
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 80,
                  child: CustomPaint(
                    painter: SproutPainter(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Kecambah', style: TextStyle(color: Colors.grey[600])),
          ],
        );
      
      case 2: // Sapling
        return Column(
          children: [
            const Text('🌿', style: TextStyle(fontSize: 100)),
            const SizedBox(height: 8),
            Text('Bibit', style: TextStyle(color: Colors.grey[600])),
          ],
        );
      
      case 3: // Young tree
        return Column(
          children: [
            const Text('🌳', style: TextStyle(fontSize: 120)),
            const SizedBox(height: 8),
            Text('Pohon Muda', style: TextStyle(color: Colors.grey[600])),
          ],
        );
      
      case 4: // Mature tree
        return Column(
          children: [
            const Text('🌲', style: TextStyle(fontSize: 140)),
            const SizedBox(height: 8),
            Text('Pohon Dewasa', style: TextStyle(color: Colors.grey[600])),
          ],
        );
      
      case 5: // Fruiting
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const Text('🌳', style: TextStyle(fontSize: 150)),
                Positioned(
                  top: 20,
                  right: 20,
                  child: const Text('🍎', style: TextStyle(fontSize: 30)),
                ),
                Positioned(
                  top: 40,
                  left: 25,
                  child: const Text('🍎', style: TextStyle(fontSize: 25)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Berbuah!', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
          ],
        );
      
      default:
        return const Text('🌱', style: TextStyle(fontSize: 80));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌳 Pohon Virtual'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: TreeService.ecoPointsNotifier,
            builder: (context, points, _) => Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text('💰', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    '$points',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: _showShop,
            tooltip: 'Toko',
          ),
        ],
      ),
      body: ValueListenableBuilder<TreeModel?>(
        valueListenable: TreeService.currentTreeNotifier,
        builder: (context, tree, _) {
          if (tree == null || !tree.isAlive) {
            return _buildNoTreeView();
          }
          
          return _buildTreeView(tree, theme);
        },
      ),
    );
  }

  Widget _buildNoTreeView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌍', style: TextStyle(fontSize: 100)),
          const SizedBox(height: 24),
          const Text(
            'Belum ada pohon',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai tanam pohon virtual kamu!',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showPlantTreeDialog,
            icon: const Icon(Icons.add),
            label: const Text('Tanam Pohon'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeView(TreeModel tree, ThemeData theme) {
    final growthProgress = TreeService.getGrowthProgress();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tree Name & Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  tree.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${tree.species.displayName} • ${tree.stageName}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Usia: ${tree.ageInDays} hari',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Tree Visualization
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
              ),
              _buildTreeVisualization(tree),
              
              // Water animation
              if (_showWaterAnimation)
                AnimatedBuilder(
                  animation: _waterAnimationController,
                  builder: (context, child) {
                    return Positioned(
                      top: 50 + (_waterAnimationController.value * 150),
                      child: Opacity(
                        opacity: 1 - _waterAnimationController.value,
                        child: const Text('💧', style: TextStyle(fontSize: 40)),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Health Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '❤️ Kesehatan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      tree.healthStatus,
                      style: TextStyle(
                        color: tree.healthPoints >= 60 ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: tree.healthPoints / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(
                      tree.healthPoints >= 60 ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${tree.healthPoints.toInt()}/100',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Growth Progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🌱 Pertumbuhan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Stage ${tree.growthStage}/5',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: tree.growthStage >= 5 ? 1.0 : growthProgress / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(Colors.blue[400]),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tree.growthStage >= 5 ? 'Maksimal!' : '${growthProgress.toInt()}% ke stage berikutnya',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: tree.needsWater ? _waterTree : null,
                  icon: const Icon(Icons.water_drop),
                  label: const Text('Siram'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: TreeService.fertilizerCountNotifier,
                  builder: (context, count, _) => ElevatedButton.icon(
                    onPressed: count > 0 ? _fertilizeTree : null,
                    icon: const Icon(Icons.grass),
                    label: Text('Pupuk ($count)'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Warnings
          if (tree.isThirsty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pohon haus! Segera siram sebelum layu',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          
          if (tree.needsWater && !tree.isThirsty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Saatnya siram pohon untuk bonus poin!',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Hapus Pohon',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.red),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hapus Pohon?'),
                    content: const Text(
                      'Pohon akan dihapus dari akun ini. Kamu bisa menanam baru setelahnya.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await TreeService.deleteCurrentTree();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pohon dihapus. Kamu bisa menanam pohon baru.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    setState(() {});
                  }
                }
              },
            ),
          ),
          
          // Harvest button (if mature)
          if (tree.growthStage >= 5) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('🎉 Panen Pohon?'),
                      content: const Text(
                        'Pohon kamu sudah dewasa dan siap dipanen!\n\n'
                        'Kamu akan mendapat poin besar dan bisa tanam pohon baru.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Panen'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm == true) {
                    final message = await TreeService.harvestTree();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                      setState(() {});
                    }
                  }
                },
                icon: const Icon(Icons.agriculture),
                label: const Text('Panen Pohon'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Custom painter for sprout
class SproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    // Stem
    canvas.drawLine(
      Offset(size.width / 2, size.height),
      Offset(size.width / 2, size.height * 0.3),
      paint,
    );
    
    // Leaves
    paint.color = Colors.green;
    paint.style = PaintingStyle.fill;
    
    final leafPath = Path()
      ..moveTo(size.width / 2, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.3,
        size.width * 0.2, size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.45,
        size.width / 2, size.height * 0.4,
      );
    
    canvas.drawPath(leafPath, paint);
    
    final leafPath2 = Path()
      ..moveTo(size.width / 2, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.7, size.height * 0.2,
        size.width * 0.8, size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.7, size.height * 0.35,
        size.width / 2, size.height * 0.3,
      );
    
    canvas.drawPath(leafPath2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
