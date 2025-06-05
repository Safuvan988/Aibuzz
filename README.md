# Aibuzz

A modern Flutter news application that provides users with the latest news updates in a clean and intuitive interface.

## Features

- Browse latest news articles
- Read full articles in-app
- Share articles with others
- Save articles for offline reading
- Clean and modern Material Design UI

## Setup Instructions

### Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/aibuzz.git
cd aibuzz
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Architecture

The project follows a clean architecture pattern with the following structure:

```
lib/
├── main.dart              # Application entry point
├── screens/              # UI screens and widgets
├── services/             # API and data services
└── provider/             # State management
```

### Architecture Choices

1. **Provider Pattern**: Used for state management to maintain a clean separation of concerns and make the app more maintainable.
2. **Service Layer**: Implements API calls and data handling in a separate service layer for better code organization.
3. **Screen-based Structure**: UI components are organized by screens for better code navigation and maintenance.

## Third-Party Packages

The project uses several third-party packages to enhance functionality:

- **http (^1.1.0)**: For making HTTP requests to fetch news data
- **url_launcher (^6.2.4)**: To open URLs in the device's default browser
- **share_plus (^7.2.1)**: Enables sharing articles with other apps
- **dio (^5.8.0+1)**: Advanced HTTP client for making API requests with additional features
- **shared_preferences (^2.5.3)**: Local storage for saving user preferences and offline data
- **webview_flutter (^4.13.0)**: In-app web browser for reading full articles
- **provider (^6.1.5)**: State management solution
- **intl (^0.20.2)**: Internationalization and formatting utilities
- **cupertino_icons (^1.0.8)**: iOS-style icons for cross-platform consistency

### Development Dependencies

- **flutter_lints (^5.0.0)**: Enforces Flutter best practices and coding standards
- **flutter_test**: For writing and running tests

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
