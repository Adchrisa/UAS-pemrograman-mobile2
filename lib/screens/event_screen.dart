import 'package:flutter/material.dart';
import '../services/local_data.dart';
import 'event_detail_screen.dart';
import '../services/event_service.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List events = [];
  Set<String> joined = {};

  @override
  void initState() {
    super.initState();
    events = LocalData.getEvents();
    _loadJoined();
  }

  void _loadJoined() async {
    final s = await EventService.getJoined();
    setState(() => joined = s.toSet());
  }

  void _toggleJoin(String id) async {
    await EventService.toggleJoin(id);
    _loadJoined();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Lingkungan'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (_, i) {
          final event = events[i];
          final id = event['id'] as String;
          final isJoined = joined.contains(id);
          final date = event['date'] as DateTime;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.08),
                  theme.colorScheme.primary.withOpacity(0.02),
                ],
              ),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
                ),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.withOpacity(0.3),
                              Colors.pink.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.event,
                            size: 40,
                            color: Colors.purple[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['title'] ?? 'Event',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  date.toLocal().toString().split(' ')[0],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isJoined
                                    ? Colors.grey[300]
                                    : theme.colorScheme.primary,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _toggleJoin(id),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isJoined ? Icons.check : Icons.add,
                                          size: 18,
                                          color: isJoined ? Colors.grey[600] : Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isJoined ? 'Sudah Ikut' : 'Ikuti',
                                          style: TextStyle(
                                            color: isJoined ? Colors.grey[600] : Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
