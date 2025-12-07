# Integration Test Cases

This document describes all integration test cases found in the `/integration_test` folder for the Dicoding Story application.

## Overview

The integration tests are organized into three main configurations:
- **Local Data Tests** - Run against mock/fake data sources with development environment
- **Remote Data Tests** - Run against the production API with faker-generated credentials
- **Patrol Tests** - Full end-to-end native tests using Patrol framework

### Test Architecture

The tests use the **Robot Pattern** for better readability and maintainability:
- `robot/` - Contains robot classes that encapsulate UI interactions
- `fake/` - Contains fake implementations for testing

---

## Local Data Tests (`app_local_data_test.dart`)

Tests that run with `AppEnvironment.development` configuration using mock data.

### TC-L01: App Load Test
| Field | Value |
|-------|-------|
| **ID** | TC-L01 |
| **Name** | should load app |
| **Description** | Verifies the app can load successfully |
| **Preconditions** | None |
| **Steps** | 1. Launch app with development environment |
| **Expected Result** | App loads without errors |

### TC-L02: Login Flow
| Field | Value |
|-------|-------|
| **ID** | TC-L02 |
| **Name** | Login flow - user can login and navigate to main page |
| **Description** | Tests the complete login flow from login page to main page |
| **Preconditions** | User is on login page |
| **Steps** | 1. Enter email `admin@example.com`<br>2. Enter password `password`<br>3. Tap login button |
| **Expected Result** | User is navigated to main page |

### TC-L03: Logout Flow
| Field | Value |
|-------|-------|
| **ID** | TC-L03 |
| **Name** | Logout flow - user can logout and return to login page |
| **Description** | Tests the logout functionality |
| **Preconditions** | User is already authenticated (token saved) |
| **Steps** | 1. Tap avatar button<br>2. Tap logout button |
| **Expected Result** | User is returned to login page |

### TC-L04: Register Flow
| Field | Value |
|-------|-------|
| **ID** | TC-L04 |
| **Name** | Register - user can register and navigate to login page |
| **Description** | Tests user registration process |
| **Preconditions** | User is on login page |
| **Steps** | 1. Navigate to register page<br>2. Enter name `John Doe`<br>3. Enter email `john.doe@example.com`<br>4. Enter password `password`<br>5. Tap register button |
| **Expected Result** | Success snackbar shown, user navigated to login page |

### TC-L05: View Story Flow
| Field | Value |
|-------|-------|
| **ID** | TC-L05 |
| **Name** | View Story - user can view story and navigate to detail page |
| **Description** | Tests viewing story list and navigating to story detail |
| **Preconditions** | User is authenticated |
| **Steps** | 1. Verify page is loading<br>2. Verify story cards are displayed<br>3. Tap on first story card |
| **Expected Result** | Story detail page is displayed with correct story data |

### TC-L06: Add Story Flow
| Field | Value |
|-------|-------|
| **ID** | TC-L06 |
| **Name** | Add Story - user can add story and verify story is added |
| **Description** | Tests the add story functionality |
| **Preconditions** | User is authenticated, camera permission granted |
| **Steps** | 1. Grant camera permission<br>2. Tap add story button |
| **Expected Result** | Add story flow is initiated |

---

## Remote Data Tests (`app_remote_data_test.dart`)

Tests that run with `AppEnvironment.production` configuration against the actual API using faker-generated credentials.

> **Note:** Uses `faker` package to generate random test credentials for each test run.

### TC-R01: App Load Test
| Field | Value |
|-------|-------|
| **ID** | TC-R01 |
| **Name** | should load app |
| **Description** | Verifies the app can load with production config |
| **Preconditions** | None |
| **Steps** | 1. Launch app with production environment |
| **Expected Result** | App loads without errors |

### TC-R02: Register Flow (Remote)
| Field | Value |
|-------|-------|
| **ID** | TC-R02 |
| **Name** | Register - user can register and navigate to login page |
| **Description** | Tests registration against remote API with faker-generated credentials |
| **Preconditions** | User is on login page |
| **Steps** | 1. Navigate to register page<br>2. Enter faker-generated name<br>3. Enter faker-generated email<br>4. Enter faker-generated password<br>5. Tap register button |
| **Expected Result** | Success snackbar shown, user navigated to login page |

### TC-R03: Login Flow (Remote)
| Field | Value |
|-------|-------|
| **ID** | TC-R03 |
| **Name** | Login flow - user can login and navigate to main page |
| **Description** | Tests login against remote API using previously registered credentials |
| **Preconditions** | User was registered in TC-R02 |
| **Steps** | 1. Enter email (from registration)<br>2. Enter password (from registration)<br>3. Tap login button |
| **Expected Result** | User receives token and navigates to main page |

### TC-R04: View Story Flow (Remote)
| Field | Value |
|-------|-------|
| **ID** | TC-R04 |
| **Name** | View Story - user can view story and navigate to detail page |
| **Description** | Tests viewing stories from remote API |
| **Preconditions** | User is authenticated with valid token |
| **Steps** | 1. Verify page is loading<br>2. Verify story cards are displayed<br>3. Tap on first story card |
| **Expected Result** | Story detail page displays actual story from API |

---

## Patrol Tests (`patrol_integration_test.dart`)

Full end-to-end native integration test using the Patrol testing framework. This is a comprehensive test that covers the complete user journey.

### TC-P01: Full Integration Test
| Field | Value |
|-------|-------|
| **ID** | TC-P01 |
| **Name** | Integration Test |
| **Description** | Complete end-to-end test covering registration, login, add story, view story, and logout |
| **Preconditions** | App installed on device |
| **Steps** | 1. Navigate to register page<br>2. Fill registration form with faker data<br>3. Tap register button<br>4. Verify registration success<br>5. Login with registered credentials<br>6. Verify login success<br>7. Tap add story button<br>8. Grant permissions when visible<br>9. Select image from gallery<br>10. Fill description with faker sentence<br>11. Tap post button<br>12. Verify story appears in list<br>13. Tap on the new story<br>14. Verify story detail is displayed<br>15. Navigate back<br>16. Tap avatar button<br>17. Tap logout button<br>18. Verify logout success |
| **Expected Result** | All steps complete successfully, user completes full journey |

---

## Robot Classes

| Robot | Responsibility |
|-------|----------------|
| `LoginRobot` | Login page interactions |
| `LogoutRobot` | Logout flow interactions |
| `RegisterRobot` | Registration page interactions |
| `ViewStoryRobot` | Story list and detail interactions |
| `AddStoryRobot` | Add story flow interactions |
| `PatrolAddStoryRobot` | Patrol-specific interactions with native features (registration, login, add story, view story, logout) |

## Fake Implementations

| Fake Class | Purpose |
|------------|---------|
| `FakeCacheRepository` | In-memory cache for local tests |
| `FakeCacheDatasource` | In-memory cache datasource for remote tests |

---

## Running Integration Tests

### Local Data Tests
```bash
flutter test integration_test/app_local_data_test.dart
```

### Remote Data Tests
```bash
flutter test integration_test/app_remote_data_test.dart
```

### Patrol Tests (requires real device/emulator)
```bash
patrol test integration_test/patrol_integration_test.dart
```

---

## Test Dependencies

| Package | Purpose |
|---------|---------|
| `integration_test` | Flutter integration test framework |
| `patrol` | Native integration testing framework |
| `faker` | Generate random test data (names, emails, passwords, sentences) |
| `mocktail_image_network` | Mock network images in tests |
