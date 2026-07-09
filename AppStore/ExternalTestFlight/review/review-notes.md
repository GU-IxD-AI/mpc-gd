# Beta App Review Notes

Paravida is an experimental game-design and playtesting app used for external testing and research preparation.

## Test Account / Access
No account login is required from the tester. On first launch, the app asks whether to join or skip the study.

Recommended review path:
1. Launch the app.
2. Choose `Join` to enter study mode, or `Skip` to use normal mode.
3. In study mode, choose a game from `StudyPack`.
4. Press Play, complete or end a game, then submit the rating form.
5. Return to the design interface, modify game parameters, and press Play again.

## Study Mode
Study mode sends interaction data to the project server. If network requests fail, data is cached locally and retried.

## Diagnostics
Orange diagnostic text may appear on screen for TestFlight builds if a recoverable error occurs. If this appears during review, please include the visible diagnostic text in the review feedback.

## Network Endpoint
The app connects to the project interaction server at `interactions.se` for study logging.

## Notes For Reviewer
The app is portrait-only and supports iPhone and iPad.
