# External TestFlight Submission Checklist

## Before Uploading Build
- Confirm bundle ID: `org.metamakers.Paravida`.
- Confirm display name: `Paravida`.
- Increment build number if uploading another build.
- Confirm version: `1.1.1` or update intentionally.
- Confirm app icon includes 1024x1024 marketing icon.
- Confirm diagnostics overlay is acceptable for TestFlight.
- Confirm study server is reachable or backlog retry behavior is acceptable.
- Confirm Privacy Policy URL is available.
- Confirm support email/address is available.

## App Store Connect
- Create/select app record for `org.metamakers.Paravida`.
- Upload build via Xcode Organizer or Transporter.
- Fill Beta App Description and What to Test from `metadata.md`.
- Add Beta App Review notes from `review/review-notes.md`.
- Add export compliance answer.
- Add App Privacy answers from `privacy-notes.md`.
- Add external tester group.
- Submit for Beta App Review.

## Screenshot Capture
- Capture iPhone screenshots into `screenshots/iPhone-6.9/`.
- Capture iPad screenshots into `screenshots/iPad-13/`.
- Use real app screens, not generated mockups.
