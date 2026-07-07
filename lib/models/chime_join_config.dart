import 'package:equatable/equatable.dart';

class ChimeMediaPlacement extends Equatable {
  const ChimeMediaPlacement({
    required this.audioHostUrl,
    required this.audioFallbackUrl,
    required this.signalingUrl,
    required this.turnControlUrl,
  });

  final String audioHostUrl;
  final String audioFallbackUrl;
  final String signalingUrl;
  final String turnControlUrl;

  factory ChimeMediaPlacement.fromJson(Map<String, dynamic> json) {
    return ChimeMediaPlacement(
      audioHostUrl: json['AudioHostUrl'] as String? ??
          json['audio_host_url'] as String? ??
          '',
      audioFallbackUrl: json['AudioFallbackUrl'] as String? ??
          json['audio_fallback_url'] as String? ??
          '',
      signalingUrl: json['SignalingUrl'] as String? ??
          json['signaling_url'] as String? ??
          '',
      turnControlUrl: json['TurnControlUrl'] as String? ??
          json['turn_control_url'] as String? ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'AudioHostUrl': audioHostUrl,
        'AudioFallbackUrl': audioFallbackUrl,
        'SignalingUrl': signalingUrl,
        'TurnControlUrl': turnControlUrl,
      };

  @override
  List<Object?> get props => [
        audioHostUrl,
        audioFallbackUrl,
        signalingUrl,
        turnControlUrl,
      ];
}

class ChimeJoinConfig extends Equatable {
  const ChimeJoinConfig({
    required this.meetingId,
    required this.attendeeId,
    required this.joinToken,
    required this.externalUserId,
    required this.mediaRegion,
    required this.mediaPlacement,
  });

  final String meetingId;
  final String attendeeId;
  final String joinToken;
  final String externalUserId;
  final String mediaRegion;
  final ChimeMediaPlacement mediaPlacement;

  factory ChimeJoinConfig.fromJson(Map<String, dynamic> json) {
    final meeting = json['Meeting'] as Map<String, dynamic>? ??
        json['meeting'] as Map<String, dynamic>? ??
        json;
    final attendee = json['Attendee'] as Map<String, dynamic>? ??
        json['attendee'] as Map<String, dynamic>? ??
        json;

    final placement = meeting['MediaPlacement'] as Map<String, dynamic>? ??
        meeting['media_placement'] as Map<String, dynamic>? ??
        const {};

    return ChimeJoinConfig(
      meetingId: meeting['MeetingId'] as String? ??
          meeting['meeting_id'] as String? ??
          '',
      attendeeId: attendee['AttendeeId'] as String? ??
          attendee['attendee_id'] as String? ??
          '',
      joinToken: attendee['JoinToken'] as String? ??
          attendee['join_token'] as String? ??
          '',
      externalUserId: attendee['ExternalUserId'] as String? ??
          attendee['external_user_id'] as String? ??
          '',
      mediaRegion: meeting['MediaRegion'] as String? ??
          meeting['media_region'] as String? ??
          '',
      mediaPlacement: ChimeMediaPlacement.fromJson(placement),
    );
  }

  Map<String, dynamic> toJson() => {
        'Meeting': {
          'MeetingId': meetingId,
          'MediaRegion': mediaRegion,
          'MediaPlacement': mediaPlacement.toJson(),
        },
        'Attendee': {
          'AttendeeId': attendeeId,
          'JoinToken': joinToken,
          'ExternalUserId': externalUserId,
        },
      };

  @override
  List<Object?> get props => [
        meetingId,
        attendeeId,
        joinToken,
        externalUserId,
        mediaRegion,
        mediaPlacement,
      ];
}
