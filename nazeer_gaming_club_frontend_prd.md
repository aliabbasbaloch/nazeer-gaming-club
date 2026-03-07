# Nazeer Gaming Club — Frontend PRD
### Production UI Redesign: 10% → 100%
**Version:** 2.0.0 | **Platform:** Flutter (iOS-first, Cupertino) | **Author:** Frontend Design Review | **Date:** 2026-02-24

---

## 1. Executive Summary

Nazeer Gaming Club is a native iOS snooker scorekeeping app built with Flutter and Riverpod. The current codebase has a solid architectural foundation — clean state management, proper theming tokens, and a functional `AppColors` design system — but the presentation layer suffers from inconsistencies: raw `CupertinoColors.systemGrey` leaking past the design token layer, hardcoded `Colors.black` in dark-mode-unaware widgets, mixed Material and Cupertino icon libraries, an undifferentiated empty-state visual language, and a home screen that tries to do too much in one scrollable column without clear visual hierarchy.

This PRD defines every change needed to bring the frontend to 100% production quality — giving Nazeer Gaming Club the premium feel of a well-crafted sports app that club members will be proud to use every session.

---

## 2. Product Context & User Profile

| Attribute | Detail |
|---|---|
| **App Name** | Nazeer Gaming Club |
| **Domain** | Snooker club score tracking |
| **Primary Users** | Club members and the game operator (Ali Abbas) |
| **Session Flow** | Create game → add players (up to 12) → tap balls to score → undo/next player → game complete |
| **Screens** | Splash, Home (game board), History, Settings |
| **Tab Structure** | 3-tab bottom bar: Game · History · Settings |
| **Data** | Hive local persistence, no network calls |
| **Target OS** | iOS (Cupertino semantics), Android is a bonus |

---

## 3. Visual Direction & Design Principles

### 3.1 Aesthetic Identity: "Green Baize Premium"

The design theme is inspired by the material reality of a snooker table — deep green baize, polished mahogany rails, and the high-contrast clarity needed to read ball positions under club lighting. This translates to a UI that is:

- **Dark-first**: The dark theme (already default-capable) becomes the hero experience. It should feel like the app *lives* under club lighting.
- **Tactile**: Buttons and ball controls must feel physically pressable. Micro-animations reinforce this.
- **High contrast, zero ambiguity**: Score numbers are the biggest thing on every game screen. Hierarchy is ruthless.
- **Warm, not cold**: Navy/teal accents replace plain iOS blue to evoke the green baize and polished cue tips.

### 3.2 Core Design Principles

1. **Clarity First** — Any player can read the scoreboard at arm's length in low lighting.
2. **One Primary Action Per State** — The currently active ball cluster or "Next Player" CTA must be unmistakable. No competing primaries.
3. **Zero Raw System Colors** — Every color in every widget references `AppColors` tokens. No `CupertinoColors.systemBlue`, `CupertinoColors.black`, or `Colors.grey` anywhere in UI code.
4. **Consistent Touch Targets** — Minimum 44×44 pt for all interactive elements per Apple HIG.
5. **Delightful but Not Distracting** — Animations serve function (confirm an action, guide attention) and complete in under 300ms.
6. **Dark & Light Parity** — Both themes are first-class. No component should look broken in either mode.

---

## 4. Color System

The existing `AppColors` token class is the right foundation. The following updates correct inconsistencies and add missing semantic tokens.

### 4.1 Updated Token Map

