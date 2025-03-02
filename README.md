# Simplicity IDE

A cross-platform Smart Contract IDE built with Flutter. Simplicity IDE provides a clean, intuitive interface for developing, testing, and deploying smart contracts.

## Overview

Simplicity IDE is a development environment specifically designed for smart contract development. It features syntax highlighting, code completion, and tools for interacting with blockchain networks.

![Smart Contract IDE](https://github.com/user-attachments/assets/8406aea8-a276-4da1-a23e-3fef018ff52a)


## Features

- Code editor with syntax highlighting for multiple languages (Dart, Python)
- Dark theme for reduced eye strain during long coding sessions
- Support for smart contract deployment
- Private key management for blockchain interactions
- Cross-platform support (iOS, Android, Windows, macOS, Linux, Web)

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (latest stable version)
- For platform-specific development:
  - Android: Android Studio with SDK
  - iOS/macOS: Xcode and CocoaPods
  - Windows: Visual Studio with C++ desktop development workload
  - Linux: Required development libraries (see Flutter documentation)

### Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/simplicity_ide.git
cd simplicity_ide
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Building for Production

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### macOS

```bash
flutter build macos --release
```

### Windows

```bash
flutter build windows --release
```

### Linux

```bash
flutter build linux --release
```

### Web

```bash
flutter build web --release
```

## Firebase Integration

This project uses Firebase with the project name "simplicity-ide". To configure Firebase:

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

3. Initialize Firebase in your project (if not already done):
```bash
firebase init
```

4. Deploy to Firebase:
```bash
firebase deploy
```

## Project Structure

```
lib/               # Dart source code
├── main.dart      # Application entry point
android/           # Android-specific code
ios/               # iOS-specific code
macos/             # macOS-specific code
windows/           # Windows-specific code
linux/             # Linux-specific code
web/               # Web-specific code
```

## Dependencies

- [code_text_field](https://pub.dev/packages/code_text_field): Code editor widget
- [flutter_highlight](https://pub.dev/packages/flutter_highlight): Syntax highlighting
- [http](https://pub.dev/packages/http): HTTP requests for API interaction

For a complete list, see the pubspec.yaml file.

## Development Notes

### Line Endings

This project has configured Git to normalize line endings to Windows-style (CRLF) when committing changes. This helps maintain consistency across different operating systems.

If you're contributing to this project, you may want to configure Git to properly handle line endings:

#### For Windows users:
```bash
git config --global core.autocrlf true
```

#### For Linux/macOS users:
```bash
git config --global core.autocrlf input
```

This configuration ensures that line endings are consistent in the repository regardless of which operating system contributors are using.

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Your Name - [@yourtwitter](https://twitter.com/affanshaikhsurab) - email@example.com

Project Link: [https://github.com/affanshaikhsurab/simplicity_ide](https://github.com/affanshaikhsurab/simplicity_ide)

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [highlight.js](https://highlightjs.org/)

