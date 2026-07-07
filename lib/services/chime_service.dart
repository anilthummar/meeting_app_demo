import 'dart:async';

import '../models/chime_join_config.dart';
import 'chime/chime_method_channel_platform.dart';
import 'chime/chime_platform.dart';

class ChimeService {
  ChimeService({ChimePlatform? platform})
      : _platform = platform ?? ChimeMethodChannelPlatform();

  final ChimePlatform _platform;

  void Function(String participantId)? onParticipantJoined;
  void Function(String participantId)? onParticipantLeft;
  void Function()? onMeetingStarted;
  void Function()? onMeetingEnded;
  void Function(bool isMuted)? onMuteChanged;
  void Function(bool isEnabled)? onCameraChanged;

  StreamSubscription<Map<String, dynamic>>? _eventSubscription;

  bool _initialized = false;
  bool _joined = false;
  bool _micMuted = false;
  bool _cameraEnabled = true;
  bool _disposed = false;

  bool get isInitialized => _initialized;
  bool get isJoined => _joined;
  bool get isMicMuted => _micMuted;
  bool get isCameraEnabled => _cameraEnabled;

  Future<void> initialize() async {
    _ensureNotDisposed();
    if (_initialized) return;

    await _platform.initialize();
    _eventSubscription ??= _platform.events.listen(_handlePlatformEvent);
    _initialized = true;
  }

  Future<void> joinMeeting(ChimeJoinConfig config) async {
    _ensureNotDisposed();
    if (!_initialized) {
      throw StateError('ChimeService must be initialized before joining.');
    }
    if (_joined) {
      throw StateError('Already joined to a meeting.');
    }

    await _platform.joinMeeting(config);
    _joined = true;
    _micMuted = false;
    _cameraEnabled = true;
  }

  Future<void> leaveMeeting() async {
    _ensureNotDisposed();
    if (!_joined) return;

    await _platform.leaveMeeting();
    _joined = false;
  }

  Future<void> toggleMic() async {
    _ensureNotDisposed();
    if (!_joined) {
      throw StateError('Cannot toggle mic when not in a meeting.');
    }

    final isMuted = !_micMuted;
    await _platform.setMicEnabled(!isMuted);
    _micMuted = isMuted;
    onMuteChanged?.call(isMuted);
  }

  Future<void> toggleCamera() async {
    _ensureNotDisposed();
    if (!_joined) {
      throw StateError('Cannot toggle camera when not in a meeting.');
    }

    final isEnabled = !_cameraEnabled;
    await _platform.setCameraEnabled(isEnabled);
    _cameraEnabled = isEnabled;
    onCameraChanged?.call(isEnabled);
  }

  Future<void> dispose() async {
    if (_disposed) return;

    await _eventSubscription?.cancel();
    _eventSubscription = null;

    if (_joined) {
      await _platform.leaveMeeting();
      _joined = false;
    }

    await _platform.dispose();

    _initialized = false;
    _disposed = true;

    onParticipantJoined = null;
    onParticipantLeft = null;
    onMeetingStarted = null;
    onMeetingEnded = null;
    onMuteChanged = null;
    onCameraChanged = null;
  }

  void _handlePlatformEvent(Map<String, dynamic> event) {
    final type = event['type'] as String?;
    if (type == null) return;

    switch (type) {
      case 'participantJoined':
        final participantId = event['participantId'] as String?;
        if (participantId != null) {
          onParticipantJoined?.call(participantId);
        }
      case 'participantLeft':
        final participantId = event['participantId'] as String?;
        if (participantId != null) {
          onParticipantLeft?.call(participantId);
        }
      case 'meetingStarted':
        onMeetingStarted?.call();
      case 'meetingEnded':
        _joined = false;
        onMeetingEnded?.call();
      case 'muteChanged':
        final isMuted = event['isMuted'] as bool?;
        if (isMuted != null) {
          _micMuted = isMuted;
          onMuteChanged?.call(isMuted);
        }
      case 'cameraChanged':
        final isEnabled = event['isEnabled'] as bool?;
        if (isEnabled != null) {
          _cameraEnabled = isEnabled;
          onCameraChanged?.call(isEnabled);
        }
    }
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('ChimeService has been disposed.');
    }
  }
}
