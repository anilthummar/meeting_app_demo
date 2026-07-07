import 'package:equatable/equatable.dart';

import 'meeting_type.dart';

sealed class MeetingRequest extends Equatable {
  const MeetingRequest();

  Map<String, dynamic> toJson();
}

class CreateMeetingRequest extends MeetingRequest {
  const CreateMeetingRequest({this.type = MeetingType.agent});

  final MeetingType type;

  @override
  Map<String, dynamic> toJson() => {'type': type.value};

  @override
  List<Object?> get props => [type];
}

class JoinMeetingRequest extends MeetingRequest {
  const JoinMeetingRequest({
    required this.type,
    required this.meetingId,
  });

  final MeetingType type;
  final String meetingId;

  @override
  Map<String, dynamic> toJson() => {
        'type': type.value,
        'meeting_id': meetingId,
      };

  @override
  List<Object?> get props => [type, meetingId];
}
