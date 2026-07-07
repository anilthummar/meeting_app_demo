import 'package:flutter/material.dart';
import 'package:flutter_amazon_chime/chime_session.dart';
import 'package:flutter_amazon_chime/views/grid/participant_grid.dart';
import 'package:flutter_amazon_chime/views/meeting_controls/meeting_controls.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/meeting/meeting_bloc.dart';
import '../bloc/meeting/meeting_event.dart';
import '../bloc/meeting/meeting_state.dart';
import '../widgets/meeting_chime_listener.dart';
import '../widgets/meeting_logs.dart';
import '../widgets/meeting_status_chip.dart';

class MeetingScreen extends StatelessWidget {
  const MeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MeetingChimeListener(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: BlocBuilder<MeetingBloc, MeetingState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Row(
                      children: [
                        MeetingStatusChip(status: state.status),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.meetingId ?? 'Meeting',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: _VideoPanel(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const MeetingControls(),
                        const SizedBox(width: 8),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                          ),
                          onPressed: () {
                            context.read<MeetingBloc>().add(const LeaveMeeting());
                            Navigator.of(context).pop();
                          },
                          child: const Icon(Icons.call_end, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 140,
                    color: Colors.grey.shade900,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
                          child: Text(
                            'Event Log',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(child: _MeetingLogPanel()),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VideoPanel extends StatelessWidget {
  const _VideoPanel();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ChimeSession>();

    return ParticipantGrid(
      participants: session.allParticipants,
      localAttendeeId: session.localAttendeeId,
      roster: session.roster,
      activeSpeakers: session.activeSpeakers.toSet(),
    );
  }
}

class _MeetingLogPanel extends StatelessWidget {
  const _MeetingLogPanel();

  @override
  Widget build(BuildContext context) {
    final logs = context.select((MeetingBloc bloc) => bloc.state.logs);
    return MeetingLogs(logs: logs);
  }
}
