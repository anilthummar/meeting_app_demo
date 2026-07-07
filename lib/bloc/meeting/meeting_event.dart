import 'package:equatable/equatable.dart';

abstract class MeetingEvent extends Equatable {
  const MeetingEvent();

  @override
  List<Object?> get props => [];
}

class CreateMeeting extends MeetingEvent {
  const CreateMeeting();
}

class JoinMeeting extends MeetingEvent {
  const JoinMeeting(this.meetingId);

  final String meetingId;

  @override
  List<Object?> get props => [meetingId];
}

class ToggleMic extends MeetingEvent {
  const ToggleMic();
}

class ToggleCamera extends MeetingEvent {
  const ToggleCamera();
}

class LeaveMeeting extends MeetingEvent {
  const LeaveMeeting();
}

class AppendMeetingLog extends MeetingEvent {
  const AppendMeetingLog(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
