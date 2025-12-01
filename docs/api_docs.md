The following Markdown documentation reflects the API structure for the Dicoding Story API based on your request.

## Dicoding Story API Documentation

This API is used to share stories about Dicoding, similar to Instagram posts but specialized for the Dicoding platform.

**Base URL:** `https://story-api.dicoding.dev/v1`

### Authentication

Most endpoints require authentication using a Bearer Token obtained from the Login endpoint.
*   **Header:** `Authorization: Bearer <token>`

***

### Auth Endpoints

#### Register
Creates a new user account.

*   **URL:** `/register`
*   **Method:** `POST`
*   **Request Body:**
    *   `name` (string): User's full name
    *   `email` (string): User's email (must be unique)
    *   `password` (string): User's password (min. 8 characters)

**Response Example:**
```json
{
  "error": false,
  "message": "User Created"
}
```

#### Login
Authenticates a user and returns a token.

*   **URL:** `/login`
*   **Method:** `POST`
*   **Request Body:**
    *   `email` (string): Registered email
    *   `password` (string): User password

**Response Example:**
```json
{
  "error": false,
  "message": "success",
  "loginResult": {
    "userId": "user-yj5pc_LARC_AgK61",
    "name": "Arif Faizin",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

***

### Story Endpoints

#### Add New Story
Uploads a new story with an image and description.

*   **URL:** `/stories`
*   **Method:** `POST`
*   **Headers:**
    *   `Content-Type`: `multipart/form-data`
    *   `Authorization`: `Bearer <token>`
*   **Request Body:**
    *   `description` (string): Story description
    *   `photo` (file): Image file (max 1MB)
    *   `lat` (float, optional): Latitude
    *   `lon` (float, optional): Longitude

**Response Example:**
```json
{
  "error": false,
  "message": "success"
}
```

#### Add New Story (Guest)
Uploads a story without authentication.

*   **URL:** `/stories/guest`
*   **Method:** `POST`
*   **Request Body:**
    *   `description` (string): Story description
    *   `photo` (file): Image file (max 1MB)
    *   `lat` (float, optional): Latitude
    *   `lon` (float, optional): Longitude

**Response Example:**
```json
{
  "error": false,
  "message": "success"
}
```

#### Get All Stories
Retrieves a list of stories.

*   **URL:** `/stories`
*   **Method:** `GET`
*   **Headers:** `Authorization: Bearer <token>`
*   **Query Parameters:**
    *   `page` (int, optional): Page number
    *   `size` (int, optional): Items per page
    *   `location` (int, optional): `1` to include location data, `0` (default) to ignore.

**Response Example:**
```json
{
  "error": false,
  "message": "Stories fetched successfully",
  "listStory": [
    {
      "id": "story-FvU4u0Vp2S3PMsFg",
      "name": "Dimas",
      "description": "Lorem Ipsum",
      "photoUrl": "https://story-api.dicoding.dev/images/stories/photos-1641623658595_dummy-pic.png",
      "createdAt": "2022-01-08T06:34:18.598Z",
      "lat": -10.212,
      "lon": -16.002
    }
  ]
}
```

#### Detail Story
Retrieves detailed information for a specific story.

*   **URL:** `/stories/:id`
*   **Method:** `GET`
*   **Headers:** `Authorization: Bearer <token>`

**Response Example:**
```json
{
  "error": false,
  "message": "Story fetched successfully",
  "story": {
    "id": "story-FvU4u0Vp2S3PMsFg",
    "name": "Dimas",
    "description": "Lorem Ipsum",
    "photoUrl": "https://story-api.dicoding.dev/images/stories/photos-1641623658595_dummy-pic.png",
    "createdAt": "2022-01-08T06:34:18.598Z",
    "lat": -10.212,
    "lon": -16.002
  }
}
```

***

### Push Notification Endpoints
**VAPID Public Key:** `BCCs2eonMI-6H2ctvFaWg-UYdDv387Vno_bzUzALpB442r2lCnsHmtrx8biyPi_E-1fSGABK_Qs_GlvPoJJqxbk`

#### Subscribe
Subscribes to web push notifications.

*   **URL:** `/notifications/subscribe`
*   **Method:** `POST`
*   **Headers:**
    *   `Authorization`: `Bearer <token>`
    *   `Content-Type`: `application/json`
*   **Request Body:**
    *   `endpoint` (string)
    *   `keys` (object):
        *   `p256dh` (string)
        *   `auth` (string)

**Response Example:**
```json
{
  "error": false,
  "message": "Success to subscribe web push notification.",
  "data": {
    "id": "...",
    "endpoint": "...",
    "keys": {
      "p256dh": "...",
      "auth": "..."
    }
  }
}
```

#### Unsubscribe
Unsubscribes from web push notifications.

*   **URL:** `/notifications/subscribe`
*   **Method:** `DELETE`
*   **Headers:**
    *   `Authorization`: `Bearer <token>`
    *   `Content-Type`: `application/json`
*   **Request Body:**
    *   `endpoint` (string)

**Response Example:**
```json
{
  "error": false,
  "message": "Success to unsubscribe web push notification."
}
```

[1](https://story-api.dicoding.dev/v1/#/?id=endpoint)