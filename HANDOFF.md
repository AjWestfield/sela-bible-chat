# HANDOFF — where development left off

_Last updated: July 6, 2026 (evening)_

This doc is the single source of truth for continuing the project. Read top-to-bottom;
it's ~5 minutes and will save you hours.

## TL;DR status

| Area | State |
|---|---|
| Full app (onboarding → paywall → verse share → main, all tabs, Daily Plan, Chat, Read, Listen, My Journey settings) | ✅ Built, builds clean, visually verified against the reference recordings |
| **Home + button opens My Journey on tap** | ✅ **FIXED & verified** — root cause + fix documented below |
| UI test suite (`SelaUITests`) | ✅ 4 tests, all green ×2 consecutive full runs |
| Bundled audio narration (Listen player) | ✅ 24 .m4a files in `Bible Chat/Audio/` (placeholder voice) |
| Regenerate narration with [jamiepine/voicebox](https://github.com/jamiepine/voicebox) | 🔨 IN PROGRESS — Docker container running, voice profile created, scripts written (notes below) |
| Complete functional audit | ⏳ Checklist below |
| TestFlight upload | ⏳ Not started — do **only after** the audit passes |

## The + button bug — SOLVED (read this before touching Home's layout)

**Symptom was:** the + button (top-right of Home) rendered but taps never fired its action.

**Root cause (two stacked problems):**

1. **Stale-app confusion (process bug):** the project's bundle ID was changed to
   `com.lmgaj.sela`, but an old July-1 build remained installed under the old id
   `Bible-Chat.Bible-Chat`. Every `simctl launch` with the old id ran a 5-day-old binary —
   which is what the "broken button" reports were actually exercising. If a fix "doesn't
   take," check you're launching `com.lmgaj.sela`.
2. **The real code bug (iOS 26):** interactive views placed at the very top of a
   `ScrollView`'s content sit under the navigation/scroll-edge region, and their taps are
   silently intercepted — deterministically. Buttons lower in the scroll (Interpret, Begin)
   were never affected; safe-area-inset content (the tab bar) was never affected.

**The fix (in `HomeView.swift`):** the header (brand mark + the + button) moved OUT of the
scroll content into `.safeAreaInset(edge: .top)`. Do not move it back inside the ScrollView.
Additionally `MainTabView` now presents Journey/Daily-Plan **directly** from
`app.presentedModal` via a computed binding (no mirror `@State`), and
`AppState.present(_:)` nil-then-sets defensively so a presentation dropped mid-dismissal
can never wedge the state machine.

**Verified by:** `SelaUITests/PlusButtonUITests.swift` — real synthesized taps:
open, and close-then-reopen, both green across two consecutive full-suite runs.
Note for test authors: use the suite's `settleAndTap()` helper — Home re-lays-out shortly
after launch and plain `tap()` can race it.

## Functional audit checklist (resume here)

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

## Voicebox narration (in progress)

Goal: replace the placeholder narration voice with locally-generated TTS using
**jamiepine/voicebox**, cloned from the reference video's calm male narrator.

State so far (all reproducible):

- voicebox runs via **Docker** (`docker compose up -d --build` in a fresh clone).
  ⚠ Upstream bug: `.dockerignore` excludes `scripts/` but the Dockerfile COPYs
  `scripts/rocm-entrypoint.sh` — add `!scripts/rocm-entrypoint.sh` under it before building.
  API lands on `http://127.0.0.1:17600` (compose maps 17600→17493). CPU-only is fine.
- Voice profile created via `POST /profiles` (name "Sela Narrator"). Voice cloning needs a
  sample + transcript: `POST /profiles/{id}/samples` (multipart `file` + `reference_text`).
- Narrator sample extraction: the reference recording
  (`~/Downloads/ScreenRecording_07-01-2026 00-11-38_1.MP4`, 7m06s) has clean narration at
  ≈35–80s. `ffmpeg -ss 40 -t 30 -i ref.wav -ac 1 -ar 24000 narrator_sample.wav`.
  Transcribe it with voicebox's own `POST /transcribe` (Whisper model downloads on first call).
- Generation: `POST /generate {profile_id, text}` → `GET /audio/{generation_id}`.
  Texts ≤5000 chars; the app's stories are all under that.
- **Real narration scripts written for all 20 placeholder stories** (the `story()` factory in
  `BibleData.swift` used a generic 3-line template). The scripts live in this repo's history /
  BibleData once merged — style matches the existing Creation story (calm devotional,
  10–14 sentences). Update each story's `narration:` array so karaoke lines match the audio,
  and set `durationSeconds` from the real audio length.
- Output → replace matching files in `Bible Chat/Audio/` (filenames = snake_cased story
  titles). Keep .m4a: `ffmpeg -i in.wav -c:a aac -b:a 96k out.m4a`. `AudioPlayerView`
  needs no code changes.

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
