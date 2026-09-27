# Expense Tracker

A simple Flutter expense tracker with a clean Material 3 interface and Cloud Firestore storage.

## Features

- Add, edit, and delete expenses
- Categories, date, amount, title, and optional notes
- Live expense history from Firestore
- Current-month total
- Filter history by category or exact date; clear filters
- Form validation, save progress, and error feedback
- Loading, empty, and error states

## Tech stack

- Flutter and Dart
- Firebase Core
- Cloud Firestore
- Material 3 widgets (no extra UI or state-management packages)

## Setup

1. Install Flutter and confirm `flutter doctor` reports a working toolchain.
2. Create a Firebase project in the Firebase console and enable Cloud Firestore.
3. Install the FlutterFire CLI and authenticate with Firebase:

   ```sh
   dart pub global activate flutterfire_cli
   firebase login
   ```

4. The current configuration targets the Firebase project `expense-tracker-practical-2026`. To use your own project, run `dart pub global run flutterfire_cli:flutterfire configure --project=YOUR_PROJECT_ID --platforms=android` and replace `YOUR_PROJECT_ID` with the new project ID.
5. `lib/main.dart` initializes Firebase with `DefaultFirebaseOptions.currentPlatform`. Re-run FlutterFire configuration when changing Firebase projects or adding platforms.
6. In the Firebase Console for the selected project, enable the Cloud Firestore API and create a Firestore database. Choose a location carefully because it cannot be changed later. The app reads/writes the `expenses` collection.
7. Configure Firestore security rules before use. This starter has no authentication or per-user data isolation; do not deploy open development rules or store sensitive data in a publicly accessible database.
8. Run `flutter pub get`, then `flutter run`.

## Data structure

Each document in `expenses` stores `title`, `amount`, `category`, `date` (ISO-8601 string), and optional `notes`. Documents use an auto-generated Firestore ID. The current-month total is computed from the streamed expense records on the device.

## Project structure

- `lib/app/` — app shell and theme
- `lib/features/expenses/models/` — expense data model and category choices
- `lib/features/expenses/data/` — repository contract and Firestore implementation
- `lib/features/expenses/screens/` — history dashboard and add/edit form
- `lib/features/expenses/widgets/` — reusable history row

## AI tools

GitHub Copilot was used as an AI coding assistant to help scaffold the project structure, implement and review Flutter UI/data-layer code, and update the README. All generated code should be reviewed and understood before submission.

## Verification

Run `flutter analyze` and `flutter test` from the project directory.
