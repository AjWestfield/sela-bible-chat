# HANDOFF — where development left off

_Last updated: July 6, 2026_

This doc is the single source of truth for continuing the project. Read top-to-bottom;
it's ~5 minutes and will save you hours.

## TL;DR status

| Area | State |
|---|---|
| Full app (onboarding → paywall → verse share → main, all tabs, Daily Plan, Chat, Read, Listen, My Journey settings) | ✅ Built, builds clean, visually verified against the reference recordings |
| Bundled audio narration (Listen player) | ✅ 24 .m4a files in `Bible Chat/Audio/` (current voice: ElevenLabs-generated placeholder) |
| **Home + button opens My Journey on tap** | ❌ **OPEN BUG — the only known functional defect. Details below.** |
| Complete functional audit | ⏳ Not finished (blocked on the bug; checklist below) |
| Regenerate narration with [jamiepine/voicebox](https://github.com/jamiepine/voicebox) | ⏳ Repo cloned & assessed, generation not started (notes below) |
| TestFlight upload | ⏳ Not started — do **only after** the audit passes |

## The one open bug

**Symptom:** the + button (top-right of Home) renders but tapping it does not present the
My Journey sheet.

**What is PROVEN by experiment (don't re-litigate these):**

1. **The presentation chain works.** Launching with `HAVEN_TAP_PLUS=1` calls
   `app.presentJourney()` from `HomeView.onAppear` — the *exact* closure the button runs —
   and My Journey presents perfectly (fullscreen, all rows, matches reference).
2. **The button exists and is hittable.** The XCUITest finds `home-plus-button`,
   `isHittable == true`.
3. **XCUITest taps do fire actions in this app.** A control tap on the Listen tab switches
   tabs successfully in the same test run.
4. **Tapping + does nothing** — same test, `plusStillExists=true`, no sheet, no crash.
5. Things already tried that did **not** fix it:
   - Moving the journey cover to different levels of the MainTabView hierarchy
   - Consolidating multiple `fullScreenCover`s into one
   - Removing HomeView's own chat cover (restored afterwards)
   - `.toolbar(.hidden, for: .navigationBar)` on the Home scroll view (still in place)

**Repro:** `SelaUITests/PlusButtonUITests.swift` (currently red, 100% reproducible), or tap
+ by hand in the simulator.

**Where I'd look next (in order):**

1. **Is the Button action firing at all?** Add `print("PLUS TAPPED")` inside the action and
   watch `simctl spawn booted log stream`. If it prints → the bug is in state→cover plumbing
   (see #3). If it doesn't → it's gesture interception (see #2).
2. **Gesture interception over the header.** The header HStack sits under the daily-verse
   card's `.shadow(...)`; a sibling view with a large hit area (or the `ScrollView`'s
   content inset region / safe-area top) may be swallowing touches. Try `.allowsHitTesting(false)`
   on the shadow-casting decorations, or lift the + button into a `.safeAreaInset(edge: .top)` /
   overlay so nothing can sit above it.
3. **The modal binding.** `MainTabView` presents via
   `fullScreenCover(item: appModalBinding)` where `appModalBinding` wraps
   `app.presentedModal` (`AppState`, `AppModal` enum in `Models.swift`). SwiftUI sometimes
   drops `@Published`-driven `item:` covers when the binding is recreated per-render — try a
   plain `@State` mirror synced with `.onChange(of: app.presentedModal)`, or present from a
   `.sheet(isPresented:)` bool + switch.
4. As a last resort, present My Journey with `NavigationStack` push or `.overlay` instead of
   `fullScreenCover` — the reference video shows a slide-in that a push replicates fine.

**Verify the fix by:** running the UI test (it must go green), *then* a human tap in the
simulator. Do not trust "the code path works" — that was the trap that hid this bug.

## Functional audit checklist (resume here after the bug)

Walk each of these in the sim; everything below already worked visually last session:

- [ ] Fresh install → onboarding carousel (5 pages) → notification card → conversation
      (name/faith/motivation/challenge) → prayer (press-and-hold ring) → personalization → paywall
- [ ] Paywall toggle, subscribe (mock) → "You're all set." → verse share → main
- [ ] Home: Interpret → Chat opens seeded; Share (stub); Begin → Daily Plan; weekday strip
- [ ] Daily Plan: mood slider → devotional reader → recite ring → streak postcard → streak +1,
      journey advances, Review mode on Home
- [ ] Chat: topic cards, prompt chips, streaming reply (mock without key), conversation persists
      to Recent conversations
- [ ] Listen: Library grid → collection → story → player (plays bundled m4a, karaoke
      highlighting, scrubber, mini-player bar docks above tab bar)
- [ ] Read: KJV text, book picker (OT/NT), chapter grid, Aa font sheet, verse long-press menu
- [ ] **+ → My Journey** (the bug) → every row: Your information (edit name/age), Preferences
      (Bible version carousel ✓ 6 versions, language, dark mode toggles the whole app, haptics,
      audio, charm grid), Notification preferences, Manage subscription, Restore, Help, Legal,
      Delete account (confirm + reset), User ID tap-to-copy
- [ ] Dark mode pass across every screen (SettingsStore drives `preferredColorScheme`)

## Voicebox narration (not started)

Goal: replace the current placeholder narration voice with locally-generated TTS using
**jamiepine/voicebox** so the reads match the reference video's calm male narrator.

What I learned (repo was cloned to a scratchpad, clone it fresh):

- Tauri (Rust) desktop app + **Python backend** (FastAPI, port 17493) + `bun` workspaces.
  Easiest path: download the **macOS DMG** from `voicebox.sh` — full REST API included
  (`POST /generate` etc., see `docs/` + README "API" section) — instead of building from source.
- 7 TTS engines, local models (Kokoro is the lightweight/high-quality default; Qwen3-TTS or
  Chatterbox for cloning). Voice cloning works from a few seconds of reference audio —
  you can rip the narrator sample straight from the reference screen recording's audio track.
- Script texts for all 24 stories already exist in `BibleData.swift` (`narration` arrays —
  they're the karaoke lines; join them per story).
- Output → replace matching files in `Bible Chat/Audio/` (filenames = snake_cased story
  titles). Keep .m4a (AVFoundation-friendly); convert with
  `ffmpeg -i in.wav -c:a aac -b:a 96k out.m4a`. `AudioPlayerView` needs no code changes.

## TestFlight (after everything above)

- Bundle ID `Bible-Chat.Bible-Chat`, no entitlements beyond defaults, no third-party deps.
- An **asc-mcp** (App Store Connect MCP, key "Claude MCP Deploy") is configured on the owner's
  machine for upload; otherwise standard Xcode Organizer archive → upload works.
- Reminder: archive with derived data **outside** any iCloud-synced folder (Desktop is synced;
  iCloud xattrs break codesigning).

## Design references

- `DesignReference/PLAN.md` — original screen-by-screen recreation plan
- `DesignReference/DESIGN_SYSTEM.md` — extracted palette/type/spacing spec
- `DesignReference/screens/` — curated per-screen reference screenshots from the source app
- `DesignReference/plus_menu/` — reference shots for the My Journey settings module
- Source screen recordings live outside the repo (owner's `~/Downloads`, two .MP4s dated
  07-01-2026) — ask the owner if you need them.

## Conventions / gotchas

- All UI composes `Theme.*` tokens + `Font.haven*` (system serif = New York). Don't hardcode.
- Strings/branding go through `Brand` (`Brand.swift`) — the app was renamed Haven → **Sela**;
  never hardcode either name in views.
- `AppState` persists via UserDefaults with `sela.*` keys (legacy `haven.*` still read).
- iOS 26 deprecations already cleaned once: don't use `Text + Text` concatenation or
  `UIScreen.main` (use interpolation / context screen).
- `#Preview`s must inject `.environmentObject(AppState())` (+ `SettingsStore()` where used).
- ContentView is the phase router; every screen is reachable from it (owner requirement).
