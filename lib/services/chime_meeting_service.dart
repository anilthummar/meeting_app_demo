import 'package:flutter_amazon_chime/amazon_chime.dart';
import 'package:flutter_amazon_chime/chime_session.dart';
import 'package:flutter_amazon_chime/models/join_info.dart';
import 'package:logger/logger.dart';

class MeetingJoinException implements Exception {
  MeetingJoinException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ChimeMeetingService {
  ChimeMeetingService(this._session, {Logger? logger})
      : _logger = logger ?? Logger();

  final ChimeSession _session;
  final Logger _logger;

  Future<void> join(JoinInfo joinInfo) async {
    await _ensureChimePermissions();
    await AmazonChime.instance.joinMeeting(joinInfo);
    _session.initializeMeeting(
      joinInfo: joinInfo,
      roster: {joinInfo.attendeeId: joinInfo.externalUserId},
    );
    try {
      await AmazonChime.instance.startLocalVideo();
    } catch (error, stackTrace) {
      _logger.w('Local video failed to start', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _ensureChimePermissions() async {
    if (!await AmazonChime.instance.hasAudioPermissions()) {
      await AmazonChime.instance.requestAudioPermissions();
    }
    if (!await AmazonChime.instance.hasVideoPermissions()) {
      await AmazonChime.instance.requestVideoPermissions();
    }
  }

  Future<void> leave() async {
    await _session.stopMeeting();
  }

  Future<void> setMicEnabled(bool enabled) async {
    if (enabled) {
      await AmazonChime.instance.unmute();
    } else {
      await AmazonChime.instance.mute();
    }
  }

  Future<void> setCameraEnabled(bool enabled) async {
    if (enabled) {
      await AmazonChime.instance.startLocalVideo();
    } else {
      await AmazonChime.instance.stopLocalVideo();
    }
  }
}
