# Meeting App — Senior Flutter Assessment (Stage 1)

This Flutter app implements a 1:1 video calling flow using the provided backend API and Amazon Chime SDK.

## Setup Instructions

1. Clone repository and open project:
   ```bash
   git clone <your-repo-url>
   cd meeting_app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Verify API config in `lib/core/api_constants.dart`:
   - `baseUrl`: `https://assess.hipster-dev.com/api/`
   - `apiKey`: `qxsm2peuW5ZiMz5Nq7DS`
4. Run the app:
   ```bash
   flutter run
   ```
5. Build release APK:
   ```bash
   flutter build apk --release
   ```
   APK output: `build/app/outputs/flutter-apk/app-release.apk`

## State Management Used

- Primary state management: `flutter_bloc`
- `MeetingBloc` handles create/join/leave, status updates, mic/camera toggles, and event log messages.
- `MeetingState` stores current meeting status (`idle`, `joining`, `connected`, `disconnected`), `meetingId`, mic/camera state, and logs.
- `provider` is used for Chime SDK session state (`ChimeSession`) required by `flutter_amazon_chime` UI.

## Brief Architecture Overview

Project is organized into clear layers:

- **UI Layer**
  - `lib/screens/` (`HomeScreen`, `MeetingScreen`)
  - `lib/widgets/` (`MeetingLogs`, `MeetingStatusChip`, `MeetingChimeListener`)
- **Business Logic Layer**
  - `lib/bloc/meeting/` (`MeetingBloc`, events, state)
- **API Layer**
  - `lib/services/meeting_service.dart` (Dio HTTP client)
  - `lib/repository/meeting_repository.dart` (API abstraction)
- **Chime Integration Layer**
  - `lib/services/chime_meeting_service.dart`
  - local package `packages/flutter_amazon_chime`
- **Core Utilities**
  - `lib/core/utils/permission_service.dart`
  - `lib/core/utils/meeting_join_mapper.dart`
  - `lib/core/utils/api_error_formatter.dart`

Main runtime flow:
1. User taps Create/Join on Home.
2. Camera/microphone permissions are requested.
3. API call is made to `/meetings`.
4. Response is mapped to Chime `JoinInfo`.
5. Chime session starts and meeting screen shows status + event logs.

## Assumptions Made

- Backend API is reachable and API key is valid.
- `POST /meetings` supports both create and join flows using `type` + `meeting_id`.
- Join responses include required meeting and attendee information for Chime connection.
- Android is the primary target platform for this assessment.
- One meeting session at a time is sufficient for scope.

## Known Limitations

1. **Meeting expiry**: Old meeting IDs may return `Meeting not found`; a fresh meeting ID should be created for new test sessions.
2. **iOS validation not fully completed**: iOS permission keys are added, but full multi-device iOS verification was not part of this submission.
3. **Local plugin patch**: `flutter_amazon_chime` is vendored locally under `packages/flutter_amazon_chime` to fix Android main-thread callback crashes and improve stability.

