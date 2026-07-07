import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_amazon_chime/amazon_chime.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/meeting/meeting_bloc.dart';
import '../bloc/meeting/meeting_event.dart';
import '../services/chime_meeting_service.dart';

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
    final session = context.read<ChimeMeetingService>().session;
    final chime = AmazonChime.instance;

    void log(String message) {
      if (!mounted) return;
      bloc.add(AppendMeetingLog(message));
    }

    String? localAttendeeId() => session.localAttendeeId;

    _subscriptions.addAll([
      chime.onAttendeeJoined.listen((attendee) {
        if (attendee.attendeeId == localAttendeeId()) return;
        final participant = attendee.externalUserId.isNotEmpty
            ? attendee.externalUserId
            : attendee.attendeeId;
        debugPrint(
          '[Meeting] Attendee joined -> id=${attendee.attendeeId}, externalUserId=${attendee.externalUserId}',
        );
        log('Attendee joined: $participant');
      }),
      chime.onAttendeeLeft.listen((attendee) {
        if (attendee.attendeeId == localAttendeeId()) return;
        final participant = attendee.externalUserId.isNotEmpty
            ? attendee.externalUserId
            : attendee.attendeeId;
        debugPrint(
          '[Meeting] Attendee left -> id=${attendee.attendeeId}, externalUserId=${attendee.externalUserId}',
        );
        log('Attendee left: $participant');
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
        debugPrint(
          '[Meeting] Video tile added -> tileId=${tile.tileId}, attendeeId=${tile.attendeeId}, isLocal=${tile.isLocalTile}, isContent=${tile.isContentShare}',
        );
        if (!tile.isLocalTile) return;
        log('Camera enabled');
      }),
      chime.onVideoTileRemoved.listen((tile) {
        debugPrint(
          '[Meeting] Video tile removed -> tileId=${tile.tileId}, attendeeId=${tile.attendeeId}, isLocal=${tile.isLocalTile}, isContent=${tile.isContentShare}',
        );
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
