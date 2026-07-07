import 'package:flutter/material.dart';

class MeetingLogs extends StatelessWidget {
  const MeetingLogs({super.key, required this.logs});

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(
        child: Text('No events', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            logs[index],
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        );
      },
    );
  }
}
