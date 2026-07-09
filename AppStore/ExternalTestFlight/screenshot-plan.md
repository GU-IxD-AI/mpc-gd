# Screenshot Plan

Apple requires real screenshots. Capture these on an iPhone and iPad, then place them in the folders below.

## Required Folders
- `screenshots/iPhone-6.9/`
- `screenshots/iPad-13/`

## Recommended Capture Sizes
Use App Store Connect’s currently accepted largest device classes:
- iPhone portrait: `1242 x 2688` or `1284 x 2778`.
- iPhone landscape: `2688 x 1242` or `2778 x 1284`.
- iPad portrait: `2064 x 2752` or `2048 x 2732`.
- iPad landscape: `2752 x 2064` or `2732 x 2048`.

If using Xcode Simulator, capture with `File > Save Screen` or `xcrun simctl io booted screenshot <file>.png`.

## Required Screenshot Set
Use these filenames exactly after capture:

1. `01-opening.png`
   Opening/start screen showing Paravida branding.

2. `02-study-pack.png`
   StudyPack or game-pack page with game titles visible.

3. `03-gameplay.png`
   A game in progress with controls/score/timer visible.

4. `04-design-interface.png`
   The design/customisation interface with parameter buttons visible.

5. `05-post-game-rating.png`
   Study-mode post-game rating panel.

## External TestFlight Minimum
External TestFlight review often does not require full App Store screenshots, but adding at least the iPhone and iPad screenshots helps reviewers understand the app.

## App Previews
An App Preview is an optional short video shown on the App Store product page, separate from screenshots. It must be captured from the app itself and demonstrate real app interaction, not a generic trailer.

Common requirements:
- Video, not a still image.
- 15 to 30 seconds long.
- Device-specific dimensions matching the screenshot device class.
- Mostly in-app footage; avoid misleading compositing or UI that is not in the app.
- No TestFlight-only debug overlays, private data, or unreleased claims.

For External TestFlight, an App Preview is not needed. It is only useful for the public App Store listing.

## Capture Notes
- Use a fresh install for first-launch study flow screenshots.
- Also capture one screenshot if orange diagnostic text appears; name it `diagnostic-error.png` and include it in tester feedback.
- Do not include personal data, email addresses, or server credentials in screenshots.
