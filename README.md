



https://github.com/user-

https://github.com/user-attachments/assets/0f47178d-a9ab-48d2-9b0c-74709f69fb91

attachments/assets/f6bcff68-b862-4647-9e5d-95af3f2a7bb8


https://github.com/user-attachments/assets/ac4f6c14-39d5-42b6-b906-1f65f3e4f764



https://github.com/user-attachments/assets/ead2cdd3-a3da-423e-b9b6-33219228892e




# Meeting App — Senior Flutter Assessment (Stage 1)

This Flutter app implements the required 1:1 meeting flow using the provided API and Amazon Chime SDK.

## Setup Instructions

1. Clone and open project:
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
4. Run app:
   ```bash
   flutter run
   ```
5. Build release APK:
   ```bash
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`

## State Management Used

- `flutter_bloc` (BLoC) is used for app state management.
- Only BLoC is used for application state management (no mixed Provider state management in the app tree).
- `MeetingBloc` handles:
  - Create meeting
  - Join meeting
  - Leave meeting
  - Meeting status updates (`idle`, `joining`, `connected`, `disconnected`)
  - Mic/Camera toggle state
  - Event log updates

## Brief Architecture Overview

- **UI Layer**: `lib/screens`, `lib/widgets`
- **Business Logic Layer**: `lib/bloc/meeting`
- **API Layer**: `lib/services/meeting_service.dart`, `lib/repository/meeting_repository.dart`
- **Chime Integration Layer**: `lib/services/chime_meeting_service.dart`, `packages/flutter_amazon_chime`
- **Utilities**: permissions, response mapping, error formatting in `lib/core/utils`

Flow:
1. User taps Create/Join.
2. Camera and microphone permissions are requested.
3. API request is sent to `/meetings`.
4. API response is mapped to Chime join configuration.
5. Meeting screen shows video, controls, status, and event log.

## Assumptions Made

- API endpoint and key provided in assignment are valid.
- `POST /meetings` supports:
  - Create: `{ "type": "agent" }`
  - Join: `{ "type": "client", "meeting_id": "<uuid>" }`
- Join response includes required meeting + attendee details for Chime connection.
- Android is the primary tested platform for this submission.

## Known Limitations

1. Meeting IDs can expire; old IDs may return `Meeting not found`.
2. iOS permissions are configured, but full iOS device validation was not completed.
3. Local patched `flutter_amazon_chime` package is used for Android callback stability fixes.

## Demo Video

- Google Drive: [Meeting App Demo Video](https://drive.google.com/drive/folders/1h4yPxtcPDnkOTIXzlVnjz9FuSANbW2Wh?usp=sharing)

## APK Download

- Google Drive: [app-release.apk](https://drive.google.com/file/d/1jNyVV86M7GsMBU37LarAVBJIcaWcW17H/view?usp=sharing)
