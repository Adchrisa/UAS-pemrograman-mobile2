import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/local_data.dart';
import '../services/bookmark_service.dart';
import 'article_detail_screen.dart';
import 'category_screen.dart';
import 'category_articles_screen.dart';
import 'eco_tips_screen.dart';
import 'articles_screen.dart';
import 'bookmark_screen.dart';
import 'carbon_calculator_screen.dart';
import 'impact_visualization_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoHelper', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero Banner
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang!',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Belajar. Beraksi. Berbagi.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Carbon Footprint Tools
          Text(
            'Jejak Karbon Anda',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildToolCard(
                  context,
                  icon: Icons.calculate,
                  title: 'Kalkulator\nKarbon',
                  gradient: [Colors.green.shade400, Colors.teal.shade400],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CarbonCalculatorScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToolCard(
                  context,
                  icon: Icons.analytics,
                  title: 'Visualisasi\nDampak',
                  gradient: [Colors.purple.shade400, Colors.blue.shade400],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ImpactVisualizationScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Eco Tips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Eco Tips',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EcoTipsScreen()),
                ),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: LocalData.getTips().map((tip) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    tip['title'] ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(tip['subtitle'] ?? ''),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Categories Grid
          Text(
            'Kategori',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: ['Sampah', 'Energi', 'Air', 'Iklim']
                .map((category) => _buildCategoryCard(context, category))
                .toList(),
          ),
          const SizedBox(height: 24),

          // Artikel Terbaru Carousel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Artikel Terbaru',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ArticlesScreen()),
                ),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: LocalData.articles.take(5).length,
              itemBuilder: (_, i) {
                final article = LocalData.articles[i];
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.2),
                        theme.colorScheme.primary.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArticleDetailScreen(
                              id: article.id,
                              title: article.title,
                              subtitle: article.subtitle,
                              content: article.content,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    article.category,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.article,
                                  color: theme.colorScheme.primary.withOpacity(0.5),
                                  size: 28,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              article.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                article.subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Baca Selengkapnya',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Bookmark Section
          ValueListenableBuilder<Set<String>>(
            valueListenable: BookmarkService.notifier,
            builder: (_, bookmarks, __) {
              if (bookmarks.isEmpty) return const SizedBox.shrink();

                final List<Article> bookmarkedArticles = bookmarks
                  .map((id) => LocalData.getById(id))
                  .whereType<Article>()
                  .take(3)
                  .toList();

              if (bookmarkedArticles.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bookmark Saya',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BookmarkScreen()),
                        ),
                        icon: const Icon(Icons.bookmark),
                        label: Text('${bookmarks.length}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...bookmarkedArticles.map((article) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.amber.withOpacity(0.05),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArticleDetailScreen(
                                  id: article.id,
                                  title: article.title,
                                  subtitle: article.subtitle,
                                  content: article.content,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.bookmark,
                                    color: Colors.amber,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.title,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        article.subtitle,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category) {
    final theme = Theme.of(context);
    final colors = {
      'Sampah': Colors.brown,
      'Energi': Colors.yellow,
      'Air': Colors.blue,
      'Iklim': Colors.cyan,
    };

    final icons = {
      'Sampah': Icons.delete_outline,
      'Energi': Icons.flash_on,
      'Air': Icons.water_drop,
      'Iklim': Icons.cloud,
    };

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryArticlesScreen(category: category),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors[category]?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
              colors[category]?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors[category]?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icons[category],
              size: 48,
              color: colors[category],
            ),
            const SizedBox(height: 12),
            Text(
              category,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors[category],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Ink(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