| Token | Light Value | Dark Value | Usage |
|---|---|---|---|
| `background` | `#F0F4EE` | `#0A0F0D` | Screen background |
| `surface` | `#FFFFFF` | `#141A16` | Cards, nav bar |
| `surfaceElevated` | `#F7FAF7` | `#1C2420` | Input fields, chip backgrounds |
| `primary` | `#0E6B4A` | `#2DD88A` | CTAs, active states, progress |
| `primaryDark` | `#095738` | `#1FAF6E` | CTA pressed state |
| `accent` | `#C9A84C` | `#E8C566` | Highlights, "NOW PLAYING" label, warning chip |
| `textPrimary` | `#0D1A14` | `#EAF5EF` | Body text, player names |
| `textSecondary` | `#4A6158` | `#7A9E8C` | Labels, turn counts, timestamps |
| `divider` | `#D5E3DC` | `#243029` | Separator lines |
| `navBar` | `#FFFFFF` | `#141A16` | Navigation bar |
| `cardGradientStart` | `#EBF5F0` | `#162B20` | Card gradient top |
| `cardGradientEnd` | `#D6EEE3` | `#0D1E16` | Card gradient bottom |
| `success` (static) | — | `#22C55E` | Completed badge, +score entries |
| `error` (static) | — | `#EF4444` | Subtract mode, destructive actions |
| `warning` (static) | — | `#E8C566` | Warning threshold chip |

> **Baize Green** (`#0E6B4A` / `#2DD88A`) replaces the current plain iOS blue as the brand primary. This single change does more for identity than any other edit.

### 4.2 Ball Color Tokens (no changes needed)

Ball colors in `AppColors` are already well-defined and contextually accurate. No modifications required.

### 4.3 Implementation Rule

Add `surfaceElevated` and `accent` to `AppColors`. Remove every instance of a raw `CupertinoColors.*`, `Colors.*`, or hardcoded hex in any widget file. All colors must be accessed via `ref.watch(appColorsProvider)` or passed as a `colors` parameter.

---

## 5. Typography

The app currently uses default system font sizing without a defined type scale. The following scale should be codified in a `AppTextStyles` class.

### 5.1 Font Choice

