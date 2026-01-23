import 'package:flutter/material.dart';
import 'category_articles_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Sampah', 'icon': Icons.delete_outline, 'color': Colors.brown},
      {'name': 'Energi', 'icon': Icons.flash_on, 'color': Colors.yellow},
      {'name': 'Air', 'icon': Icons.water_drop, 'color': Colors.blue},
      {'name': 'Iklim', 'icon': Icons.cloud, 'color': Colors.cyan},
    ];

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final cat = categories[index];
          final name = cat['name'] as String;
          final icon = cat['icon'] as IconData;
          final color = cat['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryArticlesScreen(category: name),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            size: 40,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Telusuri artikel tentang $name',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
