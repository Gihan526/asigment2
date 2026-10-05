# Foundly

Flutter campus lost-and-found app using Firebase Authentication, Cloud Firestore, and Cloudinary for item photos.

The Firebase project is `mobileassigment2`. Its `(default)` Firestore database uses Standard edition in Singapore (`asia-southeast1`).

## Run

```sh
flutter pub get
# Restore your local Firebase configuration first (see below).
flutter run
```

Restart the app completely after changing Firebase plugins; hot reload does not load native plugin changes.

## Local Firebase configuration and commit protection

These generated files contain API keys and must stay local:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Existing local copies are preserved. For a fresh checkout, restore all three from a trusted private copy, or regenerate them with the FlutterFire CLI for project `mobileassigment2`. `lib/firebase_options.dart.example` documents the Dart configuration with placeholder keys; copying it alone does not supply working credentials or the native configuration files. Do not force-add the ignored files.

Enable the repository's commit guard after cloning (requires Python 3):

```sh
git config --local core.hooksPath .githooks
python3 tool/check_secrets.py
```

The guard checks the staged snapshot, rejects local Firebase/environment files, and detects Google API keys and private-key headers without printing their values. It is a focused check, not a comprehensive secret scanner. GitHub Actions runs the same check on pushes and pull requests.

Removing files from tracking does not remove keys from earlier commits or resolve GitHub alerts. Review the exposed keys in Google Cloud Credentials; if rotation is needed, update all local configurations and verify the app before revoking old keys. Only resolve the alerts after reviewing restrictions or completing rotation. Firebase client API keys are public by design when restricted appropriately; data access must be protected by Firebase Security Rules. See [Firebase API key guidance](https://firebase.google.com/docs/projects/api-keys).

## Data and access

- `users/{uid}` stores private profiles. Only the signed-in owner can access a profile.
- `items/{id}` stores found-item posts. Signed-in students can read posts, including the pickup/contact details shown in the app. Only the poster can edit, claim/unclaim, or delete a post.
- New photos upload to Cloudinary using cloud `lkualbj6` and unsigned preset `foundly_images`. The preset accepts JPG, JPEG, PNG, and WebP, uses random public IDs, and stores assets in `lost_items`. The app rejects empty files and photos larger than 10 MB.
- Item records keep the Cloudinary `secure_url` in `imageUrl` and `cloudinary:<public_id>` in `storagePath`. Existing Firebase Storage photos still display, and their cleanup remains supported.
- Unsigned uploads need no API key or secret. Never add the Cloudinary API secret to the mobile app. Cloudinary photos remain in the Media Library when posts are deleted, photos are replaced, or a Firestore write fails. Permanent cleanup requires an authenticated backend with the secret and ownership checks.
- New creation dates use Firestore server timestamps. The item model also reads legacy millisecond timestamps, and the profile service converts Firestore dates for the existing profile screen.

Prototype rules are in `firestore.rules`. The feed orders by `createdAt` descending, using the automatic single-field index; no composite index is needed for its current query.

```sh
npx -y firebase-tools@latest deploy --only firestore:rules --dry-run --project mobileassigment2
npx -y firebase-tools@latest deploy --only firestore:rules --project mobileassigment2
```

Deploy the updated Firestore rules before using Cloudinary uploads; they validate the Cloudinary account, public ID, HTTPS URL, and allowed image formats while preserving support for legacy photos.

## Verify

```sh
flutter analyze
flutter test
flutter build apk --debug
```

To check the real Cloudinary preset with a tiny synthetic PNG (leaves one test asset in the Media Library):

```sh
flutter test test/cloudinary_service_test.dart --dart-define=CLOUDINARY_LIVE_TEST=true
```

The rules tests use only Node's built-in APIs and run against an isolated demo project. Firebase CLI 15 requires Java 21 or later on PATH:

```sh
npx -y firebase-tools@latest emulators:exec --only firestore --project demo-foundly 'node tool/firestore_rules_test.cjs'
```

The test script refuses to run unless it receives a demo project ID and emulator host. It covers profile privacy, post ownership, the feed query, edits and claimed status, required fields, types, string limits, immutable identity/dates, image paths, and unmatched paths.

## Existing data migration

The existing Realtime Database user profile was copied to Firestore with the same UID, name, email, and creation date. There were no item posts to copy. Firebase Authentication accounts and Storage files were preserved. After verifying the migrated profile, the old Realtime Database data (including its unrelated `test` node) was deleted and its default instance was disabled. Firebase does not allow deleting the default instance itself. A private export is retained at `.firebase-backups/realtime-before-removal.json`; this directory is excluded from Git.
