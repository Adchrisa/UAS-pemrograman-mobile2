import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/local_data.dart';
import '../widget/article_card.dart';
import 'article_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  List<Article> results = [];

  void _onSearch(String q) {
    if (q.trim().isEmpty) {
      setState(() => results = []);
      return;
    }
    setState(() => results = LocalData.search(q));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Cari artikel, event, atau topik...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('Hasil pencarian akan muncul di sini'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (_, i) {
                        final it = results[i];
                        return ArticleCard(
                          id: it.id,
                          title: it.title,
                          subtitle: it.subtitle,
                          imageUrl: it.imageUrl,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArticleDetailScreen(
                                  id: it.id,
                                  title: it.title,
                                  subtitle: it.subtitle,
                                  content: it.content,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

