import 'package:flutter/material.dart';

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final date = (event['date'] as DateTime).toLocal().toString().split(' ')[0];
    return Scaffold(
      appBar: AppBar(title: Text(event['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event['title'], style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('$date • ${event['location']}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Text(event['description'], style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text('Daftar / Info lebih lanjut'))
          ],
        ),
      ),
    );
  }
}
