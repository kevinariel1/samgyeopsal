# Learn Korean (Hangul Baby) — UI/UX Design System Specification
**Target Stack:** Flutter (Material 3) + Dart  
**Version:** 1.0.0 (Master Global Source of Truth)  
**Style System:** Bento-Box Grid + Tactile Micro-Interactions + Minimalist Single/Two Column Flow  
**Target Domain:** EdTech Korean Language Learning Mobile App  

---

## 1. Project Context & Current Architecture

### 1.1 Tech Stack Scan
- **Framework:** Flutter (SDK `^3.12.2`, Material 3 enabled)
- **State Management & DI:** `flutter_riverpod` (`^3.4.3`)
- **Storage & State Persistence:** `shared_preferences` (`^2.5.6`)
- **Audio & Speech Engine:** `just_audio`, `sherpa_onnx` (on-device speech recognition / phonetics)
- **Design Tokens Exists in:**
  - `lib/core/constants/app_colors.dart`
  - `lib/core/constants/app_theme.dart`

### 1.2 Screen & Feature Inventory
1. **Main Shell:** `MainNavigationScreen` (4 Destinations: Journey, Guide, Practice, Profile) + `FloatingFunFactGuide` (Cat Mascot Guide).
2. **Tab 1 — Journey (`HomeScreen`):** Vertical path of units, lessons, unlock requirements, XP, level badges, and gated milestones.
3. **Tab 2 — Guide (`HangulGuideScreen`):** Interactive Hangul syllabary & character explorer, romanization, audio pronunciation, stroke guides.
4. **Tab 3 — Practice Hub (`PracticeHubScreen`):**
   - `HangulBuilderScreen` (syllable constructor: initial consonant + vowel + final batchim).
   - `SoundDetectiveScreen` (audio phonetic contrast detection, e.g. ㄱ vs ㅋ vs ㄲ).
   - `SpeedMatchScreen` (timed tile pairing).
   - `DailyFlashcardsScreen` (spaced-repetition review with `FlipCardWidget`).
   - `WritingStudioScreen` (freeform stroke drawing & canvas evaluation with `HangulTracingWidget`).
5. **Tab 4 — Profile (`ProgressScreen`):** Streak days, total XP, mastered letters, badge showcase, user stats.
6. **Auxiliary:** `LessonScreen`, `QuizScreen`, `StoryViewerWidget`.

---

## 2. Design Philosophy & Aesthetic Pillars

### 2.1 Core Pillars
1. **Distraction-Free Legibility:** High optical clarity for Korean Hangul glyphs (ㄴ, ㄱ, ㅏ, ㅗ) paired with clean Latin typography.
2. **Soft Bento-Grid Modularity:** Card layouts grouped into clean, soft-cornered modules (`border-radius: 20px - 24px`, subtle 1.5px borders, soft elevation 0–4px).
3. **Tactile Delight (Physical Response):** Buttons, tiles, and cards feel real, physical, and bouncy:
   - Scale down on press (`0.96` scale).
   - Gentle haptic feedback on successful action.
   - Clean 150–250ms bounce transitions with spring curves (`easeOutCubic` / `easeOutBack`).
4. **Dual-Theme Parity (Light / Dark):** WCAG AA 4.5:1+ contrast compliance across both warm paper cream (Light) and deep obsidian slate (Dark).
5. **No Visual Noise / Emoji Icons:** Replace generic emojis with crisp Vector Icons (`Icons.*` from Material Icons / Cupertino Icons) for UI controls.

---

## 3. Color System & Contrast Token Map

### 3.1 Primary Brand & Accent Palette (Cheerful Sky Blue Single-Tone)
| Token Name | Hex Code | Role & Usage | Contrast Ratio (Light / Dark) |
|---|---|---|---|
| `primary` | `#0EA5E9` | Cheerful Bright Sky Blue (Sky-500: Primary CTA, Active selections, Solid banners) | Standard WCAG compliant |
| `primaryContainer` | `#E0F2FE` | Soft Sky Tint (Sky-100: Active pill backgrounds, badge surfaces) | Light mode harmonious tint |
| `secondary` | `#0284C7` | Crisp Ocean Sky (Sky-600: Sound buttons, secondary controls) | High optical clarity |
| `secondaryContainer` | `#F0F9FF` | Airy Sky Tint (Sky-50: Card inner surfaces) | Light mode surface tint |
| `accentYellow` | `#38BDF8` | Bright Sunny Sky (Sky-400: Harmonious single-tone highlight) | Decorative single-tone |
| `accentPurple` | `#0369A1` | Deep Sky Accent (Sky-700: Guide bubble borders, tags) | Single-tone border accent |
| `success` | `#10B981` | Cheerful Emerald (Correct quiz state) | WCAG AA compliant |
| `error` | `#F43F5E` | Friendly Coral Rose (Incorrect feedback) | WCAG AA compliant |

### 3.2 Light & Dark Surface Specifications (Single-Tone Ratio: 60-30-10)

#### Light Mode ("Airy Sky Morning")
- **Scaffold Background:** `#F0F9FF` (Sky-50 cheerful airy background)
- **Card / Bento Surface:** `#FFFFFF` (Pure white solid raised cards)
- **Border / Divider:** `#BAE6FD` (Sky-200 soft flat border, 1.5px)
- **Text Primary:** `#0C4A6E` (Sky-900, high contrast against `#F0F9FF`)
- **Text Secondary / Muted:** `#0369A1` (Sky-700 against `#F0F9FF`)
- **Card Shadow:** `BoxShadow(color: Color(0x0A0284C7), blurRadius: 10, offset: Offset(0, 2))` (Subtle flat depth, zero glass, zero gradients)

