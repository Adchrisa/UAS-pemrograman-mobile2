import 'package:flutter/material.dart';
import '../services/local_data.dart';
import '../services/eco_tips_service.dart';

class EcoTipsScreen extends StatefulWidget {
  const EcoTipsScreen({super.key});

  @override
  State<EcoTipsScreen> createState() => _EcoTipsScreenState();
}

class _EcoTipsScreenState extends State<EcoTipsScreen> {
  @override
  void initState() {
    super.initState();
    EcoTipsService.notifier.addListener(_onCompletedChanged);
  }

  @override
  void dispose() {
    EcoTipsService.notifier.removeListener(_onCompletedChanged);
    super.dispose();
  }

  void _onCompletedChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tips = LocalData.tips;
    final theme = Theme.of(context);
    final completedTips = EcoTipsService.notifier.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Eco Tips')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          final tipId = tip['id'] ?? 't$index';
          final isCompleted = completedTips.contains(tipId);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: theme.colorScheme.primary.withOpacity(0.05),
              border: Border.all(
                color: isCompleted
                    ? Colors.green.withOpacity(0.5)
                    : theme.colorScheme.primary.withOpacity(0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : theme.colorScheme.primary.withOpacity(0.15),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.lightbulb,
                  color: isCompleted ? Colors.green : theme.colorScheme.primary,
                ),
              ),
              title: Text(
                tip['title'] ?? 'Eco Tip',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isCompleted ? Colors.green[700] : null,
                ),
              ),
              subtitle: Text(
                tip['subtitle'] ?? '',
                style: theme.textTheme.bodySmall,
              ),
              trailing: IconButton(
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
                onPressed: () async {
                  await EcoTipsService.toggle(tipId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              isCompleted ? Icons.undo : Icons.check_circle,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCompleted
                                  ? 'Ditandai belum selesai'
                                  : 'Tips sudah dilakukan! ✓',
                            ),
                          ],
                        ),
                        backgroundColor: isCompleted ? Colors.orange : Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
