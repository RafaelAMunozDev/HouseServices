# HouseServices setup

**English** · [Español](SETUP.es.md)

This document explains how to configure and start MySQL + the backend (Docker). Everything is preconfigured to make bringing up the infrastructure as easy as possible.
The end of this document also covers the files the app (frontend) needs in order to start without problems.

---

## Requirements
- Docker + Docker Compose
- (optional) Java 17 if you run the backend without Docker
- Flutter if you run the app
- **Important:** the **AUTH**, **STORAGE** and **FIRESTORE** services must be enabled in the console of the Firebase project you are going to use, with their rules configured; otherwise those services will not work.

---

## 1) Run with Docker (MySQL + backend)

### 1.1 Environment variables
The `infra/.env` file defines the variables used by `infra/docker-compose.yml`.

1. Create the local file from the example:
   - `cp infra/.env.example infra/.env`

2. Edit `infra/.env` and fill in the values. They are used for some internal settings when the infrastructure starts (MySQL database, backend port, Firebase JSON...).

3. What each variable is for:

### MYSQL_PORT
Port on your machine/server where MySQL is exposed.
E.g. 3306. If MySQL is already running on the server, you can use another one (e.g. 3307).

### MYSQL_DATABASE
Name of the database created when the container starts.
E.g. houseservices.

### MYSQL_USER / MYSQL_PASSWORD
User and password the backend uses to connect to MySQL.

### MYSQL_ROOT_PASSWORD
Password of the MySQL root user (for admin/debugging tasks).

### BACKEND_PORT
Port on your machine/server where the backend is exposed.
E.g. 8080.

### FIREBASE_STORAGE_BUCKET
The project's Firebase Storage bucket (the backend uses it to upload and read files).
It must match the project in `firebase-service-account.json`. You can find it in the Firebase console, since it is the main name, and it usually looks like:
`project-name.appspot.com` or `project-name.firebasestorage.app`.

### 1.2 Required files (secrets)
For the backend to start with Docker, these local files are expected:

- `infra/secrets/application.properties`
- `infra/secrets/firebase-service-account.json`

If the folder does not exist, create it:
- `mkdir -p infra/secrets`

#### Available templates
The example templates are in the backend, at these paths:

- `backend/src/main/resources/application.properties.example`
- `backend/src/main/resources/firebase-service-account.example.json`

You can use them as a starting point:

- `cp backend/src/main/resources/application.properties.example infra/secrets/application.properties`
- `cp backend/src/main/resources/firebase-service-account.example.json infra/secrets/firebase-service-account.json`

`application.properties` is the configuration file for the MySQL connection, and `firebase-service-account.json` must be replaced with the real Admin SDK JSON downloaded from Firebase.

#### Important (Docker): MySQL host (application.properties)
This affects the backend's database configuration, specifically:

- `spring.datasource.url` (inside `application.properties`)

When the backend runs inside Docker, `localhost` points to the backend container itself (not to the MySQL container).
That is why, in Docker, the host must be the name of the MySQL service defined in `infra/docker-compose.yml`:

- service: `mysql`
- correct host: `mysql`

Example for Docker (in `infra/secrets/application.properties`):

- `spring.datasource.url=jdbc:mysql://mysql:3306/houseservices`

When running locally without Docker it would normally be:

- `spring.datasource.url=jdbc:mysql://localhost:3306/houseservices`

### 1.3 Run
- `cd infra`
- `docker compose --env-file .env up -d --build`

Services:
- MySQL: `localhost:${MYSQL_PORT}`
- Backend: `http://localhost:${BACKEND_PORT}`

### 1.4 Backend Dockerfile
The backend container is built from `backend/Dockerfile`, because `infra/docker-compose.yml` uses:

- `build: ../backend`

---

## 2) Frontend (Flutter)

### 2.1 Required files

The Flutter app needs 2 configuration files to work with Firebase.

The Firebase configuration for Android, downloaded from the Firebase console:

- `frontend/android/app/google-services.json`

A file generated for Flutter (Firebase options per platform), usually created with FlutterFire (for example, with `flutterfire configure`):

- `frontend/lib/config/firebase_options.dart`

If you do not use any command to generate `firebase_options.dart`, you can start from the example file listed below. You only need to replace the values for the platform you want to run the app on (web, iOS or Android) with the real ones.

The repository includes example templates:

- `frontend/android/app/google-services.example.json`
- `frontend/lib/config/firebase_options.example.dart`

Once you have the real configuration, the files must exist with these names:

- `frontend/android/app/google-services.json`
- `frontend/lib/config/firebase_options.dart`

Finally, and very importantly, you need to create a file with the Google Maps API key, because the app uses a map that calls that API. To do so, create the following file:

- `frontend/android/app/src/main/res/values/google_maps_api.xml`

With content like this, inserting your API key:

```xml
<resources>
    <string name="google_maps_key" translatable="false">
        YOUR_GOOGLE_MAPS_API_KEY
    </string>
</resources>
```

---

### 2.2 Running the app (frontend)

To run the app (with Flutter installed), run the following commands:
- `cd frontend` (if you are not already in the frontend folder)
- `flutter pub get`

Finally, the Flutter app gets the backend URL from an environment variable defined at run time. That is why you must start the app passing the backend URL with `--dart-define`:

`flutter run --dart-define=URL_BASE={BACKEND_URL}/api`

As an alternative to the command above, you can change the URL that points to the backend in `frontend\lib\services\ApiService.dart`, specifically on this line:

- `defaultValue: 'http://10.0.2.2:8080/api'`

## Additional information

This information is useful if you want to reset or bring the infrastructure up again.

1) Reset the database (re-run the init SQL)

The initialization scripts are in:
- `infra/db/init/`

To reset from scratch:

- `cd infra`
- `docker compose down -v`
- `docker compose --env-file .env up -d --build`

---

2) Backend without Docker (local)

When running locally, the backend expects the files inside resources:

- `backend/src/main/resources/application.properties`
- `backend/src/main/resources/firebase-service-account.json`

You can create them from the examples:

- `cp backend/src/main/resources/application.properties.example backend/src/main/resources/application.properties`
- `cp backend/src/main/resources/firebase-service-account.example.json backend/src/main/resources/firebase-service-account.json`

Run:
- `cd backend`
- `./gradlew bootRun`
