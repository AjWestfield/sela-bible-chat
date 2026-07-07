# Haven — Bible Chat · Recreation Plan

Native **SwiftUI (iOS 26)** recreation of the *Haven – Bible Chat* iPhone app
(App Store: "Daily Guidance, Study & Prayer", developer **E12 Holdings**),
reverse-engineered from a 7-minute screen recording.

Everything is reachable from `ContentView` (the root router). No storyboards.

---

## 1. Source analysis

- Recording: `ScreenRecording_07-01-2026 00-11-38_1.MP4` — 1290×2796, 60 fps, 426 s.
- **55 full-res reference frames** → `DesignReference/screens_fullres/` (one per distinct screen).
- **8 contact sheets** (timestamped, 2 s cadence) → `DesignReference/contact_sheets/`.

## 2. Complete screen inventory (in flow order)

### A. Onboarding  (video 0:12 – 3:02)
| # | Screen | Key elements |
|---|--------|--------------|
| A0 | Launch splash | Gold cross-in-hands over cream |
| A1 | Marketing carousel (5 pages) | "Welcome to Haven", "Join 1 million Christians ★4.9/18k", "Read the bible with guidance", "Add a daily verse to your lock screen", "Get personalized biblical advice" + phone mockups; footer **Continue with Apple** / *Continue without signing in* + Terms/Privacy |
| A2 | Notification permission | "Spiritual discipline, made easier" + faux iOS "Haven Would Like to Send You Notifications" alert w/ arrow → Allow |
| A3 | Conversational intro | Blue-sky bg, typewriter: "Welcome, friend! I'm Haven, your spiritual companion." |
| A4 | Name capture | "What can I call you?" → first-name field |
| A5 | Greeting | "It's nice to meet you, {name}! Thank you for being here." + "I have a few questions… completely confidential." |
| A6 | Q1 Faith relationship | 4 options (curious / believe-not-active / practicing / central) → tailored reply |
| A7 | Q2 Motivation | 5 options (meaning / hard time / curious / admire someone / something missing) → tailored reply |
| A8 | Q3 Challenge (free text) | "What are your biggest challenges…" → empathetic reply referencing the answer |
| A9 | Personalized prayer | "A Prayer for {name}" full paragraph → **TAP TO RECITE** → tap-and-hold ring → "Amen." |
| A10 | Personalization complete | Cream + gold cross, "…transformative journey… Are you ready to begin?" → **Enter Haven** |

### B. Paywall + purchase  (video 2:30 – 3:06)
| # | Screen | Key elements |
|---|--------|--------------|
| B1 | Paywall sheet | Cream sheet, gold cross + italic *Psalm 56:3*, "Dear {name}," "unlocked a FREE week", "Notify me before my trial ends" toggle, **Start free trial →**, "7-day free trial then $6.99 per week", Terms/Privacy/Restore |
| B2 | StoreKit confirm | Faux App-Store sheet, "Double Click to Subscribe" → Processing |
| B3 | Success | "You're all set. Your purchase was successful." |
| B4 | Verse share | Meadow painting, "Jesus Christ is the same yesterday and today and forever / HEBREWS 13:8", **Share to story** + "tap anywhere to continue" |

### C. Main app — Tab bar: **Home · Listen · Read**  (video 3:12 +)
- **Home** — Daily Verse card (Interpret/Share) · Today's journey (streak pill, weekday strip, days-until-next-stop, Begin/Review) · Chat with Haven (horizontal topic cards) · Manage screen time (Lock apps till you pray) · Recent conversations · docked mini-player.
- **Listen** — Library grid (Bible Stories, Stories for Men/Women, By Faith, Daily Reflections, Today in Christ) → Collection (Creation / Patriarchs / Exodus … sections) → **Audio player** (dark oil-painting bg, karaoke narration, scrubber, 1x/±10/play/queue).
- **Read** — KJV reader (Genesis 1 default), book pill + chapter pill + **Aa**; book picker (OT/NT segmented grid), chapter grid, verse long-press menu (Copy/Interpret/Share/Save/Add note + highlight swatches), bookmark + next-chapter FABs.

