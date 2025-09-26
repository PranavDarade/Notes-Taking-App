# Notes Taking App

A feature-rich, modern notes application built with Flutter, featuring Clean Architecture, Firebase integration, and advanced note management capabilities.

## 🚀 Features

### Core Features
- **Rich Text Editing**: Powered by Flutter Quill for advanced text formatting
- **Note Management**: Create, edit, delete, pin, and favorite notes
- **Search & Filter**: Advanced search with filtering options (pinned, favorites, locked, recent)
- **Staggered Grid Layout**: Beautiful masonry-style note display
- **Color Coding**: Customizable note colors for better organization
- **Tags System**: Organize notes with custom tags

### Authentication & Sync
- **Firebase Authentication**: Email/password and Google Sign-In
- **Cloud Sync**: Two-way synchronization between local storage and Firestore
- **Offline Support**: Full functionality without internet connection
- **Auto Sync**: Automatic synchronization when connected

### Security & Privacy
- **Biometric Authentication**: Fingerprint/Face ID for sensitive notes
- **Note Locking**: Lock individual notes with biometric authentication
- **Secure Storage**: Local encryption with Hive database

### Notifications & Reminders
- **Local Notifications**: Schedule reminders for important notes
- **Smart Reminders**: Set custom reminder dates for notes
- **Notification Management**: Full control over notification settings

### User Experience
- **Modern UI**: Material Design 3 with custom theming
- **Dark/Light Theme**: System-aware theme switching
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Responsive Design**: Optimized for all screen sizes
- **Accessibility**: Full accessibility support

## 🏗️ Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and constants
│   ├── constants/          # App constants and configuration
│   ├── themes/             # App theming and styling
│   ├── router/             # Navigation routing
│   └── utils/              # Utility functions
├── data/                   # Data layer
│   ├── local/              # Local storage (Hive)
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
├── domain/                 # Domain layer
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business logic use cases
├── presentation/           # Presentation layer
│   ├── pages/              # UI pages/screens
│   ├── providers/          # Riverpod state management
│   └── widgets/            # Reusable UI components
└── services/               # External services
    ├── auth_service.dart   # Firebase Authentication
    ├── biometric_service.dart # Biometric authentication
    ├── notification_service.dart # Local notifications
    └── sync_service.dart   # Cloud synchronization
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod 2.x
- **Local Database**: Hive
- **Cloud Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Rich Text Editor**: Flutter Quill
- **UI Components**: Material Design 3
- **Animations**: Flutter Animate, Lottie
- **Testing**: Flutter Test, Mockito

## 📦 Dependencies

### Core Dependencies
- `flutter_riverpod`: State management
- `hive` & `hive_flutter`: Local database
- `firebase_core`, `firebase_auth`, `cloud_firestore`: Firebase services
- `flutter_quill`: Rich text editor
- `google_fonts`: Typography
- `lottie`: Animations

### UI & UX
- `flutter_staggered_grid_view`: Masonry layout
- `flutter_slidable`: Swipe actions
- `shimmer`: Loading animations
- `flutter_animate`: Smooth animations

### Services
- `flutter_local_notifications`: Local notifications
- `local_auth`: Biometric authentication
- `permission_handler`: Permission management
- `file_picker`: File selection
- `share_plus`: Content sharing

### Utilities
- `uuid`: Unique ID generation
- `intl`: Internationalization
- `shared_preferences`: Settings storage
- `equatable`: Value equality
- `dartz`: Functional programming

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (2.18 or higher)
- Firebase project setup
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd notes_taking_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Firebase Setup**
   - Create a Firebase project
   - Enable Authentication (Email/Password, Google)
   - Enable Firestore Database
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories

5. **Run the app**
   ```bash
   flutter run
   ```

## 🧪 Testing

Run tests with:
```bash
flutter test
```

Generate test coverage:
```bash
flutter test --coverage
```

## 📱 Screenshots

*Add screenshots of your app here*

## 🔧 Configuration

### Firebase Configuration
1. Set up Firebase project
2. Enable required services
3. Configure authentication methods
4. Set up Firestore security rules

### App Configuration
- Modify `lib/core/constants/app_constants.dart` for app-wide settings
- Update themes in `lib/core/themes/app_theme.dart`
- Configure notification channels in `lib/services/notification_service.dart`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Riverpod for state management
- All open-source contributors


**Built with ❤️ using Flutter**
