import 'package:flutter/services.dart';

import '../../models/chime_join_config.dart';
import 'chime_platform.dart';

class ChimeMethodChannelPlatform implements ChimePlatform {
  ChimeMethodChannelPlatform({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  })  : _methodChannel =
            methodChannel ?? const MethodChannel('com.example.meeting_app/chime'),
        _eventChannel =
            eventChannel ?? const EventChannel('com.example.meeting_app/chime_events');

  static const _initialize = 'initialize';
  static const _joinMeeting = 'joinMeeting';
  static const _leaveMeeting = 'leaveMeeting';
  static const _setMicEnabled = 'setMicEnabled';
  static const _setCameraEnabled = 'setCameraEnabled';
  static const _dispose = 'dispose';

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  @override
  Stream<Map<String, dynamic>> get events {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
  }

  @override
  Future<void> initialize() {
    return _methodChannel.invokeMethod<void>(_initialize);
  }

  @override
  Future<void> joinMeeting(ChimeJoinConfig config) {
    return _methodChannel.invokeMethod<void>(
      _joinMeeting,
      config.toJson(),
    );
  }

  @override
  Future<void> leaveMeeting() {
    return _methodChannel.invokeMethod<void>(_leaveMeeting);
  }

  @override
  Future<void> setMicEnabled(bool enabled) {
    return _methodChannel.invokeMethod<void>(_setMicEnabled, enabled);
  }

  @override
  Future<void> setCameraEnabled(bool enabled) {
    return _methodChannel.invokeMethod<void>(_setCameraEnabled, enabled);
  }

  @override
  Future<void> dispose() {
    return _methodChannel.invokeMethod<void>(_dispose);
  }
}
