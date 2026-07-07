import '../models/meeting_response.dart';
import '../services/meeting_service.dart';
import 'meeting_media_cache.dart';

class MeetingRepository {
  MeetingRepository(
    this._service, {
    MeetingMediaCache? mediaCache,
  }) : _mediaCache = mediaCache ?? MeetingMediaCache.instance;

  final MeetingService _service;
  final MeetingMediaCache _mediaCache;

  Future<MeetingResponse> createMeeting() async {
    final response = await _service.createMeeting();
    _cacheMeetingMedia(response);
    return response;
  }

  Future<MeetingResponse> joinClient(String meetingId) {
    return _service.joinClient(meetingId);
  }

  Future<MeetingResponse> joinAgent(String meetingId) {
    return _service.joinAgent(meetingId);
  }

  MeetingMediaCache get mediaCache => _mediaCache;

  void _cacheMeetingMedia(MeetingResponse response) {
    if (!response.isSuccess || response.meetingId == null) return;

    final meeting = response.raw?['data']?['meeting'] as Map<String, dynamic>?;
    if (meeting == null || meeting['MediaPlacement'] == null) return;

    _mediaCache.save(response.meetingId!, meeting);
  }
}
