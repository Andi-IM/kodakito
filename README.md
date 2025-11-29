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

3.  **Run the application**:
    ```bash
    flutter run
    ```

## Architecture & Design

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

## Project Structure

-   `lib/common`: Shared utilities, constants, and router configuration.
-   `lib/data`: Data layer including models and repositories.
-   `lib/presentation`: UI layer organized by feature (main, login, etc.).
-   `lib/domain`: Business logic and entities (if applicable).

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.
