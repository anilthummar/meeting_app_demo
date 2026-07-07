import 'package:equatable/equatable.dart';

import 'chime_join_config.dart';

class MeetingResponse extends Equatable {
  const MeetingResponse({
    required this.status,
    this.message,
    this.meetingId,
    this.raw,
  });

  final String status;
  final String? message;
  final String? meetingId;
  final Map<String, dynamic>? raw;

  bool get isError => status == 'error';
  bool get isSuccess => status == 'success';

  ChimeJoinConfig? get chimeJoinConfig {
    final data = raw?['data'] as Map<String, dynamic>?;
    if (data == null) return null;
    return ChimeJoinConfig.fromJson(data);
  }

  factory MeetingResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final meeting = data?['meeting'] as Map<String, dynamic>?;

    return MeetingResponse(
      status: json['status'] as String? ?? 'unknown',
      message: json['message'] as String?,
      meetingId: meeting?['MeetingId'] as String? ??
          json['meeting_id'] as String?,
      raw: json,
    );
  }

  @override
  List<Object?> get props => [status, message, meetingId, raw];
}
