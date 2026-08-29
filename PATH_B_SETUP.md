# Path B Setup — Private Document Storage via Cloud Functions

This adds three Firebase Cloud Functions that relay uploads/downloads to the
private Supabase `user-documents` bucket using the **service role key**.
The Flutter app never talks to Supabase directly for this bucket, and never
holds the service role key.

## 1. Install function dependencies

```bash
cd functions
npm install
cd ..
```

## 2. Set the Supabase secrets (server-side only, never in the app)

Run these from the project root. You'll be prompted to paste each value —
get them from Supabase Dashboard → Settings → API:

```bash
firebase functions:secrets:set SUPABASE_URL
# paste: https://<your-project-ref>.supabase.co

firebase functions:secrets:set SUPABASE_SERVICE_ROLE_KEY
# paste the "service_role" secret key (NOT the anon key)
```

Verify they're set:

```bash
firebase functions:secrets:access SUPABASE_URL
firebase functions:secrets:access SUPABASE_SERVICE_ROLE_KEY
```

## 3. Deploy the functions

```bash
firebase deploy --only functions
```

This deploys three callable functions:
- `uploadDocumentFile` — uploads a file to the private bucket on behalf of
  the signed-in user.
- `getDocumentSignedUrl` — returns a 10-minute signed URL to view a
  document. Allowed for the document's owner, or any user with
  `role: 'admin'` / `role: 'mentor'` in their `users/{uid}` Firestore doc.
- `deleteDocumentFile` — deletes a document. Allowed for the owner or an
  admin.

## 4. Deploy the updated Firestore rules (if not already deployed)

The `documents` collection rules were already present and match this setup
exactly (owner + admin/mentor read, owner create, owner/admin update+delete):

```bash
firebase deploy --only firestore:rules
```

## 5. Flutter side — already wired up

- `pubspec.yaml` — added `cloud_functions` and `url_launcher`.
- `lib/features/documents/` — user-facing upload + document list screen,
  reachable via `RouteNames.documents` (`/documents`).
- `lib/admin/document_verification/` — admin review screen (approve /
  reject with reason), reachable via
  `RouteNames.adminDocumentVerification` (`/admin/document-verification`).
- Both providers (`DocumentsProvider`, `DocumentVerificationProvider`) are
  registered in `lib/app/app.dart`.

Run `flutter pub get` after pulling this, then `flutter run`.

## 6. Testing the flow

1. Sign in as a normal user, navigate to `/documents`, upload a CNIC/PDF —
   confirm it appears in the list with a "Pending review" status.
2. Check Supabase Dashboard → Storage → `user-documents` bucket — the file
   should be there under `{uid}/...`, NOT publicly listed (bucket stays
   private).
3. Sign in as a user with `role: 'admin'` in Firestore, navigate to
   `/admin/document-verification` — the uploaded document should appear.
   Tap "View" to confirm the signed URL opens the file. Tap "Verify" or
   "Reject" and confirm the status updates back on the user's screen in
   real time (Firestore stream).
4. Confirm a *non*-owner, *non*-admin user cannot fetch a signed URL for
   someone else's document (call should fail with `permission-denied`).
