# Architecture Documentation

## Overview

This project follows a **Clean Architecture** approach tailored for Flutter, ensuring separation of concerns, testability, and maintainability. It utilizes **Riverpod** for state management and dependency injection, and **GoRouter** for navigation.

## Technology Stack

-   **Language**: Dart
-   **Framework**: Flutter
-   **State Management**: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) using code generation (`riverpod_generator`).
-   **Navigation**: [go_router](https://pub.dev/packages/go_router) with [go_router_builder](https://pub.dev/packages/go_router_builder).
-   **Data Modeling**: [freezed](https://pub.dev/packages/freezed) and [json_serializable](https://pub.dev/packages/json_serializable) for immutable data classes and JSON serialization.
-   **Networking**: [dio](https://pub.dev/packages/dio).
-   **Functional Programming**: [dartz](https://pub.dev/packages/dartz) for `Either` types (Error Handling).
-   **Testing**: `flutter_test`, `integration_test`, `patrol`, `mocktail`, `faker`.
-   **UI components**: `m3e_collection` (Material 3 extensions).
-   **Maps & Location**: `google_maps_flutter`, `location`.

## Project Structure

The project is structured into layers separating the business logic from the UI and Data sources.

```text
lib/
├── app/                  # App-wide configurations, routes, and main wiring
├── common/               # Shared constants, enums, and extensions
├── data/                 # Data Layer: API calls, DTOs, Repository Implementations
│   ├── repositories/     # Concrete implementations of Domain repositories
│   ├── services/         # External data sources (API, Local Storage)
│   └── data_providers.dart # Data layer Dependency Injection
├── domain/               # Domain Layer: Business rules, Entities, Repository Interfaces
│   ├── models/           # App Entities (Freezed classes)
│   ├── repository/       # Abstract Repository Interfaces
│   └── domain_providers.dart # Domain layer Dependency Injection
├── ui/                   # Presentation Layer: Widgets, Screens, ViewModels
│   ├── auth/             # Authentication Feature
│   ├── home/             # Home/Feed Feature
│   ├── detail/           # Story Detail Feature
│   └── ...
├── l10n/                 # Localization files
├── main.dart             # Main entry point (Wiring)
└── main_*.dart           # Flavor-specific entry points (Dev, Prod, Pro)
```

## Layers

### 1. Domain Layer (`lib/domain`)
The core of the application. It is independent of other layers (UI, Data).
-   **Models**: Immutable data structures defined using `freezed`.
-   **Repositories**: Abstract classes (interfaces) defining valid operations on data.
-   **Use Cases (Optional)**: In this architecture, Repository operations are often called directly by ViewModels/Notifiers if simple, or Logic is encapsulated in Service classes.

### 2. Data Layer (`lib/data`)
Responsible for retrieving and manipulating data from external sources.
-   **Services**: Handle direct interaction with APIs (`Dio`) or Local Storage (`SharedPreferences` / `Hive`).
-   **Repositories**: Implement the interfaces defined in the Domain layer. They map DTOs (Data Transfer Objects) to Domain Entities and handle error exceptions, often returning `Either<Failure, Success>`.

### 3. Presentation Layer (`lib/ui`)
Responsible for showing data to the user and handling user interactions.
-   **Features**: Organized by feature folder (e.g., `auth`, `home`).
-   **Widgets**: UI components.
-   **State**: Managed via Riverpod Notifiers (`AsyncPartifier`, `Notifier`, `StateNotifier`).
-   **Navigation**: Declarative routing using `GoRouter`.

## State Management (Riverpod)

-   **Dependency Injection**: Providers are defined in `*_providers.dart` (e.g., `domain_providers.dart`) or using `@riverpod` annotations on classes/functions.
-   **AsyncValue**: Used extensively to handle loading/error/success states in the UI.
-   **Code Generation**: `riverpod_generator` is used to generate providers, ensuring type safety and reducing boilerplate.

## Environment Flavors

The app supports multiple environments handled by separate entry points:
-   **Development (`main_dev.dart`)**: Uses mock/local data or dev servers.
-   **Production (`main_prod.dart`)**: Connects to real production APIs.
-   **Pro (`main_pro.dart`)**: Full-featured production build (likely including paid/extra features like Location).

## Navigation

Navigation is handled by `GoRouter`.
-   Routes are strictly typed using `go_router_builder`.
-   The Router configuration is typically found in `lib/app/`.

## Testing Strategy

-   **Unit Tests**: Test individual classes, repositories (mocking data sources), and view models.
-   **Widget Tests**: Test UI components in isolation.
-   **Integration Tests**: Run flows on a simulator/emulator.
    -   `integration_test/`: Standard Flutter integration tests.
    -   `patrol_test/`: Enhanced native automation tests using **Patrol**.
