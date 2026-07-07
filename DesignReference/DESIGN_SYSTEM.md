# Haven — Design System

Extracted from the reference recording (sampled hex values ± tweak pass).

## Palette (`Theme` in `Theme.swift`)

| Token | Hex | Use |
|-------|-----|-----|
| `paper` | `#F4EDE1` | Main warm-cream background |
| `paperDeep` | `#F1E8DA` | Reader background |
| `card` | `#FCF8F1` | Raised cards / sheets |
| `cardSoft` | `#F7F0E6` | Subtle fills, inactive day circles |
| `ink` | `#3A2A1C` | Primary serif text (espresso) |
| `inkSoft` | `#7B6A58` | Secondary text |
| `inkFaint` | `#A99A88` | Captions, inactive tab items |
| `brown` | `#5B3A22` | Primary CTA fill, active accents |
| `brownDeep` | `#432815` | Pressed / deep brown |
| `gold` | `#D9A93E` | Streak flame, active day ring, cross |
| `goldSoft` | `#E7C878` | Completed day fill |
| `goldPale` | `#EBDDB6` | Verse-ref tag background |
| `amber` | `#E8A63E` | Streak / postcard celebration background |
| `hairline` | `#E4D8C4` | Dividers, borders |
| `skyTop→skyBottom` | `#2E5F86 → #6E9DBD` | Conversational onboarding / prayer sky |

## Typography

- **Primary face:** system **serif** (New York) via `Font.haven(size, weight)`.
  The original uses a similar high-contrast transitional serif; a custom face can be bundled later.
- **UI chrome** (toggles, status): SF via `Font.havenUI`.
- Roles: `havenLargeTitle` 40/bold · `havenTitle` 34/bold · `havenHeading` 26/semibold ·
  `havenSubheading` 22/semibold · `havenBody` 19 · `havenCaption` 15 · `havenTiny` 13.

## Shape & metrics

- Corner radii: cards 22, sheets 30, pills 30, buttons 18, tiles 16.
- Screen inset: 22.
- Buttons: dark-brown filled pill (`HavenPrimaryButton`) and white pill (`HavenWhitePill`).
- Circular icon buttons (`CircleIconButton`) for nav chevrons + player controls.
- Floating white capsule tab bar; docked rounded mini-player above it.

## Imagery

Impressionist oil-painting look via `MeshGradient` (`ArtworkView(art:)`), 18 named scenes
(meadow, mountains, river, waterlilies, sunset, garden, darkCreation, goldenField, lockApps,
dawn, village, harvest, cross, forgiveness, service, stress, lifeChange, mentalHealth).
To use real paintings: add images to `Assets.xcassets` and swap the body of `ArtworkView`
to `Image(art.rawValue).resizable().scaledToFill()`.

## Signature components

- **GoldCross** — gradient gold Latin cross w/ glow (launch, paywall, personalization).
- **StreakPill** — calendar + 🔥 + count.
- **WeekdayStrip** — S M T W T F S circles, active gold ring, completed gold fill.
- **HavenChip / VerseRefTag** — cream reply bubbles / gold scripture tokens.
- **Karaoke narration** — current sentence bright, others faded (audio player).
