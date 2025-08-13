<a id="readme-top"></a>
# TechNews Flutter App

TechNews is a modern Flutter application built with **Clean Architecture** and **BLoC pattern** that delivers the latest technology news. The app features a robust architecture with proper separation of concerns, comprehensive error handling, and enterprise-grade code organization.

![Alt text](https://raw.githubusercontent.com/codewithkd77/technews-flutter/refs/heads/main/banner.jpeg)

## 🏗️ Architecture

This project follows **Clean Architecture** principles with the **BLoC (Business Logic Component)** pattern for state management, ensuring:

- **Separation of Concerns**: Clear boundaries between data, business logic, and presentation layers
- **Testability**: Interface-based design enables comprehensive unit and integration testing
- **Maintainability**: Modular structure makes the codebase easy to understand and modify
- **Scalability**: Architecture supports feature growth and team expansion
- **Error Handling**: Robust exception handling with custom error types


## 📁 Project Structure

```
lib/
├── main.dart                           # Application entry point with DI setup
├── core/                              # 🔧 Core functionality layer
│   ├── constants/                     # Application constants
│   │   ├── api_constants.dart         # API endpoints and configuration
│   │   └── app_constants.dart         # App-wide settings and constants
│   ├── errors/                        # Custom error handling
│   │   └── exceptions.dart            # Custom exception hierarchy
│   └── utils/                         # Utility functions
│       ├── date_utils.dart            # Date formatting and manipulation
│       └── network_utils.dart         # Network connectivity utilities
├── data/                              # 📊 Data layer
│   ├── datasources/                   # Data source abstractions
│   │   ├── news_data_source.dart      # Data source interfaces
│   │   ├── news_remote_data_source.dart # API implementation
│   │   └── news_local_data_source.dart  # Local storage implementation
│   └── repositories/                  # Repository implementations
│       └── news_repository_impl.dart  # News repository with DI
├── models/                            # 📋 Data models
│   └── news_article.dart             # News article model
├── bloc/                              # 🧠 Business logic layer (BLoC)
│   ├── navigation/                    # Navigation state management
│   │   ├── navigation_bloc.dart
│   │   ├── navigation_event.dart
│   │   └── navigation_state.dart
│   ├── news/                          # General tech news BLoC
│   │   ├── news_bloc.dart
│   │   ├── news_event.dart
│   │   └── news_state.dart
│   ├── ai_news/                       # AI-specific news BLoC
│   │   ├── ai_news_bloc.dart
│   │   ├── ai_news_event.dart
│   │   └── ai_news_state.dart
│   ├── saved_news/                    # Bookmarked news BLoC
│   │   ├── saved_news_bloc.dart
│   │   ├── saved_news_event.dart
│   │   └── saved_news_state.dart
│   └── news_detail/                   # Article detail BLoC
│       ├── news_detail_bloc.dart
│       ├── news_detail_event.dart
│       └── news_detail_state.dart
└── screens/                           # 🎨 Presentation layer
    ├── news_screen.dart               # Main news feed screen
    ├── ai_news_screen.dart            # AI news screen
    ├── saved_news_screen.dart         # Bookmarked articles screen
    └── news_detail_screen.dart        # Article detail screen
```

## 🚀 Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

## 🛠️ Technology Stack

- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language
- **BLoC Pattern**: State management and business logic
- **Clean Architecture**: Architectural design pattern
- **HTTP**: API communication
- **SharedPreferences**: Local data persistence
- **Equatable**: Value equality and immutability

### Prerequisites

Ensure you have the following installed on your machine:

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.0.0 or later)
- [Dart](https://dart.dev/get-dart) (version 3.0.0 or later)
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
    - Open the `lib/core/constants/api_constants.dart` file.
    - Replace the placeholder API URL and API key with your own:
    ```dart
    class ApiConstants {
      static const String baseUrl = 'YOUR_API_BASE_URL';
      static const String aiNewsApiUrl = 'YOUR_AI_NEWS_API_URL';
      static const String aiApiKey = 'YOUR_AI_API_KEY';
    }
    ```

4. **Run the project:**
    - **Android:**
        - Ensure you have an Android emulator running or a physical device connected.
        ```sh
        flutter run
        ```
    - **iOS:**
        - Ensure you have an iOS simulator running or a physical device connected.
        ```sh
        flutter run
        ```

## 📦 Building for Production

### Building the APK (Android)

To build the APK file for Android:
```sh
flutter build apk --release
```

The APK file will be generated in the `build/app/outputs/flutter-apk/` directory.

### Building the iOS App

To build the iOS app:
```sh
flutter build ios --release
```

Note: You need a macOS machine with Xcode installed to build the iOS app.

## 🏛️ Architecture Overview

### Clean Architecture Layers

1. **Core Layer** (`lib/core/`)
   - **Constants**: API endpoints, app configuration
   - **Errors**: Custom exception hierarchy for robust error handling
   - **Utils**: Shared utility functions and helpers

2. **Data Layer** (`lib/data/`)
   - **Data Sources**: Abstract interfaces and concrete implementations
     - `NewsRemoteDataSource`: API communication
     - `NewsLocalDataSource`: Local storage operations
   - **Repositories**: Implementation of repository interfaces with dependency injection

3. **Domain Layer** (Implicit)
   - **Models**: Data entities and business objects
   - **Repository Interfaces**: Abstract contracts for data operations

4. **Presentation Layer** (`lib/bloc/` + `lib/screens/`)
   - **BLoC**: Business logic and state management
   - **Screens**: UI components and user interactions

### Key Architectural Benefits

- **🔄 Dependency Inversion**: High-level modules don't depend on low-level modules
- **🧪 Testability**: Each layer can be tested independently
- **🔧 Maintainability**: Clear separation of concerns
- **📈 Scalability**: Easy to add new features and modify existing ones
- **🔒 Error Handling**: Comprehensive exception handling at each layer

## 🎯 BLoC Pattern Implementation

Each feature follows the BLoC pattern with three components:

### Events (User Actions)
```dart
abstract class NewsEvent extends Equatable {}
class NewsLoaded extends NewsEvent {}
class NewsRefreshed extends NewsEvent {}
```

### States (UI States)
```dart
abstract class NewsState extends Equatable {}
class NewsInitial extends NewsState {}
class NewsLoading extends NewsState {}
class NewsLoadSuccess extends NewsState {}
class NewsError extends NewsState {}
```

### BLoC (Business Logic)
```dart
class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository newsRepository;
  
  NewsBloc({required this.newsRepository}) : super(NewsInitial()) {
    on<NewsLoaded>(_onNewsLoaded);
  }
}
```

## 🛡️ Error Handling Strategy

The app implements a comprehensive error handling system:

### Custom Exception Hierarchy
```dart
// Base exception class
abstract class AppException implements Exception

// Specific exception types
class NetworkException extends AppException
class ApiException extends AppException  
class CacheException extends AppException
class ParseException extends AppException
```

### Error Handling in BLoCs
```dart
try {
  final news = await _newsRepository.fetchNews();
  emit(NewsLoadSuccess(articles: news));
} on NetworkException catch (e) {
  emit(NewsError('Network error: ${e.message}'));
} on ApiException catch (e) {
  emit(NewsError('API error: ${e.message}'));
} catch (error) {
  emit(NewsError('Unexpected error: ${error.toString()}'));
}
```

## 🧪 Testing

The Clean Architecture implementation supports comprehensive testing:

### Unit Tests
```sh
flutter test
```

### Integration Tests
```sh
flutter test integration_test/
```

### Test Structure
- **Unit Tests**: Test individual BLoCs, repositories, and data sources
- **Widget Tests**: Test UI components in isolation
- **Integration Tests**: Test complete user flows

## 📱 Screens Overview

### 🏠 News Screen (`news_screen.dart`)
- Main tech news feed
- Pull-to-refresh functionality
- Navigation to article details
- Search functionality

### 🤖 AI News Screen (`ai_news_screen.dart`)
- Dedicated AI and machine learning news
- Similar functionality to main news feed
- AI-specific content filtering

### 🔖 Saved News Screen (`saved_news_screen.dart`)
- Bookmarked articles management
- Local storage integration
- Remove from bookmarks functionality

### 📖 News Detail Screen (`news_detail_screen.dart`)
- Full article content display
- Bookmark/unbookmark functionality
- Share article feature
- Related articles suggestions

## 🔧 Configuration

### API Configuration
Update `lib/core/constants/api_constants.dart`:
```dart
class ApiConstants {
  static const String baseUrl = 'https://your-api-url.com';
  static const String newsEndpoint = '/api/news';
  static const String aiNewsApiUrl = 'https://your-ai-api-url.com';
  static const String aiApiKey = 'your-ai-api-key';
}
```

### App Configuration
Update `lib/core/constants/app_constants.dart`:
```dart
class AppConstants {
  static const String appName = 'TechNews';
  static const int newsPerPage = 20;
  static const Duration cacheTimeout = Duration(hours: 1);
}
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Follow the architecture**: Maintain Clean Architecture principles
4. **Write tests**: Include unit tests for new features
5. **Follow code style**: Use consistent formatting and naming
6. **Commit changes**: `git commit -m 'Add amazing feature'`
7. **Push to branch**: `git push origin feature/amazing-feature`
8. **Open a Pull Request**

### Code Style Guidelines
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comprehensive documentation
- Maintain consistent file structure
- Include proper error handling

## 🐛 Known Issues

- AI news API integration may require additional configuration
- Some network timeouts on slower connections
- iOS build requires macOS environment

## 🔮 Future Enhancements

- [ ] Dark mode support
- [ ] Push notifications for breaking news
- [ ] Offline reading mode
- [ ] Social sharing integration
- [ ] News categories and filtering
- [ ] User preferences and customization
- [ ] Analytics integration

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**KULDEEPSINH** - [codewithkd77](https://github.com/codewithkd77)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- BLoC pattern developers for state management solution
- Clean Architecture principles by Robert C. Martin
- Open source community for continuous inspiration

---

<p align="center">
  <strong>Built with ❤️ using Flutter and Clean Architecture</strong>
</p>

<p align="right">(<a href="#readme-top">back to top</a>)</p>
