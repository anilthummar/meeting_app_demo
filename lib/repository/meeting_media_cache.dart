/// In-memory cache of Chime meeting media details keyed by meeting ID.
///
/// The join API returns attendee tokens but not [MediaPlacement], so client joins
/// on the same device can reuse media details cached from create.
class MeetingMediaCache {
  MeetingMediaCache._();

  static final MeetingMediaCache instance = MeetingMediaCache._();

  final Map<String, Map<String, dynamic>> _meetings = {};

  void save(String meetingId, Map<String, dynamic> meeting) {
    _meetings[meetingId] = Map<String, dynamic>.from(meeting);
  }

  Map<String, dynamic>? get(String meetingId) => _meetings[meetingId];
}
