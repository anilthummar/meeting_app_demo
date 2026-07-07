import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/meeting/meeting_bloc.dart';
import '../bloc/meeting/meeting_event.dart';
import '../bloc/meeting/meeting_state.dart';
import '../core/utils/permission_service.dart';
import '../models/meeting_status.dart';
import 'meeting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final _meetingIdPattern = RegExp(
    r'^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$',
  );

  final _meetingIdController = TextEditingController();
  final _permissionService = const PermissionService();

  @override
  void dispose() {
    _meetingIdController.dispose();
    super.dispose();
  }

  Future<void> _onCreateMeetingPressed(BuildContext context) async {
    final granted =
        await _permissionService.requestCameraAndMicrophonePermissions(context);
    if (!granted || !context.mounted) {
      return;
    }

    context.read<MeetingBloc>().add(const CreateMeeting());
  }

  Future<void> _onJoinMeetingPressed(BuildContext context) async {
    final meetingId = _meetingIdController.text.trim();
    if (meetingId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a meeting ID'),
        ),
      );
      return;
    }

    if (!_meetingIdPattern.hasMatch(meetingId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid meeting ID. Create a meeting first, then use its ID.',
          ),
        ),
      );
      return;
    }

    final granted =
        await _permissionService.requestCameraAndMicrophonePermissions(context);
    if (!granted || !context.mounted) {
      return;
    }

    context.read<MeetingBloc>().add(JoinMeeting(meetingId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: BlocConsumer<MeetingBloc, MeetingState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            (previous.status == MeetingStatus.joining &&
                current.status == MeetingStatus.idle &&
                current.logs.isNotEmpty),
        listener: (context, state) {
          if (state.status == MeetingStatus.connected) {
            if (state.meetingId != null) {
              _meetingIdController.text = state.meetingId!;
            }

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MeetingScreen(),
              ),
            );
            return;
          }

          if (state.status == MeetingStatus.idle &&
              state.logs.isNotEmpty) {
            final message = state.logs.last;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        builder: (context, state) {
          final isJoining = state.status == MeetingStatus.joining;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _meetingIdController,
                  decoration: const InputDecoration(
                    labelText: 'Meeting ID',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isJoining,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: isJoining
                      ? null
                      : () => _onCreateMeetingPressed(context),
                  child: isJoining
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Meeting'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: isJoining
                      ? null
                      : () => _onJoinMeetingPressed(context),
                  child: const Text('Join Meeting'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
