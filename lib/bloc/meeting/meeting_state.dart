import 'package:equatable/equatable.dart';

import '../../models/meeting_status.dart';

class MeetingState extends Equatable {
  const MeetingState({
    this.status = MeetingStatus.idle,
    this.meetingId,
    this.micEnabled = true,
    this.cameraEnabled = true,
    this.logs = const [],
  });

  final MeetingStatus status;
  final String? meetingId;
  final bool micEnabled;
  final bool cameraEnabled;
  final List<String> logs;

  MeetingState copyWith({
    MeetingStatus? status,
    String? meetingId,
    bool? micEnabled,
    bool? cameraEnabled,
    List<String>? logs,
    bool clearMeetingId = false,
  }) {
    return MeetingState(
      status: status ?? this.status,
      meetingId: clearMeetingId ? null : (meetingId ?? this.meetingId),
      micEnabled: micEnabled ?? this.micEnabled,
      cameraEnabled: cameraEnabled ?? this.cameraEnabled,
      logs: logs ?? this.logs,
    );
  }

  @override
  List<Object?> get props => [
        status,
        meetingId,
        micEnabled,
        cameraEnabled,
        logs,
      ];
}
