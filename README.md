# Digital Shores (Ruang Pesisir)

Digital Shores is a comprehensive Flutter application designed to support coastal fishermen and seaweed farmers in Indonesia. The app provides digital solutions for managing finances, documents, weather information, and community engagement in the maritime and aquaculture sectors.

## Overview

Digital Shores (Ruang Pesisir) serves as a digital platform that helps coastal communities manage their daily activities more efficiently. The application combines modern technology with the traditional needs of fishermen and seaweed farmers, offering tools for financial tracking, document management, weather monitoring, and community networking.

## Key Features

### Core Functionality
- **Authentication System**: Phone number-based registration and login with OTP verification
- **User Management**: Profile management with occupation-specific settings
- **Multi-platform Support**: Available on Android, iOS, Web, Windows, macOS, and Linux

### Main Modules

#### 1. Financial Management (KeuanganKu)
- Track income and expenses with categorization (sales, operational costs, equipment)
- Historical transaction records with filtering capabilities
- Financial summaries and analytics
- Offline data storage with cloud synchronization

#### 2. Document Management (DokumenKu)
- Store and organize important documents (licenses, certificates, reports)
- Document categorization with custom types
- Image-based document storage
- Requirement tracking for administrative compliance

#### 3. Information Hub (Informasi)
- Latest news and updates for maritime communities
- Rich text content with images
- Category-based filtering (general, education, technology, policies)
- Admin content management system

#### 4. Weather Service (Cuaca)
- Real-time weather data integration with BMKG (Indonesian Meteorological Agency)
- Regional weather forecasts
- Marine-specific weather information
- Location-based weather selection

#### 5. Plot Management (LahanKu)
- Interactive map integration for seaweed farming plots
- Google Maps embedding for plot visualization
- Location-based plot tracking

#### 6. Community Discussion (Bincang Laut)
- WhatsApp group integration for community discussions
- Direct links to maritime community groups
- Collaborative platform for knowledge sharing

## Technical Architecture

### Framework and Structure
- **Framework**: Flutter (Cross-platform mobile development)
- **Architecture**: Clean Architecture with Repository Pattern
- **State Management**: Provider pattern
- **Navigation**: GoRouter for declarative routing

### Data Management
- **Remote Storage**: Firebase (Firestore, Storage, Authentication)
- **Local Storage**: SQLite with custom database helper
- **Caching**: Shared Preferences for user settings
- **Image Handling**: Cached network images with local fallbacks

### Key Dependencies
- **Firebase**: Core backend services (Authentication, Firestore, Storage)
- **HTTP**: Weather API integration
- **Provider**: State management across the application
- **Image Picker**: Camera and gallery access for document uploads
- **WebView**: Embedded web content for maps and external resources
- **Quill**: Rich text editor for content creation

## Project Structure

```
lib/
├── app/
│   ├── data/               # Data layer (repositories, data sources)
│   ├── domain/            # Domain layer (entities, repositories)
│   └── presentation/      # Presentation layer (pages, widgets, providers)
├── const/                 # Generated constants and resources
├── core/                  # Core utilities and configurations
├── injection_container.dart  # Dependency injection setup
├── main.dart             # Application entry point
└── router.dart           # Navigation configuration

assets/
├── images/               # Application images and illustrations
└── icons/                # Feature-specific icons

android/                  # Android-specific configurations
ios/                      # iOS-specific configurations
web/                      # Web-specific configurations
windows/                  # Windows-specific configurations
macos/                    # macOS-specific configurations
linux/                    # Linux-specific configurations
```

## Development Setup

### Prerequisites
- Flutter SDK (3.6.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project configuration

### Installation
1. Clone the repository
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add `google-services.json` for Android
   - Add `GoogleService-Info.plist` for iOS
4. Set up environment variables in `.env` file
5. Run the application:
   ```bash
   flutter run
   ```

### Build Configuration
- **Development**: Uses Firebase development environment
- **Production**: Configured for release builds with proper signing
- **Asset Generation**: Automatic asset generation using `flutter_asset_generator`

## User Types and Permissions

### Regular Users (Fishermen/Farmers)
- Access to all personal management features
- Read-only access to information and weather
- Community participation capabilities

### Admin Users (Extension Officers)
- Content creation and management privileges
- Information publishing capabilities
- User management oversight

## API Integration

### Firebase Services
- **Authentication**: Phone number verification with OTP
- **Firestore**: Real-time database for user data and content
- **Storage**: File and image storage for documents and media

### External APIs
- **BMKG Weather API**: Real-time weather data for Indonesian regions
- **Google Maps**: Interactive mapping for plot visualization

## Security and Privacy

- Phone number-based authentication with OTP verification
- Local data encryption for sensitive information
- Secure Firebase rules for data access control
- Image and document secure storage

## Localization

- Primary language: Indonesian (Bahasa Indonesia)
- Date formatting: Indonesian locale
- Cultural considerations for maritime communities

## Contributing

The application follows clean architecture principles with clear separation of concerns:
- Data sources handle external API calls and local storage
- Repositories manage data flow between sources and business logic
- Use cases encapsulate business rules
- Providers manage state and UI interactions

## License

This project is configured as a private package and is not intended for publication to pub.dev.

## Support

For technical support or community assistance, users can access the integrated help system through WhatsApp community groups within the application.
