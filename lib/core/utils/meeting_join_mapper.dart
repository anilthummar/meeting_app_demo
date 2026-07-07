import 'package:flutter_amazon_chime/models/join_info.dart';

import '../../models/meeting_response.dart';
import '../../repository/meeting_media_cache.dart';

class MeetingJoinMapper {
  MeetingJoinMapper._();

  static const _missingMediaMessage =
      'Meeting media details are unavailable on this device. '
      'Create the meeting here first, or ask the backend to return MediaPlacement on join.';

  /// Builds [JoinInfo] from an API response, using [cache] when join omits media URLs.
  static JoinInfo? toJoinInfo(
    MeetingResponse response, {
    MeetingMediaCache? cache,
  }) {
    final data = response.raw?['data'] as Map<String, dynamic>?;
    if (data == null) return null;

    var meeting = Map<String, dynamic>.from(
      data['meeting'] as Map<String, dynamic>? ?? const {},
    );
    final attendee = data['attendee'] as Map<String, dynamic>? ?? const {};

    final meetingId = meeting['MeetingId'] as String? ?? response.meetingId ?? '';
    if (meetingId.isEmpty) return null;

    if (meeting['MediaPlacement'] == null) {
      final cachedMeeting = (cache ?? MeetingMediaCache.instance).get(meetingId);
      if (cachedMeeting != null) {
        meeting = {
          ...cachedMeeting,
          'MeetingId': meetingId,
        };
      }
    }

    final placement =
        meeting['MediaPlacement'] as Map<String, dynamic>? ?? const {};
    final audioHostUrl = placement['AudioHostUrl'] as String? ?? '';
    final audioFallbackUrl = placement['AudioFallbackUrl'] as String? ?? '';
    final signalingUrl = placement['SignalingUrl'] as String? ?? '';
    final turnControlUrl = placement['TurnControlUrl'] as String? ?? '';

    if (audioHostUrl.isEmpty ||
        audioFallbackUrl.isEmpty ||
        signalingUrl.isEmpty ||
        turnControlUrl.isEmpty) {
      return null;
    }

    final attendeeId = attendee['AttendeeId'] as String? ?? '';
    final joinToken = attendee['JoinToken'] as String? ?? '';
    if (attendeeId.isEmpty || joinToken.isEmpty) return null;

    return JoinInfo(
      meetingId: meetingId,
      externalMeetingId: meeting['ExternalMeetingId'] as String? ?? '',
      mediaRegion: meeting['MediaRegion'] as String? ?? 'ap-southeast-1',
      audioHostUrl: audioHostUrl,
      audioFallbackUrl: audioFallbackUrl,
      signalingUrl: signalingUrl,
      turnControlUrl: turnControlUrl,
      externalUserId: attendee['ExternalUserId'] as String? ?? '',
      attendeeId: attendeeId,
      joinToken: joinToken,
    );
  }

  static String get missingMediaMessage => _missingMediaMessage;
}
