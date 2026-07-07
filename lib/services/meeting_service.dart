import 'package:dio/dio.dart';

import '../core/api_constants.dart';
import '../models/meeting_request.dart';
import '../models/meeting_response.dart';
import '../models/meeting_type.dart';

class MeetingService {
  MeetingService({Dio? dio, String? apiKey})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'X-API-Key': ?apiKey,
                },
              ),
            );

  final Dio _dio;

  Future<MeetingResponse> createMeeting() {
    return _postMeeting(const CreateMeetingRequest());
  }

  Future<MeetingResponse> joinClient(String meetingId) {
    return _postMeeting(
      JoinMeetingRequest(
        type: MeetingType.client,
        meetingId: meetingId,
      ),
    );
  }

  Future<MeetingResponse> joinAgent(String meetingId) {
    return _postMeeting(
      JoinMeetingRequest(
        type: MeetingType.agent,
        meetingId: meetingId,
      ),
    );
  }

  Future<MeetingResponse> _postMeeting(MeetingRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.meetingsPath,
        data: request.toJson(),
      );

      final data = response.data;
      if (data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Empty response body',
        );
      }

      return MeetingResponse.fromJson(data);
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        return MeetingResponse.fromJson(data);
      }
      rethrow;
    }
  }
}
