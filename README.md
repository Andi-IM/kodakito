# KodaKito (Dicoding Story)

KodaKito is a cross-platform Flutter application designed to let users share and explore stories. It features a responsive design that adapts seamlessly to mobile, tablet, and desktop screens, providing an immersive reading and storytelling experience.

## Features

-   **Responsive UI**: Optimized layouts for different screen sizes using `window_size_classes`.
    -   **Mobile**: List view for easy scrolling.
    -   **Desktop/Web**: Grid view with a navigation rail for enhanced usability.
-   **Story Management**:
    -   View a list of stories from the community.
    -   View detailed story information with hero animations.
    -   Add new stories with image uploads.
-   **Authentication**: Secure login and registration flow.
-   **Modern Design**: Material 3 design elements with custom theming and typography.

## Tech Stack

-   **Framework**: [Flutter](https://flutter.dev/)
-   **Language**: [Dart](https://dart.dev/)
-   **State Management**: [Flutter Riverpod](https://riverpod.dev/)
-   **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
-   **Networking**: Dio (implied/standard for this type of app, or http)
-   **UI Components**:
    -   `navigation_rail_m3e` for adaptive navigation.
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
    Create a `.env` file in the root directory and add the following variables:
    ```env
    STORY_URL=https://story-api.dicoding.dev/v1
    STORY_ENV=production
    TEST_EMAIL=test@example.com 
    TEST_PASSWORD=password 
    ```
    *Note: `TEST_EMAIL` and `TEST_PASSWORD` are used for integration tests.*

4.  **Generate Code**:
    This project uses code generation for Riverpod, JSON serialization, and GoRouter. You must run the build runner to generate the necessary `.g.dart` files.
    ```bash
    dart run build_runner build -d
    ```

5.  **Run the application**:
    ```bash
    flutter run
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

This project utilizes `go_router` for a robust and declarative routing system (Navigation 2.0).

-   **Router Configuration**: Defined in `lib/common/app_router.dart`, the `GoRouter` instance manages the app's navigation stack.
-   **ShellRoute**: A `ShellRoute` is used to implement a persistent bottom navigation bar (or navigation rail) that stays visible while switching between main tabs (Home, Bookmark, Profile). This ensures a smooth user experience where the main navigation context is preserved.
-   **Type-Safe Routes**: Routes are defined with clear paths and names, allowing for easy navigation using `context.go()` or `context.push()`.
-   **Deep Linking**: The URL-based navigation structure supports deep linking, making it easy to navigate to specific content directly.

### Material 3 Expressive Design

The application embraces the latest Material 3 design principles, focusing on adaptability and expression.

-   **Theming**: The app uses a custom `MaterialTheme` (generated via `palette_generator` or Material Theme Builder) with `useMaterial3: true` enabled in `lib/common/theme.dart`. This provides dynamic color schemes and modern component styling.
-   **Adaptive Navigation**:
    -   The `MainNavigation` widget (`lib/presentation/main/widgets/main_navigation.dart`) intelligently switches between navigation modes based on screen width using `window_size_classes`.
    -   **Mobile (< 600dp)**: Uses a standard `NavigationBar` at the bottom.
    -   **Tablet/Desktop (>= 600dp)**: Uses `NavigationRailM3E` (Material 3 Expressive Navigation Rail) on the side. This rail supports expanded and collapsed states, optimizing screen real estate for larger displays.
-   **Responsive Layouts**: Screens like `MainScreen` adjust their content layout (e.g., switching from `ListView` to `GridView`) based on the available width, ensuring content looks great on any device.

## State Management

This project uses **Flutter Riverpod** for state management, leveraging its compile-time safety and testability.

-   **Providers**: We use `riverpod_annotation` to generate providers, reducing boilerplate code.
-   **AsyncValue**: UI states (Loading, Error, Data) are handled gracefully using `AsyncValue`. This ensures that the UI always reflects the current state of the data, including loading spinners and error messages.
-   **Dependency Injection**: Riverpod is also used for dependency injection (DI), allowing us to easily swap implementations (e.g., for testing) by overriding providers.
-   **Ref**: The `Ref` object is used to read other providers, enabling a reactive and composable architecture.

## Project Structure

-   `lib/common`: Shared utilities, constants, and router configuration.
-   `lib/data`: Data layer including models and repositories.
-   `lib/ui`: UI layer organized by feature (main, login, etc.).
-   `lib/domain`: Business logic and entities.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.