Use **SF Pro** via the system font stack (Flutter's default on iOS) — do not fight the platform. Enforce weights and sizes explicitly rather than relying on defaults.

### 5.2 Type Scale

| Role | Size | Weight | Letter-spacing | Usage |
|---|---|---|---|---|
| `displayScore` | 72sp | Black (900) | -1.0 | Current player's live score number |
| `headline1` | 24sp | Bold (700) | -0.3 | Player name in active card |
| `headline2` | 20sp | SemiBold (600) | -0.2 | Section titles, dialog headings |
| `title` | 17sp | SemiBold (600) | 0 | Nav bar labels, card player names |
| `body` | 15sp | Regular (400) | 0 | Settings rows, dialog body |
| `caption` | 13sp | Medium (500) | 0 | Score labels ("Score: 42"), turn count |
| `label` | 11sp | SemiBold (600) | 1.5 | "NOW PLAYING", "COMPLETED", section headers |
| `ballPoint` | dynamic (30% of ball size) | Bold (700) | 0 | Ball button point value |
| `ballName` | dynamic (14% of ball size) | SemiBold (600) | 0 | Ball name label beneath ball |

### 5.3 Codification

```dart
// lib/core/theme/app_text_styles.dart
class AppTextStyles {
  static TextStyle displayScore(Color color) => TextStyle(
    fontSize: 72, fontWeight: FontWeight.w900, color: color,
    letterSpacing: -1.0, height: 1.0,
  );
  static TextStyle headline1(Color color) => TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.3,
  );
  // ... (define all roles above)
}
```

Every `TextStyle(...)` hardcoded in a widget must be replaced with the appropriate `AppTextStyles.*` call.

---

## 6. Spacing & Layout System

Define a spacing scale in a constants file to eliminate magic numbers.

```dart
// lib/core/constants/app_spacing.dart
class AppSpacing {
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;

  // Semantic
  static const double screenHPad    = 16.0;  // horizontal screen padding
  static const double cardPad       = 20.0;  // card internal padding
  static const double cardRadius    = 20.0;  // standard card corner radius
  static const double chipRadius    = 20.0;  // pill/chip corner radius
  static const double inputRadius   = 14.0;  // text field corner radius
  static const double rowHeight     = 54.0;  // settings row height
}
```

All `padding: const EdgeInsets.all(16)`, `SizedBox(height: 12)`, etc. in widget files must use `AppSpacing.*` values.

---

## 7. Screen-by-Screen Specifications

### 7.1 Splash Screen

**Current state:** Unknown (file not reviewed but it routes to `SplashScreen`).

**Required:**
- Full-screen dark background (`colors.background`).
- Centered logo image (80×80, circular white border 2pt) with a fade-in animation (400ms, ease-out).
- App name in `AppTextStyles.headline1` below the logo, fade-in 200ms after logo.
- "by Ali Abbas" in `AppTextStyles.caption` / `textSecondary`, 100ms after app name.
- A thin animated progress bar in `colors.primary` along the bottom edge, completes in ~1.2s then navigates.
- No splash screen jank: preload Hive before showing. Avoid showing the splash for longer than 2s.

---

### 7.2 Home Screen (Game Board)

This is the most complex and most critical screen. It currently has good bones but needs significant visual surgery.

#### 7.2.1 Layout Architecture

The screen is a `CupertinoPageScaffold` with a scrollable body. Content should be organized into clearly separated visual zones using the following vertical flow:

```
┌─────────────────────────────────┐
│  Navigation Bar                 │  (app name + subtitle)
├─────────────────────────────────┤
│  Target Score Selector          │  (horizontal pill selector)
├─────────────────────────────────┤
│  Current Player Card            │  (large, gradient, score display)
├─────────────────────────────────┤
│  Ball Grid                      │  (7 balls, 3-3-1 rows)
├─────────────────────────────────┤
│  Subtract Mode Toggle           │  (full-width toggle bar)
├─────────────────────────────────┤
│  Action Row: Undo / Next Player │  (two buttons, side by side)
├─────────────────────────────────┤
│  Player List Header             │  ("PLAYERS" + "New Game" button)
├─────────────────────────────────┤
│  Add Player Row                 │  (text field + + button)
├─────────────────────────────────┤
│  Animated Player List           │  (PlayerCard items)
│                                 │
└─────────────────────────────────┘
```

Each zone has `AppSpacing.lg` vertical padding between it and the next.

#### 7.2.2 Navigation Bar

**Current issues:** Uses emoji 🎱, subtitle text is a second `Text` widget squeezed into the `middle` column — fragile on small screens.

**Fix:**
- `middle:` A single `Text` with value `'Nazeer Gaming Club'` in `AppTextStyles.title`.
- Remove the emoji from the nav bar. The app icon carries brand identity; the nav bar should be clean.
- `trailing:` A single icon button for "New Game" (`CupertinoIcons.plus_circle`) — remove it from being buried in the player list section below.

#### 7.2.3 Target Score Selector

**Current issues:** Duplicated between Home and Settings screens with slightly different styling.

**Extract to:** A shared `TargetScoreSelector` widget in `lib/presentation/widgets/target_score_selector.dart`.

**Specification:**
- Horizontal `Row` of 4 pill buttons: `[100, 150, 200, 250]`.
- Selected: `colors.primary` fill, white text.
- Unselected: `colors.surfaceElevated` fill, `colors.textSecondary` text, `colors.primary` border (1pt).
- Height: 36pt. Horizontal padding between pills: `AppSpacing.sm`.
- `AnimatedContainer` transition: 150ms, `Curves.easeInOut`.
- Wrapped in horizontal padding `AppSpacing.screenHPad` on both sides.

#### 7.2.4 Current Player Card

**Current issues:** Score `Text` uses hardcoded `colors.primary` — correct, but the card is visually isolated. No player position/rank indication. "NOW PLAYING" label could be more premium.

**Specification:**
- Background: `LinearGradient` from `cardGradientStart` → `cardGradientEnd`, top-left to bottom-right.
- Corner radius: `AppSpacing.cardRadius` (20pt).
- Padding: `AppSpacing.cardPad` (20pt).
- `boxShadow`: colored shadow using `colors.primary.withOpacity(0.18)`, blur 24, offset (0,6).
- **"NOW PLAYING" label**: `AppTextStyles.label` in `colors.accent` (gold). Adds warmth and brand color.
- **Player name**: `AppTextStyles.headline1` in `colors.textPrimary`.
- **Score number**: `AppTextStyles.displayScore` in `colors.primary`. This is the hero number. Make it huge and proud.
- **Remaining points chip**: Same as current but use `colors.accent` instead of static amber. Text: `"$remaining to target"`. Keep the warning icon.
- **Empty state** (no player selected): Show a centered icon `CupertinoIcons.person_crop_circle_badge_plus` in `colors.textSecondary.withOpacity(0.4)`, size 48, with text "Select a player to begin" in `AppTextStyles.body` / `textSecondary`. Remove the cricket icon from Material library — stay Cupertino.
- **Animation**: `AnimatedSwitcher` with 250ms fade when player changes.

#### 7.2.5 Ball Grid

**Current issues:** This is actually one of the better-implemented components. Minor improvements only.

**Keep:** 3D highlight effect, press-scale animation, colored glow shadow.

**Fix:**
- The lone red ball in row 3 (single centered item) looks orphaned. Position it centered with explicit `MainAxisAlignment.center` and add a subtle label: `"Highest Value"` in `AppTextStyles.label` / `textSecondary` above it, OR keep the current layout but add consistent bottom label spacing so all 7 balls have labels.
- Subtract mode overlay: currently shows a red tint. Improve: show a small `−` badge (red circle, white minus) in the top-right of each ball, using `Stack` + `Positioned`. This is clearer than a tint alone.
- Ball label color for yellow: current fix (`Color(0xFFB8860B)`) is correct, keep it.

#### 7.2.6 Subtract Mode Toggle

**Current state:** Works well visually. One UX improvement.

**Fix:**
- Add a **haptic feedback** call on toggle: `HapticFeedback.mediumImpact()`.
- The toggle transitions from a bordered outline button to a filled red gradient. This is a strong pattern — keep it exactly.
- Label update: when active, prepend "MODE ACTIVE" as a small `AppTextStyles.label` text above the button to make the state persistent and scannable at a glance (especially for the game operator calling scores for others).

#### 7.2.7 Action Buttons (Undo / Next Player)

**Current issues:** `Undo` button currently has no disabled state — it can be pressed even when there's nothing to undo.

**Fix:**
- Pass `hasHistory` bool from provider to disable Undo when history is empty.
- Disabled state: 40% opacity, no press animation, cursor change (iOS doesn't show cursors, so opacity is sufficient).
- "Next Player" button: add a chevron icon `CupertinoIcons.chevron_right` after the label to reinforce the directional action.
- Both buttons: height 52pt (currently 50pt — meets minimum but feels slightly cramped). `borderRadius: 14pt`.

#### 7.2.8 Player List Header

**Current issues:** "New Game" and "Add Player" are in separate visual areas without clear separation.

**Fix:**
- Player list header row: `"PLAYERS"` label (left, `AppTextStyles.label`) and a `CupertinoButton` "New Game" (right, `colors.error` text color, no fill, text only). This way the destructive action is clearly secondary to the player list it sits above.
- The `AnimatedList` is correct; keep it.

#### 7.2.9 Add Player Input Row

**Current issues:** The `+` button is a bare `CupertinoButton`. No visual container distinguishes the input area from the list below it.

**Fix:**
- Wrap the row in a `Container` with `colors.surface` background, `borderRadius: AppSpacing.inputRadius`, and `boxShadow: colors.cardShadow`.
- Text field: `CupertinoTextField` with `placeholder: "Player name..."`, `colors.textSecondary` placeholder color, no border (the container provides it), `colors.surfaceElevated` fill.
- `+` button: a 38×38 circular button in `colors.primary` with a white `+` icon (`CupertinoIcons.add`). Tap triggers `_addPlayer`.
- On `textField` submit (keyboard "Done"), also trigger `_addPlayer`.

#### 7.2.10 Player Card

**Current issues:** The `PlayerCard` widget uses `CupertinoColors.systemBlue` and `CupertinoColors.black` instead of theme tokens. It also imports no `AppColors` — it relies on hard-coded system colors.

**Fix (complete rewrite of `PlayerCard`):**
- Accept `AppColors colors` as a required parameter (already partly done — fully enforce it).
- **Active state border**: `colors.primary` (brand green) instead of system blue.
- **Active state background**: `colors.primary.withOpacity(0.08)`.
- **Player name text**: `AppTextStyles.title` in `colors.textPrimary` (active) or `colors.textSecondary` (inactive).
- **Score label**: `AppTextStyles.caption` — "Score: 42" is secondary info.
- **Progress bar**: height 6pt (not 8pt — less chunky). Active fill: `colors.primary`. Completed fill: `AppColors.success`.
- **Completed badge**: small pill — `AppColors.success` background, white `AppTextStyles.label` text.
- **Rank number**: Add a small `(1)`, `(2)` etc. rank indicator (1-indexed position in player list) as a circular badge in the top-left, `colors.surfaceElevated` background, `colors.textSecondary` text. This instantly communicates standing.
- **Remove button**: `CupertinoIcons.xmark_circle_fill` in `colors.error` — matches the red theme without needing a `GestureDetector` on a raw `Icon`.
- **Turn count**: Render as `"${player.turnCount} turns"` — the word "Turns" in the raw value makes it self-explanatory.

---

### 7.3 History Screen

**Current state:** Structurally sound. The left-colored-border card pattern with avatar + name + score badge is excellent. Minor fixes.

**Issues & Fixes:**

- **Mixed icon libraries**: `Icons.delete_sweep` (Material) is used in the nav bar trailing. Replace with `CupertinoIcons.trash` or `CupertinoIcons.delete`.
- **Timestamp format**: `dd/mm  hh:mm` has two spaces between date and time — looks like a bug. Use `_formatTime` to return `"dd/mm · hh:mm"` with a middle dot separator for clarity.
- **Empty state icon**: `CupertinoIcons.clock` at 64pt with opacity is fine. Add a subtitle improvement: `"Score actions will appear here as you play"` → break at a natural word boundary and use `AppTextStyles.body` / `textSecondary`.
- **Player avatar**: Currently a 1-char initial circle. If `playerName.length > 1`, derive a consistent color from the player name string hash (pick from a predefined palette of 6–8 colors). This makes repeated players visually identifiable across history entries.
- **Ball color indicator**: The `action.ballColor` string is stored per history entry. Display a small colored dot (8pt circle) next to the score badge to show which ball was potted. This adds scannable context with zero screen real estate cost.
- **Date grouping**: Group history entries by date (Today, Yesterday, dd/mm/yyyy) with a sticky section header using `AppTextStyles.label` / `textSecondary`. This transforms a flat feed into a readable log.

---

### 7.4 Settings Screen

**Current state:** The iOS-style `_SettingsGroup` → `_SettingsRow` pattern is correct and should be kept. The `_AppHeader` card at the top is charming.

**Issues & Fixes:**

- **App Header Card**: Currently uses hardcoded `CupertinoColors.white` for text. Use `colors.textPrimary` with inverted logic if rendering on a dark background, OR always render white text (safe since the card always has a dark gradient). Keep white text — the gradient card is always dark. Document this exception.
- **Dark Mode Toggle**: Already implemented. Ensure the `CupertinoSwitch` uses `activeColor: colors.primary` (brand green, not blue).
- **Target Score in Settings**: This setting controls the *default* for new games. Clarify the subtitle text: `"Default for new games"` instead of nothing. Use the shared `TargetScoreSelector` widget.
- **Missing Setting — Player Color Avatars**: Add a new toggle `"Colorful Player Avatars"` that controls whether avatar colors derive from name hash or are always monochrome. Stored in `AppSettings`.
- **Missing Setting — Haptic Feedback**: Add a toggle for haptic feedback (on/off). Store in `AppSettings`. Guard all `HapticFeedback.*` calls with this setting.
- **Missing Setting — Keep Screen On**: Add a toggle `"Keep Screen On During Game"` that calls `WakelockPlus.enable()/disable()`. This is critical for a scorekeeping app — the screen must not sleep mid-game.
- **About section**: Keep the existing `_AppHeader`. Add an `"Open Source Licenses"` row using `showCupertinoModalPopup` or a detail push to a licenses view. This is a common App Store review requirement.
- **Clear History**: Move the "Clear History" action from the History screen's navigation bar to the Settings screen (inside a "Danger Zone" section). The nav bar trash icon pattern forces users to navigate to a different tab to discover a destructive action.

---

## 8. Navigation & Tab Bar

**Current state:** The app uses a `CupertinoTabScaffold` with 3 tabs. Tab labels and icons not confirmed from source but inferred.

### 8.1 Tab Bar Specification

| Tab | Icon (inactive) | Icon (active) | Label |
|---|---|---|---|
| Game | `CupertinoIcons.game_controller` | `CupertinoIcons.game_controller_fill` | Game |
| History | `CupertinoIcons.clock` | `CupertinoIcons.clock_fill` | History |
| Settings | `CupertinoIcons.gear` | `CupertinoIcons.gear_alt_fill` | Settings |

- Active tab icon color: `colors.primary`.
- Tab bar background: `colors.navBar` with `colors.divider` top border (0.5pt).
- Ensure `CupertinoTabBar` respects safe area (bottom padding for home-indicator iPhones).

### 8.2 Push Navigation

When the game ends (all players complete their target), **push** a `GameCompleteScreen` (see Section 9). Do not use `showCupertinoDialog` — a full screen transition is more satisfying for a game conclusion.

---

## 9. Missing Screens & Flows

### 9.1 Game Complete Screen (NEW — required)

**Trigger:** `game.isGameComplete == true`.

**Purpose:** Celebrate the end of the game, show final rankings, and offer a "New Game" CTA.

**Layout:**
- Full-screen dark background with a subtle confetti animation (use a lightweight package like `confetti` or a custom canvas particle effect — keep it brief, 2s).
- Hero text: `"🎱 Game Over"` in `AppTextStyles.displayScore` (smaller, ~48sp), centered.
- Final rankings list: each player as a row with rank number, name, score, and a gold/silver/bronze medal emoji for the top 3.
- "New Game" primary CTA button (full-width, `colors.primary` fill, white text, 52pt height).
- "Back to Lobby" secondary text button below.

### 9.2 Player Detail / Score Breakdown (OPTIONAL — v2.0)

Accessible by tapping a completed `PlayerCard`. Shows a per-ball breakdown of how the score was accumulated, pulled from the `HistoryAction` log filtered by `playerId`. This is a stretch goal but the data is already stored — it just needs a UI.

---

## 10. Animations & Micro-Interactions

| Interaction | Animation | Duration | Curve |
|---|---|---|---|
| Tab switch | Default Cupertino cross-fade | — | System |
| Player card added | `AnimatedList` slide-in from right | 300ms | `easeOut` |
| Player card removed | `AnimatedList` slide-out + fade | 300ms | `easeIn` |
| Ball button press | Scale 0.88 on `TapDown`, 1.0 on `TapUp` | 80ms | `bounceOut` |
| Active player change | `AnimatedSwitcher` fade in current player card | 250ms | `easeInOut` |
| Subtract mode toggle | `AnimatedContainer` color + shadow transition | 200ms | `easeInOut` |
| Score update in card | `AnimatedDefaultTextStyle` or `TweenAnimationBuilder` roll-up | 200ms | `easeOut` |
| Progress bar fill | `TweenAnimationBuilder<double>` | 400ms | `easeOut` |
| Completed badge appearance | Scale from 0.0 → 1.0 + fade | 300ms | `elasticOut` |
| Warning chip appear | Fade-in + slide up | 200ms | `easeOut` |
| Game complete confetti | Particle burst | 2000ms | Custom |

**Rule:** All animation durations are defined as constants in `AppConstants` (e.g., `animFast = 80ms`, `animMid = 200ms`, `animSlow = 300ms`).

---

## 11. Accessibility

| Requirement | Implementation |
|---|---|
| Minimum touch target | 44×44 pt. All ball buttons, action buttons, and list rows must comply. |
| Semantic labels | Add `Semantics(label: '...')` wrappers to ball buttons: `"${ball.name} ball, ${ball.points} points"`. |
| Contrast ratio | All text on cards must meet WCAG AA (4.5:1 for body, 3:1 for large). Test both themes. |
| Screen reader | `CupertinoApp` respects system VoiceOver. Ensure `excludeFromSemantics: true` on decorative icons. |
| Dynamic Type | Do not use fixed `fontSize` where system Dynamic Type scaling is appropriate. Use `MediaQuery.textScaleFactor` guards only for score display where layout breaks above 1.5×. |

---

## 12. Error States & Edge Cases

| State | Current Handling | Required Handling |
|---|---|---|
| No players in game | Empty state text | Illustrated empty state: large `CupertinoIcons.person_crop_circle_badge_plus` + instructional copy + animated hint arrow pointing to the add-player field |
| All players completed | None detected | Trigger `GameCompleteScreen` push |
| Max players (12) reached | None detected | Disable the add-player input row, show inline message: `"Maximum 12 players reached"` in `AppTextStyles.caption` / `colors.error` |
| Player name duplicate | None detected | Show inline validation under the text field: `"A player named 'Ali' already exists"` |
| Empty player name submit | `_addPlayer` guards `name.isEmpty` | Additionally shake the text field with a brief `CurvedAnimation` wiggle (left 6px → right 6px → center, 300ms) |
| Undo with no history | Button is tappable | Disable button (opacity 0.4, `onTap: null`) |
| Score already 0 in subtract mode | Not handled | Prevent score going negative. Show a brief toast: `"Score can't go below 0"` using `CupertinoToast` or a bottom `OverlayEntry`. |

---

## 13. Component Library Inventory

All widgets should live in `lib/presentation/widgets/`. The following are either new or need to be extracted:

| Widget File | Status | Description |
|---|---|---|
| `target_score_selector.dart` | **Extract** | Shared between Home and Settings |
| `player_card.dart` | **Refactor** | Fix hardcoded colors, add rank badge |
| `ball_button.dart` | **Keep + minor fix** | Add subtract-mode minus badge |
| `subtract_toggle.dart` | **Keep** | Minor: add haptics |
| `action_button.dart` | **Refactor** | Accept disabled state |
| `app_header_card.dart` | **Keep** | Settings screen app info card |
| `settings_group.dart` | **Keep** | iOS-style grouped list |
| `settings_row.dart` | **Keep** | Settings list row |
| `score_history_entry.dart` | **Refactor** | Add ball color dot, fix timestamp |
| `empty_state.dart` | **New** | Generic empty state: icon + title + subtitle |
| `toast_overlay.dart` | **New** | Lightweight toast for validation messages |
| `player_avatar.dart` | **New** | Circular avatar with hashed color + initial |
| `game_complete_screen.dart` | **New** | Full-screen end-of-game screen |
| `animated_score.dart` | **New** | Score number with roll-up tween animation |

---

## 14. Code Quality Standards for UI Code

The following rules apply to all widget files:

1. **No raw system colors.** Every color comes from `AppColors` via `colors.*` parameter or `ref.watch(appColorsProvider)`.
2. **No mixed icon libraries.** Use only `CupertinoIcons`. The only exception is `Icons.sports_cricket` — replace with a custom SVG asset or remove.
3. **No magic numbers.** All sizes, radii, paddings, and durations use `AppSpacing.*` or `AppConstants.*` named values.
4. **No inline `TextStyle`.** All text styles use `AppTextStyles.*` factory methods.
5. **Const constructors everywhere possible.** Static widgets should be `const`.
6. **Widget decomposition.** No `build()` method exceeds 80 lines. Extract private `_WhateverWidget` classes or top-level stateless widgets as needed.
7. **Pass colors down, don't watch in every leaf.** Intermediate widgets receive `AppColors colors` as a constructor param. Only screen-level `ConsumerWidget`s call `ref.watch(appColorsProvider)`.

---

## 15. Asset Requirements

| Asset | Format | Current State | Action |
|---|---|---|---|
| `assets/logo.png` | PNG, 120×120 @3x | Present | Ensure correct resolution; add @1x and @2x variants |
| App Icon | PNG set | Not reviewed | Must match brand (green baize theme) |
| Custom Ball SVG | SVG (optional) | Not present | Optional: replace circle + text balls with SVG ball artwork for a more polished look |

---

## 16. Implementation Priority

| Priority | Area | Effort | Impact |
|---|---|---|---|
| 🔴 P0 | Replace all hardcoded colors with `AppColors` tokens | Medium | High — eliminates theme bugs |
| 🔴 P0 | Codify `AppTextStyles` and replace all inline `TextStyle` | Medium | High — visual consistency |
| 🔴 P0 | Remove all Material `Icons.*` imports, use Cupertino only | Low | High — platform consistency |
| 🟠 P1 | Rebrand primary color to Baize Green | Low | Very High — identity |
| 🟠 P1 | Refactor `PlayerCard` (token colors, rank badge, UX fixes) | Medium | High |
| 🟠 P1 | Extract `TargetScoreSelector` shared widget | Low | Medium |
| 🟠 P1 | Add `GameCompleteScreen` | High | High — missing critical flow |
| 🟡 P2 | Add `AppSpacing` constants, replace magic numbers | Low | Medium |
| 🟡 P2 | History: date grouping, ball color dots, player avatar colors | Medium | Medium |
| 🟡 P2 | Settings: add missing toggles (Haptic, Keep Screen On, Clear History move) | Medium | Medium |
| 🟡 P2 | Undo button disabled state | Low | Medium |
| 🟢 P3 | `AnimatedScore` roll-up widget | Medium | Medium |
| 🟢 P3 | Toast overlay for validation messages | Medium | Low–Medium |
| 🟢 P3 | Player Detail / Score Breakdown screen | High | Low (v2.0) |

---

## 17. Acceptance Criteria

The frontend is considered production-ready (100%) when:

- [ ] Both dark and light themes render correctly on iPhone SE (375pt wide) and iPhone Pro Max (430pt wide).
- [ ] No raw `CupertinoColors.*` or `Colors.*` references exist in any widget file.
- [ ] No Material `Icons.*` are imported in any widget file.
- [ ] All text uses `AppTextStyles` named styles.
- [ ] All spacing uses `AppSpacing` constants.
- [ ] All touch targets are ≥ 44×44 pt.
- [ ] `GameCompleteScreen` is displayed when all players complete their target.
- [ ] Subtract mode prevents score going below 0.
- [ ] Undo button is visually disabled when no history exists.
- [ ] Keep Screen On toggle works during active games.
- [ ] App has been reviewed against Apple HIG — no obvious violations.
- [ ] Both themes pass WCAG AA contrast for all text elements.
- [ ] App name and icon match the Baize Green brand identity.

---

*End of PRD — Nazeer Gaming Club Frontend v2.0.0*
