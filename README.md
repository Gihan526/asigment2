# Foundly

Flutter campus lost-and-found app using Firebase Authentication, Cloud Firestore, and Firebase Storage.

The Firebase project is `mobileassigment2`. Its `(default)` Firestore database uses Standard edition in Singapore (`asia-southeast1`).

## Run

```sh
flutter pub get
flutter run
```

Restart the app completely after changing Firebase plugins; hot reload does not load native plugin changes.

## Data and access

- `users/{uid}` stores private profiles. Only the signed-in owner can access a profile.
- `items/{id}` stores found-item posts. Signed-in students can read posts, including the pickup/contact details shown in the app. Only the poster can edit, claim/unclaim, or delete a post.
- Photos remain in Firebase Storage at `lost_items/{id}_{milliseconds}.jpg`.
- New creation dates use Firestore server timestamps. The item model also reads legacy millisecond timestamps, and the profile service converts Firestore dates for the existing profile screen.

Prototype rules are in `firestore.rules`. The feed orders by `createdAt` descending, using the automatic single-field index; no composite index is needed for its current query.

```sh
firebase deploy --only firestore:rules --dry-run --project mobileassigment2
firebase deploy --only firestore:rules --project mobileassigment2
```

## Verify

```sh
flutter analyze
flutter test
flutter build apk --debug
```

The rules tests use only Node's built-in APIs and run against an isolated demo project. Firebase CLI 15 requires Java 21 or later on PATH:

```sh
firebase emulators:exec --only firestore --project demo-foundly 'node tool/firestore_rules_test.cjs'
```

The test script refuses to run unless it receives a demo project ID and emulator host. It covers profile privacy, post ownership, the feed query, edits and claimed status, required fields, types, string limits, immutable identity/dates, image paths, and unmatched paths.

## Existing data migration

The existing Realtime Database user profile was copied to Firestore with the same UID, name, email, and creation date. There were no item posts to copy. Firebase Authentication accounts and Storage files were preserved. The source Realtime Database, including its unrelated `test` node, was left intact.
