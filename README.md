# KodaKito (Dicoding Story)

KodaKito is a cross-platform Flutter application designed to let users share and explore stories. It features a responsive design that adapts seamlessly to mobile, tablet, and desktop screens, providing an immersive reading and storytelling experience.

## Features

-   **Responsive UI**: Optimized layouts for different screen sizes using `window_size_classes`.
    -   **Mobile**: List view with pull-to-refresh for easy scrolling.
    -   **Desktop/Web**: Grid view for enhanced usability.
-   **Story Management**:
    -   View a list of stories from the community with infinite scroll pagination.
    -   View detailed story information with dynamic color schemes extracted from images.
    -   Add new stories with image uploads and optional location tagging.
-   **Location Features** (Pro version):
    -   Pick story location using Google Maps integration.
    -   View story locations on interactive maps.
    -   Geocoding to display city/country names.
-   **Authentication**: Secure login and registration flow.
-   **Modern Design**: Material 3 design elements with custom theming and typography.

## Tech Stack

-   **Framework**: [Flutter](https://flutter.dev/)
-   **Language**: [Dart](https://dart.dev/)
-   **State Management**: [Flutter Riverpod](https://riverpod.dev/)
-   **Navigation**: [GoRouter](https://pub.dev/packages/go_router) with `go_router_builder`
-   **Networking**: [Dio](https://pub.dev/packages/dio)
-   **Maps**: [google_maps_flutter](https://pub.dev/packages/google_maps_flutter)
-   **Image Picking**: [insta_assets_picker](https://pub.dev/packages/insta_assets_picker), [wechat_camera_kit](https://pub.dev/packages/wechat_camera_kit)
-   **UI Components**:
    -   `m3e_collection` for Material 3 Expressive components.
    -   `window_size_classes` for responsive breakpoints.
    -   `palette_generator` for dynamic color schemes.
    -   `google_fonts` for typography.

## Getting Started

To run this project locally, follow these steps:

### Prerequisites

-   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
-   An IDE (VS Code, Android Studio, or IntelliJ) with Flutter plugins.

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/dicoding_story.git
    cd dicoding_story
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Configure Environment Variables**:
    
    **For Flutter (Dart):**
    Environment variables are passed at build time using `--dart-define`. The main variable is:
    - `APP_URL`: The API base URL (default: `https://story-api.dicoding.dev/v1`)
    
    **For Android (Google Maps API Key):**
    Create a `env/keys.json` file in the project root:
    ```json
    {
        "APP_URL": "https://story-api.dicoding.dev/v1",
        "MAPS_APIKEY": "your-google-maps-api-key"
    }
    ```
    > **Note**: The `env/keys.json` file is gitignored for security.

4.  **Generate Code**:
    This project uses code generation for Riverpod, JSON serialization, and GoRouter. You must run the build runner to generate the necessary `.g.dart` files.
    ```bash
    dart run build_runner build -d
    ```

5.  **Run the application**:
    ```bash
    # Development flavor
    flutter run --flavor dev --dart-define-from-file=env/keys.json

    # Production flavor
    flutter run --flavor prod --dart-define-from-file=env/keys.json
    ```

## Architecture & Design

### Clean Architecture

This project has been refactored to follow **Clean Architecture** principles, ensuring separation of concerns, scalability, and testability. The project structure is divided into three main layers:

1.  **Domain Layer** (`lib/domain`):
    -   Contains the core business logic and entities.
    -   Defines abstract repositories (interfaces) that the data layer must implement.
    -   **Impact on Understanding**: This layer is pure Dart and has no dependencies on Flutter or external data sources. It represents *what* the app does, independent of *how* it does it.

2.  **Data Layer** (`lib/data`):
    -   Responsible for data retrieval and storage (API calls, local database).
    -   Implements the repositories defined in the domain layer.
    -   **Impact on Understanding**: This layer handles the "dirty work" of talking to the outside world. It converts raw data (JSON) into domain entities.

3.  **Presentation Layer** (`lib/ui`):
    -   Contains the UI code (Widgets) and State Management (Riverpod Providers).
    -   Depends on the Domain layer to execute business logic.
    -   **Impact on Understanding**: This is where the user interacts with the application. It observes state changes and rebuilds the UI accordingly.

### Navigation 2.0 with GoRouter

This project utilizes `go_router` with `go_router_builder` for type-safe, declarative routing (Navigation 2.0).

-   **Router Configuration**: Defined in `lib/common/routing/app_router/go_router_builder.dart`, the `GoRouter` instance manages the app's navigation stack.
-   **Type-Safe Routes**: Routes are generated using `go_router_builder`, providing compile-time safety for route parameters.
-   **Dialog Routes**: Custom `DialogPage` implementation for showing dialogs as routes.
-   **Deep Linking**: The URL-based navigation structure supports deep linking, making it easy to navigate to specific content directly.

### Material 3 Expressive Design

The application embraces the latest Material 3 design principles, focusing on adaptability and expression.

-   **Theming**: The app uses a custom `MaterialTheme` with `useMaterial3: true` enabled. Dynamic color schemes are extracted from story images using `palette_generator`.
-   **Responsive Layouts**: Screens like `HomeScreen` adjust their content layout (e.g., switching from `ListView` to `GridView`) based on the available width, ensuring content looks great on any device.

## State Management

This project uses **Flutter Riverpod** for state management, leveraging its compile-time safety and testability.

-   **Providers**: We use `riverpod_annotation` to generate providers, reducing boilerplate code.
-   **AsyncValue**: UI states (Loading, Error, Data) are handled gracefully using `AsyncValue`. This ensures that the UI always reflects the current state of the data, including loading spinners and error messages.
-   **Dependency Injection**: Riverpod is also used for dependency injection (DI), allowing us to easily swap implementations (e.g., for testing) by overriding providers.
-   **Ref**: The `Ref` object is used to read other providers, enabling a reactive and composable architecture.

## Logging

The application uses the `logging` package with a custom `LogMixin` for comprehensive debugging:

-   **View Models**: All Riverpod notifiers log state changes, API calls, and errors.
-   **Page Widgets**: UI components log lifecycle events (init, dispose), user actions, and navigation.
-   **Routing**: All route transitions are logged with route names and parameters.

Log messages follow this pattern:
- `INFO`: Normal operations (navigation, successful API calls)
- `WARNING`: Recoverable errors (failed API calls, validation errors)
- `SEVERE`: Critical errors (authentication failures, cache errors)

## Project Structure

```
lib/
├── app/              # App configuration and environment
├── common/           # Shared utilities, constants, and router configuration
│   └── routing/      # GoRouter configuration and route definitions
├── data/             # Data layer
│   └── services/     # API, cache, and platform services
├── domain/           # Business logic and entities
│   ├── models/       # Domain models (Story, Cache, etc.)
│   └── repository/   # Repository interfaces
├── ui/               # Presentation layer (organized by feature)
│   ├── auth/         # Login and registration screens
│   ├── detail/       # Story detail screens (free and pro)
│   └── home/         # Home screen and add story widgets
└── utils/            # Utility classes (logger_mixin, etc.)
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

