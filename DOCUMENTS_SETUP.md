# Documents Feature Setup — Free (Spark) Plan Version

This version does NOT use Firebase Cloud Functions, so it works entirely
on the free Spark plan — no billing account needed.

## How it works

- The `user-documents` Supabase bucket is kept non-public in the
  dashboard, but its RLS policies allow the app's anon key full
  insert/select/update/delete access (same as the public buckets).
- Every file is stored at a path like `{userId}/{timestamp}_{filename}`,
  so paths are practically unguessable even though the bucket isn't
  truly access-controlled.
- Viewing a document always uses a 10-minute signed URL
  (`getSignedUrl`), so even if a link leaks, it stops working shortly
  after.

**Trade-off:** this is NOT the same level of security as the Cloud
Functions + service-role-key version. Anyone who extracted the app's
Supabase anon key could theoretically list/read files if they guessed a
path. For an internship/student project this is a reasonable trade-off
to avoid billing. If you later upgrade to Blaze, swap
`DocumentsRepositoryImpl` and `DocumentVerificationRepositoryImpl` back
to calling Cloud Functions (`uploadDocumentFile`, `getDocumentSignedUrl`,
`deleteDocumentFile`) instead of `SupabaseStorageService` directly, for
real per-user access control.

## What changed from the Cloud Functions version

- `functions/` folder removed — not needed.
- `firebase.json` — no `functions` block.
- `pubspec.yaml` — `cloud_functions` package removed (kept
  `url_launcher`).
- `lib/features/documents/data/repositories/documents_repository_impl.dart`
  — now calls `SupabaseStorageService` (`lib/supabase/supabase_storage_service.dart`,
  already built during Path A) directly instead of Cloud Functions.
- `lib/admin/document_verification/data/repositories/document_verification_repository_impl.dart`
  — same change.
- Everything else (models, providers, screens, routes, Firestore rules)
  is unchanged from before.

## Setup

1. Run `flutter pub get`.
2. Make sure `.env` has your real `SUPABASE_URL` and `SUPABASE_ANON_KEY`
   (same ones already used for avatars/portfolio uploads in Path A).
3. Run the app. Test:
   - Upload a document from `/documents` (user side).
   - Confirm it appears in Supabase Dashboard → Storage →
     `user-documents`, under a path starting with your Firebase uid.
   - Open `/admin/document-verification` as an admin user (`role: 'admin'`
     in their Firestore `users/{uid}` doc), confirm the document shows
     up, "View" opens it, and Verify/Reject updates the status back on
     the user's screen in real time.
