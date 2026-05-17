# BrainRush

BrainRush is a simple Android Flutter game that gives the player a 60-second brain challenge. The app generates quick math questions and asks the player to choose the correct answer from four options before the timer runs out.

This is the first MVP version of the app. It is intentionally small, clean, and beginner-friendly.

## Features

- Dark modern Flutter UI
- Home screen with app title and start button
- 60-second countdown timer
- Random math questions using addition, subtraction, and multiplication
- Four answer choices for each question
- Score increases after every correct answer
- Small feedback message for correct and wrong answers
- End screen with final score
- Play Again and Back Home actions

## Screens

- **Home Screen**: Shows the BrainRush title, subtitle, and Start Game button.
- **Game Screen**: Shows the timer, score, math question, answer buttons, and feedback.
- **End Screen**: Shows the final score with options to play again or return home.

## Tech Stack

- Flutter
- Dart
- Android

No Firebase, backend, ads, or extra packages are used in this version.

## Project Structure

```text
lib/
  main.dart        # Main Flutter app and game screens

android/           # Android Flutter project files
test/
  widget_test.dart # Basic widget test
```

## Getting Started

Make sure Flutter is installed, then run:

```bash
flutter pub get
flutter run
```

To check the project:

```bash
flutter analyze
flutter test
```

## Current Status

BrainRush is currently a working MVP. Future versions may add better animations, difficulty levels, sound effects, saved high scores, and improved app icons.
