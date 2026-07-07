import '../../models/chime_join_config.dart';

abstract class ChimePlatform {
  Stream<Map<String, dynamic>> get events;

  Future<void> initialize();

  Future<void> joinMeeting(ChimeJoinConfig config);

  Future<void> leaveMeeting();

  Future<void> setMicEnabled(bool enabled);

  Future<void> setCameraEnabled(bool enabled);

  Future<void> dispose();
}