### D. Daily Plan  (from Home → Begin, video 5:10 +)
Conversational: welcome → mood slider ("I'm feeling…") → personalized **Daily Devotional** card (Daily Bread, 3 min, Tap to open) → devotional reading → **continue to prayer** → guided prayer (tap-and-hold recite) → **streak celebration** ("N day streak") → **postcard reward** (Garden of Eden → Mount Ararat journey map) → Continue.

### E. Chat with Haven  (video 6:24 +)
Titled conversation ("Daily Verse Jul 1"), verse-reference chips, suggested-prompt chips
("What's the core message here?" …), streaming typewriter replies, saved to Recent conversations.

## 3. Architecture

Single target, file-system-synchronized group (drop-in `.swift` files auto-compile).

```
Bible Chat/
  Bible_ChatApp.swift     – @main, injects AppState
  ContentView.swift       – root router (launch → onboarding → paywall → verseShare → main)
  Theme.swift             – colors, serif typography, metrics, sky background
  Components.swift        – ArtworkView (MeshGradient oil-paintings), buttons, chips, GoldCross,
                            StreakPill, WeekdayStrip, CircleIconButton…
  Models.swift            – AppPhase, FaithLevel, Motivation, Mood, Verse, BibleBook, JourneyStop,
                            Story, LibraryCollection, ChatMessage/Topic/Conversation, Devotional
  AppState.swift          – ObservableObject state machine + UserDefaults persistence
  BibleData.swift         – KJV (Genesis 1–3) + 66-book list + journey map + library + chat topics + devotional
  MainTabView.swift       – floating serif tab bar + docked mini-player
  Onboarding*.swift       – A1–A10 (carousel, conversation, prayer, personalized)
  PaywallView / VerseShareView.swift        – B1–B4
  HomeView / DailyPlanView / ChatView / StreakPostcardView.swift  – C-Home, D, E
  ReadView / ReadPickers.swift              – C-Read
  ListenView / ListenCollectionView / AudioPlayerView.swift       – C-Listen
```

**State machine** (`AppState.phase`): `.onboarding → .paywall → .verseShare → .main`,
persisted so a returning subscribed user launches straight into `.main`.
Progress persisted: name, faith answers, streak, journey index, completed weekdays, conversations.

## 4. Design system (see `DESIGN_SYSTEM.md`)

Warm "illuminated manuscript" aesthetic: cream paper `#F4EDE1`, espresso ink `#3A2A1C`,
dark-brown CTAs `#5B3A22`, gold accents `#D9A93E`, amber celebration `#E8A63E`,
blue-sky conversational gradient, **serif** type throughout (system New York),
impressionist oil-painting imagery (rendered via `MeshGradient` so no bundled art is required —
real paintings can be dropped into `Assets.xcassets` later and swapped into `ArtworkView`).

## 5. Fidelity notes / intentional simplifications

- **Artwork**: reproduced as procedural impressionist `MeshGradient`s keyed by scene name.
  Swap in real images later without touching layout.
- **Purchase**: StoreKit is mocked (no product IDs); the flow, sheet, and success match visually.
  Wire real StoreKit 2 products when monetizing.
- **AI chat**: replies are warm canned/templated with streaming animation (no network).
  Point `ChatView` at a real LLM endpoint later.
- **Scripture**: Genesis 1–3 bundled verbatim (KJV); other chapters show a graceful placeholder.
  Drop a full KJV JSON into the bundle to complete the reader.
- **Fonts**: system serif (New York). The original uses a similar transitional serif; a custom
  face can be bundled and mapped in `Theme` during the design-tweak pass.

## 6. Status
Foundation + router + tab shell built and compiling. Screen modules generated in parallel,
then integrated, built for iPhone 17 Pro (iOS 26.5), and screenshot-verified against the reference.
