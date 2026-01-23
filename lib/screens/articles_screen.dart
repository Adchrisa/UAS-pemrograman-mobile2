import 'package:flutter/material.dart';
import '../services/local_data.dart';
import '../services/read_articles_service.dart';
import 'article_detail_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  @override
  void initState() {
    super.initState();
    ReadArticlesService.notifier.addListener(_onReadChanged);
  }

  @override
  void dispose() {
    ReadArticlesService.notifier.removeListener(_onReadChanged);
    super.dispose();
  }

  void _onReadChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = LocalData.articles;
    final theme = Theme.of(context);
    final readArticles = ReadArticlesService.notifier.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, idx) {
          final item = items[idx];
          final isRead = readArticles.contains(item.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.primary.withOpacity(0.05),
              border: Border.all(
                color: isRead
                    ? Colors.green.withOpacity(0.5)
                    : theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ArticleDetailScreen(
                        id: item.id,
                        title: item.title,
                        subtitle: item.subtitle,
                        content: item.content,
                      ),
                      transitionsBuilder: (_, anim, __, child) {
                        return FadeTransition(opacity: anim, child: child);
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.3),
                              theme.colorScheme.primary.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: isRead
                              ? const Icon(
                                  Icons.check_circle,
                                  size: 48,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.article,
                                  size: 48,
                                  color: theme.colorScheme.primary,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.category,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isRead ? Colors.green[700] : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                          if (isRead)
                            const Icon(
                              Icons.check_circle,
                              size: 20,
                              color: Colors.green,
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
    );
  }
}
