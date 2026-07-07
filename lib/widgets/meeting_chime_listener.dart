import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_amazon_chime/amazon_chime.dart';
import 'package:flutter_amazon_chime/chime_session.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../bloc/meeting/meeting_bloc.dart';
import '../bloc/meeting/meeting_event.dart';

/// Forwards Amazon Chime SDK events into the meeting event log.
class MeetingChimeListener extends StatefulWidget {
  const MeetingChimeListener({required this.child, super.key});

  final Widget child;

  @override
  State<MeetingChimeListener> createState() => _MeetingChimeListenerState();
}

class _MeetingChimeListenerState extends State<MeetingChimeListener> {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _listenToChimeEvents());
  }

  void _listenToChimeEvents() {
    if (!mounted) return;

    final bloc = context.read<MeetingBloc>();
    final session = context.read<ChimeSession>();
    final chime = AmazonChime.instance;

    void log(String message) {
      if (!mounted) return;
      bloc.add(AppendMeetingLog(message));
    }

    String? localAttendeeId() => session.localAttendeeId;

    _subscriptions.addAll([
      chime.onAttendeeJoined.listen((attendee) {
        if (attendee.attendeeId == localAttendeeId()) return;
        log('Participant joined: ${attendee.externalUserId}');
      }),
      chime.onAttendeeLeft.listen((attendee) {
        if (attendee.attendeeId == localAttendeeId()) return;
        log('Participant left: ${attendee.externalUserId}');
      }),
      chime.onAttendeeMuted.listen((attendee) {
        if (attendee.attendeeId != localAttendeeId()) return;
        log('Microphone disabled');
      }),
      chime.onAttendeeUnmuted.listen((attendee) {
        if (attendee.attendeeId != localAttendeeId()) return;
        log('Microphone enabled');
      }),
      chime.onVideoTileAdded.listen((tile) {
        if (!tile.isLocalTile) return;
        log('Camera enabled');
      }),
      chime.onVideoTileRemoved.listen((tile) {
        if (!tile.isLocalTile) return;
        log('Camera disabled');
      }),
    ]);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
