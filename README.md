# Whispers in the Hollow
A cinematic, atmospheric mobile story game built with Flutter and Dart.

This project includes:
- A cinematic intro sequence
- Creepy ambient audio trigger and voiceover narration
- Chapter-based survival storytelling
- Click-to-discover clues in a dark forest
- A final suspenseful outro and developer credits

## Prerequisites
- Flutter SDK 3.3 or newer
- VS Code with Flutter extension
- Android Studio or a suitable simulator/device

## Run the app
1. Open the folder in VS Code.
2. Run:
   ```bash
   flutter pub get
   flutter run
   ```
3. On a device or emulator, the game will launch.

## Project structure
- `lib/main.dart` — the complete game logic and UI
- `pubspec.yaml` — Flutter dependencies

## Notes
- The ambient sound uses a remote audio URL so the game has atmosphere immediately.
- The voiceover is generated through Flutter TTS for story narration.
- You can replace the remote sound with local assets later for a more polished production build.
