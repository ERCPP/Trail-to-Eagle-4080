# API Documentation

## Overview

This API supports user authentication, session management, and data access for a Scout management platform. The system leverages JWT-based authentication, provides protected endpoints for various data entities, and performs background scraping of external data sources. All sensitive endpoints require a valid JWT token.

---

## Authentication

### POST `/login`

**Description:** Authenticates user and returns JWT access and refresh tokens. Stores or validates device information.

**Request Body:**

```json
{
  "username": "string",
  "password": "string",
  "device_identifier": "string"
}
```

**Response:**

* 200 OK: `{ "access_token": "...", "refresh_token": "..." }`
* 400 Bad Request / 401 Unauthorized / 500 Internal Error

---

### POST `/refresh`

**Description:** Issues a new access token using a valid refresh token.

**Headers:** `Authorization: Bearer <refresh_token>`

**Response:**

* 200 OK: `{ "access_token": "..." }`

---

## User Info

### GET `/whoami`

**Description:** Returns the username of the authenticated user.

**Headers:** `Authorization: Bearer <access_token>`

**Response:**

* 200 OK: `{ "logged_in_as": "username" }`

---

## Device Token Management

### POST `/update-token`

**Description:** Updates the notification token associated with a device.

**Request Body:**

```json
{
  "device_identifier": "string",
  "device_token": "string"
}
```

**Response:**

* 200 OK / 400 Bad Request / 500 Internal Error

---

## Scraping

### POST `/start-scrape`

**Description:** Initiates a background scraping task using provided session cookies.

**Request Body:**

```json
{
  "cookies": "string"
}
```

**Response:**

* 200 OK: `{ "message": "Scraping started" }`

---

## Static Image Access

### GET `/scout-image?scoutbook_id=<id>`

### GET `/mb-image?scoutbook_id=<id>`

**Description:** Returns the image of a scout or merit badge by Scoutbook ID.

**Response:**

* 200 OK: Image file
* 404 Not Found

---

## Data Retrieval Endpoints

### GET `/hidden-scout-list`

**Description:** Returns a list of hidden scouts for the user.

### GET `/pinned-scouts-list`

**Description:** Returns a list of pinned scouts.

### GET `/units`

**Description:** Returns a list of units.

### GET `/merit-badges`

**Description:** Returns all merit badges.

### GET `/scout-list`

**Description:** Returns a preview of scouts with merit badges and rank advancements.

### GET `/scout?scout_id=<id>`

**Description:** Returns detailed information for a specific scout.

**Response Format:**
Each endpoint returns a list or single JSON object containing the relevant structured data.

---

## Data Update

### POST `/update-birthday`

**Description:** Updates a scout's birthday.

**Request Body:**

```json
{
  "scout_id": "integer",
  "birthday": "YYYY-MM-DD"
}
```

**Response:**

* 200 OK / 400 Bad Request / 500 Internal Error

---

## Version Info

### GET `/version`

**Description:** Returns current API version.

**Response:**

```json
{ "version": "0.1.0" }
```

---

## Security

* JWT tokens are required for all protected endpoints.
* HTTPS enforced via Flask-Talisman.
* Device verification enhances authentication security.
