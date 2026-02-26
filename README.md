# GuardianRoute

GuardianRoute is a high-reliability mobile application built using Flutter that continuously tracks and logs user location data, even in the background. The application persists location data locally and provides an intuitive UI for users to manage, view, and navigate their tracking history.

## Architecture Overview
The application follows **Clean Architecture** principles to separate concerns and ensure maintainability:
- **UI Layer**: Composed of Flutter widgets (`MainScreen`, `HomeScreen`, `HistoryScreen`, `MapRouteScreen`) that are strictly responsible for presenting data and handling user interactions.
- **Business Logic Layer**: Managed via **Riverpod** providers (`trackingStateProvider`, `historyLogsProvider`, `routePointsProvider`, etc.). This layer fetches data from the Data Later and pushes state updates to the UI smoothly.
- **Services Layer**: Background execution components (`FlutterBackgroundService`) handles platform-specific continuous tracking tasks.
- **Data Layer**: The `LocationRepository` uses an **Isar** NoSQL database for fast, offline, and reliable local data persistence.

## Packages Used
- **flutter_riverpod**: For robust, scalable state management with compile-time safety.
- **isar & isar_flutter_libs**: A high-performance local NoSQL database used for saving location point records efficiently.
- **geolocator**: To access the device's native GPS capabilities securely.
- **flutter_background_service**: The core package used for ensuring the app's location fetching code executes independently when the app is minimized, locked, or removed from recent apps.
- **google_maps_flutter**: Displays beautiful maps and route polylines inside the application.
- **url_launcher**: Used for triggering Deep Links into native external Map applications (Google Navigation or Apple Maps).
- **intl**: For robust date and time formatting in the History list.

## Background Execution Strategy
To achieve robust background location tracking (even when the app is swiped away):
1. The app registers an Android Foreground Service and iOS Background Fetch task using `flutter_background_service`.
2. Upon starting tracking, the app delegates execution to an isolated background process (`onStart`).
3. Inside this isolate, a standard Dart `Timer.periodic` triggers every 5 minutes.
4. With each tick, it pulls the current GPS coordinates using `geolocator` with `LocationAccuracy.medium` (to balance precision and battery life).
5. The coordinates, timestamp, and active Session ID are immediately mapped into a `LocationData` object and saved synchronously to the Isar database.

## Setup Instructions

### Prerequisites
- Flutter SDK `^3.5.0`
- Android Studio / Xcode

### API Keys
GuardianRoute requires a Google Maps API Key to render map polylines.
1. Create a project on the [Google Cloud Console](https://console.cloud.google.com/).
2. Enable the **Maps SDK for Android** and **Maps SDK for iOS**.
3. Generate an API Key.
4. _Android_: Insert your key into `android/app/src/main/AndroidManifest.xml` under `<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY" />`.
5. _iOS_: Provide your key in `ios/Runner/AppDelegate.swift` through `GMSServices.provideAPIKey("YOUR_KEY")`.
*(Note: A test key is provided in the repository for the Android module currently).*

### Running the App
1. Run `flutter pub get` to fetch dependencies.
2. Run `dart run build_runner build -d` to generate Riverpod and Isar bindings.
3. Run `flutter run` on a connected physical device or emulator.
