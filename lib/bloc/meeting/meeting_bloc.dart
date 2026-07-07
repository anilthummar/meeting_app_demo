import 'package:flutter_amazon_chime/models/exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../core/utils/api_error_formatter.dart';
import '../../core/utils/meeting_join_mapper.dart';
import '../../models/meeting_response.dart';
import '../../models/meeting_status.dart';
import '../../repository/meeting_repository.dart';
import '../../services/chime_meeting_service.dart';
import 'meeting_event.dart';
import 'meeting_state.dart';

class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  MeetingBloc(
    this._repository,
    this._chimeMeetingService, {
    Logger? logger,
  })  : _logger = logger ?? Logger(),
        super(const MeetingState()) {
    on<CreateMeeting>(_onCreateMeeting);
    on<JoinMeeting>(_onJoinMeeting);
    on<ToggleMic>(_onToggleMic);
    on<ToggleCamera>(_onToggleCamera);
    on<LeaveMeeting>(_onLeaveMeeting);
    on<AppendMeetingLog>(_onAppendMeetingLog);
  }

  final MeetingRepository _repository;
  final ChimeMeetingService _chimeMeetingService;
  final Logger _logger;

  Future<void> _onCreateMeeting(
    CreateMeeting event,
    Emitter<MeetingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MeetingStatus.joining,
        logs: [...state.logs, 'Creating meeting...'],
      ),
    );

    try {
      final response = await _repository.createMeeting();

      if (response.isError) {
        emit(
          state.copyWith(
            status: MeetingStatus.idle,
            logs: [
              ...state.logs,
              ApiErrorFormatter.format(
                response.message,
                fallback: 'Failed to create meeting',
              ),
            ],
          ),
        );
        return;
      }

      await _joinChimeSession(response, emit);
    } catch (error, stackTrace) {
      _logger.e('Create meeting failed', error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: MeetingStatus.idle,
          logs: [...state.logs, _formatError(error, 'Failed to create meeting')],
        ),
      );
    }
  }

  Future<void> _onJoinMeeting(
    JoinMeeting event,
    Emitter<MeetingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MeetingStatus.joining,
        meetingId: event.meetingId,
        logs: [...state.logs, 'Joining meeting ${event.meetingId}...'],
      ),
    );

    try {
      final response = await _repository.joinClient(event.meetingId);

      if (response.isError) {
        emit(
          state.copyWith(
            status: MeetingStatus.idle,
            clearMeetingId: true,
            logs: [
              ...state.logs,
              ApiErrorFormatter.format(
                response.message,
                fallback: 'Failed to join meeting',
              ),
            ],
          ),
        );
        return;
      }

      await _joinChimeSession(response, emit, fallbackMeetingId: event.meetingId);
    } catch (error, stackTrace) {
      _logger.e('Join meeting failed', error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: MeetingStatus.idle,
          clearMeetingId: true,
          logs: [...state.logs, _formatError(error, 'Failed to join meeting')],
        ),
      );
    }
  }

  Future<void> _joinChimeSession(
    MeetingResponse response,
    Emitter<MeetingState> emit, {
    String? fallbackMeetingId,
  }) async {
    final joinInfo = MeetingJoinMapper.toJoinInfo(
      response,
      cache: _repository.mediaCache,
    );
    if (joinInfo == null) {
      throw MeetingJoinException(MeetingJoinMapper.missingMediaMessage);
    }

    emit(
      state.copyWith(
        logs: [...state.logs, 'Connecting to Chime...'],
      ),
    );

    await _chimeMeetingService.join(joinInfo);

    emit(
      state.copyWith(
        status: MeetingStatus.connected,
        meetingId: joinInfo.meetingId.isNotEmpty
            ? joinInfo.meetingId
            : fallbackMeetingId,
        logs: [
          ...state.logs,
          'Meeting started',
          'Connected to meeting ${joinInfo.meetingId}',
        ],
      ),
    );
  }

  String _formatError(Object error, String fallback) {
    if (error is ChimeException) {
      final details = error.code;
      if (details != null && details.isNotEmpty) {
        return '${error.message} ($details)';
      }
      return error.message;
    }
    if (error is MeetingJoinException) {
      return error.message;
    }
    final message = error.toString();
    if (message.isEmpty || message == 'Exception') {
      return fallback;
    }
    return message;
  }

  Future<void> _onToggleMic(ToggleMic event, Emitter<MeetingState> emit) async {
    if (state.status != MeetingStatus.connected) return;

    final enabled = !state.micEnabled;
    try {
      await _chimeMeetingService.setMicEnabled(enabled);
      emit(
        state.copyWith(
          micEnabled: enabled,
          logs: [...state.logs, 'Mic ${enabled ? 'on' : 'off'}'],
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          logs: [...state.logs, _formatError(error, 'Failed to toggle microphone')],
        ),
      );
    }
  }

  Future<void> _onToggleCamera(
    ToggleCamera event,
    Emitter<MeetingState> emit,
  ) async {
    if (state.status != MeetingStatus.connected) return;

    final enabled = !state.cameraEnabled;
    try {
      await _chimeMeetingService.setCameraEnabled(enabled);
      emit(
        state.copyWith(
          cameraEnabled: enabled,
          logs: [...state.logs, 'Camera ${enabled ? 'on' : 'off'}'],
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          logs: [...state.logs, _formatError(error, 'Failed to toggle camera')],
        ),
      );
    }
  }

  void _onAppendMeetingLog(
    AppendMeetingLog event,
    Emitter<MeetingState> emit,
  ) {
    if (event.message.isEmpty) return;
    if (state.logs.isNotEmpty && state.logs.last == event.message) return;

    emit(
      state.copyWith(
        logs: [...state.logs, event.message],
      ),
    );
  }

  Future<void> _onLeaveMeeting(
    LeaveMeeting event,
    Emitter<MeetingState> emit,
  ) async {
    if (state.status != MeetingStatus.connected) return;

    try {
      await _chimeMeetingService.leave();
    } catch (_) {
      // Still move UI back to idle even if native leave fails.
    }

    emit(
      state.copyWith(
        status: MeetingStatus.disconnected,
        clearMeetingId: true,
        logs: [...state.logs, 'Meeting ended', 'Left meeting'],
      ),
    );
  }
}
