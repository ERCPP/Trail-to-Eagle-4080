# API Documentation

This document provides detailed technical documentation for each endpoint in the API, including input parameters, authentication requirements, and returned values.

---

## Authentication

### `POST /login`

**Description**: Authenticates a user and returns JWT access and refresh tokens.

**Request Body**:

```json
{
  "username": "string",
  "password": "string",
  "device_identifier": "string"
}
```

**Response**:

```json
{
  "access_token": "JWT",
  "refresh_token": "JWT"
}
```

**Errors**:

* `400`: Missing parameters.
* `401`: Invalid credentials.
* `500`: Device info storage failure.

### `POST /refresh`

**Description**: Refreshes the JWT access token using the refresh token.

**Authentication**: Requires valid JWT refresh token.

**Response**:

```json
{
  "access_token": "JWT"
}
```

---

## User Utilities

### `GET /whoami`

**Description**: Returns the username of the currently authenticated user.

**Authentication**: JWT access token required.

**Response**:

```json
{
  "logged_in_as": "username"
}
```

---

## Session & Scraping

### `POST /start-scrape`

**Description**: Triggers a background scraping task using user session cookies.

**Request Body**:

```json
{
  "cookies": { ... }
}
```

**Authentication**: JWT access token required.

**Response**:

```json
{
  "message": "Scraping started"
}
```

**Errors**:

* `400`: Missing cookies.

---

## Device Management

### `POST /update-token`

**Description**: Updates the device token for notifications.

**Request Body**:

```json
{
  "device_identifier": "string",
  "device_token": "string"
}
```

**Authentication**: JWT access token required.

**Response**:

```json
{
  "message": "Device token updated successfully"
}
```

---

## Media Endpoints

### `GET /scout-image?scoutbook_id=ID`

### `GET /mb-image?scoutbook_id=ID`

**Description**: Retrieves image files for scouts or merit badges.

**Authentication**: JWT access token required.

**Response**: Image file.

**Errors**:

* `400`: Missing ID.
* `404`: Image not found.

---

## Data Retrieval Endpoints

### `GET /hidden-scout-list`

### `GET /pinned-scouts-list`

**Response**:

```json
[
  {
    "id": int,
    "scoutbook_id": "string",
    "first_name": "string",
    "last_name": "string",
    "unit_name": "string",
    "current_rank": "string"
  }, ...
]
```

### `GET /units`

### `GET /merit-badges`

**Response**:

```json
[
  {
    "id": int,
    "scoutbook_id": "string",
    "name": "string",
    "unit_type_id": int,
    "number": string,
    "gender": string,
    "scoutmaster_id": int,
    "active": bool,
    "eagle_required": bool
  }, ...
]
```

### `GET /scout-list`

**Response**:

```json
[
  {
    "id": int,
    "scoutbook_id": "string",
    "first_name": "string",
    "last_name": "string",
    "unit_name": "string",
    "email": "string",
    "phone": "string",
    "birthday": "YYYY-MM-DD",
    "merit_badges": [ ... ],
    "rank_advancement_events": [ ... ]
  }, ...
]
```

### `GET /scout?scout_id=ID`

**Response**:

```json
[
  {
    "id": int,
    "scoutbook_id": "string",
    "first_name": "string",
    "last_name": "string",
    "unit_name": "string",
    "email": "string",
    "phone": "string",
    "birthday": "YYYY-MM-DD",
    "merit_badges": [ ... ],
    "rank_advancement_events": [ ... ]
  }
]
```

---

## Data Modification Endpoints

### `POST /update-birthday`

**Request Body**:

```json
{
  "scout_id": int,
  "birthday": "YYYY-MM-DD"
}
```

**Response**:

```json
{
  "message": "Birthday updated successfully."
}
```

### `POST /update-hidden`

**Request Body**:

```json
{
  "scout_id": int,
  "hidden": bool
}
```

**Response**:

```json
{
  "message": "Hidden status updated successfully."
}
```

---

## Version

### `GET /version`

**Response**:

```json
{
  "version": "0.1.0"
}
```