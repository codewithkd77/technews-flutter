<a id="readme-top"></a>
# TechNews Flutter App

![Alt text](https://raw.githubusercontent.com/codewithkd77/technews-flutter/refs/heads/main/banner.jpeg)


TechNews is a Flutter-based mobile application that provides the latest tech news.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Ensure you have the following installed on your machine:

- [Flutter](https://flutter.dev/docs/get-started/install) (version 2.0.0 or later)
- [Dart](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development, macOS only)
- [Visual Studio Code](https://code.visualstudio.com/) (optional, but recommended)

### Installation

1. **Clone the repository:**
    ```sh
    git clone https://github.com/codewithkd77/technews-flutter.git
    cd technews-flutter
    ```

2. **Install dependencies:**
    ```sh
    flutter pub get
    ```

3. **Configure API:**
    - Open the `lib/services/news_service.dart` file.
    - Replace the placeholder API URL and API key with your own.
    ```dart
    class NewsService {
      static const String apiUrl = 'YOUR_API_URL';
      static const String apiKey = 'YOUR_API_KEY';
    }
    ```

4. **Run the project:**
    - **Android:**
        - Ensure you have an Android emulator running or a physical device connected.
        - Run the following command:
            ```sh
            flutter run
            ```
    - **iOS:**
        - Ensure you have an iOS simulator running or a physical device connected.
        - Run the following command:
            ```sh
            flutter run
            ```

### Building the APK (Android)

To build the APK file for Android, run the following command:
```sh
flutter build apk --release
```

The APK file will be generated in the `build/app/outputs/flutter-apk/` directory.

### Building the iOS App

To build the iOS app, run the following command:
```sh
flutter build ios --release
```

Note: You need a macOS machine with Xcode installed to build the iOS app.

### Contributing


If you want to contribute to this project, please fork the repository and create a pull request with your changes.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
