# Sela — Bible Chat (iOS)

A native **iOS 26 / SwiftUI** recreation of the "Haven – Bible Chat" app, rebranded **Sela**.
Warm serif/vellum design system, painterly artwork, full onboarding funnel, paywall,
Home / Listen / Read tabs, guided Daily Plan, AI chat (Gemini), audio Bible stories,
and a complete My Journey settings module.

> **Continuing this project?** Read **[HANDOFF.md](HANDOFF.md)** first — it documents
> exactly where development left off, the one open bug, and the verified debug tooling.

## Requirements

- Xcode 26+ (iOS 26 SDK), simulator target used throughout: **iPhone 17 Pro**
- No third-party dependencies, no SPM packages — pure SwiftUI, builds out of the box

## Build & run

Open `Bible Chat.xcodeproj`, select the *Bible Chat* scheme → iPhone 17 Pro → **⌘R**.

CLI equivalent (use a derived-data path *outside* iCloud-synced folders — Desktop is iCloud-synced
and its xattrs break codesigning):

```bash
xcodebuild -project "Bible Chat.xcodeproj" -scheme "Bible Chat" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath ~/Library/Developer/Xcode/DerivedData/Sela \
  build
```

## AI chat (Gemini) key — optional

Chat falls back to a scripted mock without a key. To enable live Gemini replies, set the
`GEMINI_API_KEY` build setting (it is injected into Info.plist as `GeminiAPIKey`), or launch
with a `GEMINI_API_KEY` env var. **No key is committed to this repo.**
Model defaults to `gemini-3.1-flash-lite` (`GeminiModel` / `GEMINI_MODEL` to override).

## App flow

`AppState.phase` routes the whole app: `onboarding → paywall → verseShare → main`.

- **Onboarding** — 5-page carousel (Apple sign-in mock), faux notification prompt,
  conversational Q&A (name, faith level, motivation, challenge), personalized prayer with
  press-and-hold recite ring, "Enter" personalization page.
- **Paywall** — $6.99/wk with free-trial toggle, faux StoreKit confirmation sheet, mock purchase.
- **Verse share** — full-bleed postcard, tap-through to the main app.
- **Main** — floating serif tab bar: **Home** (daily verse, journey streak, chat topics,
  screen-time card, recent conversations), **Listen** (library → collections → audio player
  with real bundled narration in `Bible Chat/Audio/`), **Read** (KJV reader, book/chapter/font
  pickers, verse long-press actions).
- **Daily Plan** — mood slider → devotional card → guided prayer → streak postcard.
- **My Journey** (the + button on Home) — profile, Your information, Preferences
  (Bible version carousel, language, dark mode, haptics, audio, charm picker),
  notification preferences, manage subscription, restore, help, legal, delete account.

## Debug deep-links (DEBUG builds only)

Launch env vars (set via scheme or `simctl launch` `SIMCTL_CHILD_` prefix):

| Variable | Values | Effect |
|---|---|---|
| `HAVEN_SCREEN` | `onboarding` `paywall` `verseShare` `main` `mainReview` | Boot directly into a phase with seeded profile |
| `HAVEN_TAB` | `listen` `read` | Initial tab |
| `HAVEN_MODAL` | `player` `dailyplan` `chat` `postcard` `settings` | Auto-present a modal |
| `HAVEN_SETTINGS` | `menu` `editinfo` `preferences` `bibleversion` `charm` `notifications` | Jump into a settings screen |
| `HAVEN_DARK` | `1` | Force dark mode with `HAVEN_SETTINGS` |
| `HAVEN_TAP_PLUS` | `1` | Fire the Home + button's action on appear (bug repro aid) |

Example:

```bash
xcrun simctl launch --terminate-running-process \
  booted Bible-Chat.Bible-Chat \
  SIMCTL_CHILD_HAVEN_SCREEN=main SIMCTL_CHILD_HAVEN_SETTINGS=preferences
```

## Repo layout

```
Bible Chat/            App source (all SwiftUI, one target)
  Theme.swift          Design tokens (palette, type scale, metrics)
  Components.swift     Shared views (buttons, pills, ArtworkView, BrandMark…)
  Models.swift         Value types & enums
  AppState.swift       Router + persisted progress (UserDefaults)
  SettingsStore.swift  Settings persistence + dark-mode scheme
  BibleData.swift      All content: verses, KJV chapters, journey, library
  Audio/               Bundled narration .m4a for the Listen player
  DebugRoute.swift     DEBUG deep-link plumbing (env vars above)
  …View.swift          One file per screen/module
SelaUITests/           XCUITest for the + button (currently red — see HANDOFF)
DesignReference/       PLAN.md, DESIGN_SYSTEM.md + curated reference screenshots
```

## Testing

```bash
xcodebuild test -project "Bible Chat.xcodeproj" -scheme "Bible Chat" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath ~/Library/Developer/Xcode/DerivedData/Sela-test
```

The single UI test (`SelaUITests/PlusButtonUITests.swift`) reproduces the one open bug —
see [HANDOFF.md](HANDOFF.md#the-one-open-bug).
