# Integration Test Cases

This document describes all integration test cases found in the `/integration_test` folder for the Dicoding Story application.

## Overview

The integration tests are organized into two main configurations:
- **Local Data Tests** - Run against mock/fake data sources
- **Remote Data Tests** - Run against the production API

### Test Architecture

The tests use the **Robot Pattern** for better readability and maintainability:
- `robot/` - Contains robot classes that encapsulate UI interactions
- `fake/` - Contains fake implementations for testing

---

## Local Data Tests (`app_local_data_test.dart`)

Tests that run with `AppEnvironment.development` configuration.

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

Tests that run with `AppEnvironment.production` configuration against the actual API.

> **Note:** Requires `.env` file with `TEST_EMAIL` and `TEST_PASSWORD` variables.

### TC-R01: App Load Test
| Field | Value |
|-------|-------|
| **ID** | TC-R01 |
| **Name** | should load app |
| **Description** | Verifies the app can load with production config |
| **Preconditions** | None |
| **Steps** | 1. Launch app with production environment |
| **Expected Result** | App loads without errors |

### TC-R02: Login Flow (Remote)
| Field | Value |
|-------|-------|
| **ID** | TC-R02 |
| **Name** | Login flow - user can login and navigate to main page |
| **Description** | Tests login against remote API |
| **Preconditions** | Valid credentials in `.env` file |
| **Steps** | 1. Enter email from `TEST_EMAIL`<br>2. Enter password from `TEST_PASSWORD`<br>3. Tap login button |
| **Expected Result** | User receives token and navigates to main page |

### TC-R03: View Story Flow (Remote)
| Field | Value |
|-------|-------|
| **ID** | TC-R03 |
| **Name** | View Story - user can view story and navigate to detail page |
| **Description** | Tests viewing stories from remote API |
| **Preconditions** | User is authenticated with valid token |
| **Steps** | 1. Verify page is loading<br>2. Verify story cards are displayed<br>3. Tap on first story card |
| **Expected Result** | Story detail page displays actual story from API |

---

## Patrol Tests (`patrol_add_story_test.dart`)

Native integration tests using the Patrol testing framework for real device testing.

### TC-P01: Add Story (Patrol)
| Field | Value |
|-------|-------|
| **ID** | TC-P01 |
| **Name** | Add story |
| **Description** | Full end-to-end add story test with native permission handling |
| **Preconditions** | Valid credentials in `.env` file |
| **Steps** | 1. Enter email and password<br>2. Tap login button<br>3. Verify login success<br>4. Tap add story button<br>5. Grant permission when visible<br>6. Select image from gallery<br>7. Fill description with random text<br>8. Tap post button |
| **Expected Result** | Story is posted and visible in story list |

---

## Robot Classes

| Robot | Responsibility |
|-------|----------------|
| `LoginRobot` | Login page interactions |
| `LogoutRobot` | Logout flow interactions |
| `RegisterRobot` | Registration page interactions |
| `ViewStoryRobot` | Story list and detail interactions |
| `AddStoryRobot` | Add story flow interactions |
| `PatrolAddStoryRobot` | Patrol-specific add story interactions with native features |

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

### Patrol Tests
```bash
patrol test integration_test/patrol_add_story_test.dart
```
