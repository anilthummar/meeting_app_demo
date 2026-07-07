import 'package:flutter/material.dart';

import '../models/meeting_status.dart';

class MeetingStatusChip extends StatelessWidget {
  const MeetingStatusChip({super.key, required this.status});

  final MeetingStatus status;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(status.name.toUpperCase()),
        backgroundColor: _colorForStatus(status).withValues(alpha: 0.15),
        side: BorderSide(color: _colorForStatus(status)),
      ),
    );
  }

  Color _colorForStatus(MeetingStatus status) {
    return switch (status) {
      MeetingStatus.idle => Colors.grey,
      MeetingStatus.joining => Colors.orange,
      MeetingStatus.connected => Colors.green,
      MeetingStatus.disconnected => Colors.blueGrey,
    };
  }
}