#### Dark Mode ("Starry Sky Study")
- **Scaffold Background:** `#082F49` (Sky-950 deep solid background)
- **Card / Bento Surface:** `#0C4A6E` (Sky-900 solid elevated container)
- **Border / Divider:** `#0369A1` (Sky-700 stroke border, 1.5px)
- **Text Primary:** `#F0F9FF` (Sky-50 text)
- **Text Secondary / Muted:** `#7DD3FC` (Sky-300 text)
- **Card Shadow:** `BoxShadow(color: Color(0x20000000), blurRadius: 12, offset: Offset(0, 3))`

---

## 4. Typography & Hangeul Legibility Matrix

### 4.1 Font Family Strategy
- **Korean Syllables & Glyphs:** `Noto Sans KR` (or platform native Apple SD Gothic Neo / Roboto / Nanum Square)
- **Latin Headings & Numbers:** Clean geometric rounded sans (e.g. `Baloo 2`, `Pretendard`, or Material standard with `FontWeight.w800`)

### 4.2 Type Scale
| Style Token | Size | Weight | Line Height | Purpose |
|---|---|---|---|---|
| `HangulHero` | 64sp–80sp | `FontWeight.w900` | 1.1 | Syllable workshop block (`가`, `한`), Tracing canvas target |
| `HangulTile` | 28sp–36sp | `FontWeight.w800` | 1.2 | Syllable selection chips, Grid tiles, Flashcard front |
| `displayLarge` | 32sp | `FontWeight.w900` | 1.2 | Screen titles, milestone rewards |
| `headlineMedium`| 22sp | `FontWeight.w800` | 1.3 | Bento card section headers, Unit labels |
| `titleMedium` | 16sp | `FontWeight.w700` | 1.35 | Card titles, button labels, quiz options |
| `bodyLarge` | 16sp | `FontWeight.w500` | 1.45 | Romanization, definitions, speech bubble body |
| `bodyMedium` | 14sp | `FontWeight.w500` | 1.4 | Helper explanations, secondary captions |
| `labelSmall` | 11sp | `FontWeight.w800` | 1.2 | Category badges, XP pills, uppercase tags |

---

## 5. Component Patterns & Bento-Grid Guidelines

### 5.1 Bento-Grid Cards
- **Border Radius:** `24.0` standard for large cards, `16.0` for nested sub-tiles.
- **Stroke Border:** `1.5px` border (`lightCardBorder` / `darkCardBorder`).
- **Internal Padding:** `16dp` to `20dp`.
- **Card Spacing / Grid Gap:** `14dp` to `16dp`.
- **Elevation:** Flat `elevation: 0` with subtle `BoxShadow` to prevent harsh material elevation clashes.

### 5.2 Tactile Buttons & Interactive Tiles
- **Standard Button Height:** `54dp` with `20dp` rounded corners.
- **Micro-Interaction (Press State):**
  - Instant tactile feedback using `Transform.scale(scale: isPressed ? 0.96 : 1.0)`.
  - Animation duration: `100ms - 150ms` on release (`Curves.easeOutBack`).
- **Tactile 3D Button Style (Optional Gamified Buttons):**
  - Bottom border / bevel shadow: `4px` darker solid offset (`Offset(0, 4)`).
  - On active press: translates down by `3px` with shadow flattening to `1px`.

### 5.3 Character Guide & Mascot (`FloatingFunFactGuide`)
- **States:**
  - **Greeting (`MascotGuideState.greeting`):** `mascot_cat_idle_clean.png` + Welcome bubble + Dark spotlight veil.
  - **Peeking (`MascotGuideState.peeking`):** `mascot_cat_peeking_clean.png` flush against the right screen edge (`right: -6`), no veil, no bubble.
  - **Speaking (`MascotGuideState.speaking`):** `mascot_cat_tapping_clean.png` (`right: 12`) + Spotlight dark veil + Fun fact chat bubble.
- **Spotlight Veil:** `Colors.black.withOpacity(isDark ? 0.62 : 0.48)`. Dismissable on tap anywhere.

---

## 6. Implementation Checklist & Anti-Patterns

### 6.1 Must-Have (Best Practices)
- [ ] Korean characters must always have ample vertical line-height (`1.2` to `1.4`) to prevent diacritic/vowel clipping.
- [ ] Touch targets must be at least `48x48dp` (Material Accessibility standard).
- [ ] Sound/Audio buttons must always provide active playback indication (e.g. animated pulse ring or wave icon).
- [ ] Use vector icons (`Icon(Icons.*)`) instead of raw text emojis for interactive navigation buttons.

### 6.2 Anti-Patterns to Avoid
- **Cluttered Canvas:** Do not cram romanization, IPA, translations, and stroke numbers into one small card simultaneously. Progressive disclosure (e.g. flip card or modal) is required.
- **Harsh Grayscale Dark Mode:** Avoid pure black `#000000` for surface cards; use deep charcoal slate `#232533` to preserve contrast and prevent eye fatigue.
- **Overly Sensitive Timers:** Critical educational content (greetings, lesson instructions) must require explicit user dismissal, not arbitrary auto-dismiss timers.
