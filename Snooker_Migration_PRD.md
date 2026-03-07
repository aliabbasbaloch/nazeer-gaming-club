# Product Requirements Document (PRD)
## Nazeer Gaming Club — Snooker Score App
### Migration: Cupertino → Material 3 + Electric Blue & Cyan Theme

---

**Document Version:** 1.0
**App Name:** Nazeer Gaming Club
**Package Name:** snooker (keep as-is from pubspec.yaml)
**Current State:** CupertinoApp, white light theme, iOS widgets
**Target State:** MaterialApp, Electric Blue & Cyan dark theme, Material 3 widgets
**Developer:** Ali Abbas
**Migration Type:** UI/Theme only — ALL business logic preserved exactly

---

## ⚠️ AI AGENT RULES — READ BEFORE ANY CODE

```
RULE 1 — ZERO FEATURE CHANGES
  This is a UI migration ONLY.
  Do NOT add, remove, or modify any business logic.
  Do NOT change providers, models, storage, or game rules.
  Every feature that works now must work identically after migration.

RULE 2 — PRESERVE ALL PROVIDERS EXACTLY
  gameProvider, settingsProvider, historyProvider, drawProvider,
  gameTimerProvider, storageRepositoryProvider, appColorsProvider,
  navigateToHomeProvider — none of these change in any way.
  Do NOT touch any file in: data/, providers/

RULE 3 — PRESERVE ALL HIVE MODELS EXACTLY
  Do NOT modify any .dart or .g.dart file in data/models/
  Hive typeIds, field names, field types — all must stay identical.
  Any change will corrupt existing user data.

RULE 4 — COLOR SCHEME LOCKED (ELECTRIC BLUE & CYAN)
  Use ONLY the colors defined in Section 6 of this PRD.
  Apply via AppColors class and AppTheme — no hardcoded hex values in screens.
  The app runs in DARK mode only — remove light mode toggle from settings.

RULE 5 — REPLACE EVERY CUPERTINO WIDGET
  Not a single Cupertino widget must remain after migration.
  Replace every widget listed in Section 4 with its Material equivalent.
  Set uses-material-design: true in pubspec.yaml.
  Change CupertinoApp → MaterialApp in main.dart.

RULE 6 — FIX ALL DEPRECATIONS
  Replace every Color.withOpacity() with Color.withValues(alpha: x).
  Found in: app_colors.dart, home_screen.dart, draw_screen.dart,
  history_screen.dart, settings_screen.dart, player_card.dart,
  snooker_ball_button.dart, game_analytics_widget.dart.

RULE 7 — FIX ALL HARDCODED COLORS
  Replace every hardcoded hex color with AppColors constants.
  See Section 7 for the complete mapping.
  No raw Color(0xFF...) values allowed in screen files.

RULE 8 — KEEP FOLDER STRUCTURE IDENTICAL
  Do NOT rename, move, or reorganize any file.
  Only modify file CONTENTS — never file paths or names.

RULE 9 — NAVIGATION STAYS THE SAME
  Keep IndexedStack + tab-based navigation.
  Keep splash → MainNavigation pushReplacement flow.
  Replace _CustomBottomNav Cupertino styling with Material BottomNavigationBar
  or NavigationBar — same 4 tabs, same icons (switch to Icons.* equivalents).

RULE 10 — BUILD MUST PASS WITH ZERO ERRORS
  Run flutter analyze after every file change.
  Fix every error before moving to the next file.
  Zero warnings allowed in final build.
  Test on Android emulator before marking complete.

RULE 11 — COMPLETE FILES ONLY
  Never leave a file half-done.
  Complete each file fully before opening the next.
  Migration order is defined in Section 9 — follow it exactly.

RULE 12 — DARK MODE ONLY
  The new app runs in dark mode only (Brightness.dark).
  Remove the isDarkMode toggle from settings.
  AppSettings.isDarkMode field stays in the Hive model (do not change model)
  but the UI always uses the dark color palette.
  Remove the dark mode CupertinoSwitch row from SettingsScreen.
```

---

## Table of Contents

1. [Migration Overview](#1-migration-overview)
2. [What Does NOT Change](#2-what-does-not-change)
3. [What Changes](#3-what-changes)
4. [Cupertino → Material Widget Map](#4-cupertino--material-widget-map)
5. [New Theme Architecture](#5-new-theme-architecture)
6. [Electric Blue & Cyan Color Palette](#6-electric-blue--cyan-color-palette)
7. [Hardcoded Color Fix Map](#7-hardcoded-color-fix-map)
8. [Screen-by-Screen Specification](#8-screen-by-screen-specification)
9. [Migration Order](#9-migration-order)
10. [pubspec.yaml Changes](#10-pubspecyaml-changes)
11. [Deprecation Fixes](#11-deprecation-fixes)
12. [Other Fixes](#12-other-fixes)

---

## 1. Migration Overview

The Nazeer Gaming Club snooker app is fully functional but built entirely with iOS Cupertino widgets and a white light theme. The goal is to migrate the UI to Material 3 with the Electric Blue & Cyan dark theme — the same theme used in the A-Audio Flutter app.

**What this migration achieves:**
- Looks professional and modern on Android (not like a ported iOS app)
- Dark mode electric blue theme — premium feel for a gaming club app
- Fixes all existing deprecation warnings
- Fixes all hardcoded color values
- Removes unused widgets (or wires them in — per Section 12)

**What this migration does NOT do:**
- Does not change scoring logic, ball values, undo, turn management
- Does not change Hive storage or data models
- Does not change Riverpod providers
- Does not add new features

---

## 2. What Does NOT Change

These files must NOT be modified at all:

```
data/models/app_settings.dart        ← Hive model
data/models/app_settings.g.dart      ← Generated adapter
data/models/game.dart                ← Hive model
data/models/game.g.dart              ← Generated adapter
data/models/history_action.dart      ← Hive model
data/models/history_action.g.dart    ← Generated adapter
data/models/player.dart              ← Hive model
data/models/player.g.dart            ← Generated adapter
data/models/snooker_ball.dart        ← Ball enum + points logic
data/repositories/storage_repository.dart  ← Hive CRUD
presentation/providers/draw_provider.dart
presentation/providers/game_provider.dart
presentation/providers/game_timer_provider.dart
presentation/providers/history_provider.dart
presentation/providers/settings_provider.dart
core/constants/app_constants.dart    ← Keep all constants
core/utils/date_formatter.dart       ← Keep as-is
```

---

## 3. What Changes

| File | Change Type |
|---|---|
| `pubspec.yaml` | uses-material-design: true, add Google Fonts, remove cupertino_icons |
| `main.dart` | CupertinoApp → MaterialApp, dark ThemeData, fix Firebase stub |
| `core/theme/app_theme.dart` | Full rewrite — Material ThemeData, Electric Blue palette |
| `core/theme/app_colors.dart` | Update all color tokens to Electric Blue & Cyan palette |
| `presentation/main_navigation.dart` | Replace CupertinoPageScaffold + custom nav → Scaffold + NavigationBar |
| `presentation/screens/splash/splash_screen.dart` | Replace Cupertino scaffold, fix hardcoded white bg, add cyan glow |
| `presentation/screens/home/home_screen.dart` | Replace all Cupertino widgets → Material, fix hardcoded colors |
| `presentation/screens/draw/draw_screen.dart` | Replace all Cupertino widgets → Material, fix hardcoded colors |
| `presentation/screens/history/history_screen.dart` | Replace all Cupertino widgets → Material |
| `presentation/screens/settings/settings_screen.dart` | Replace all Cupertino widgets → Material, remove dark mode toggle |
| `presentation/widgets/add_player_dialog.dart` | CupertinoAlertDialog → AlertDialog |
| `presentation/widgets/player_card.dart` | Fix deprecations, CupertinoButton → TextButton/IconButton |
| `presentation/widgets/game_analytics_widget.dart` | Fix deprecations only |
| `presentation/widgets/snooker_ball_button.dart` | Fix deprecations only |

---

## 4. Cupertino → Material Widget Map

Replace every Cupertino widget with its Material equivalent:

| Cupertino Widget | Replace With |
|---|---|
| `CupertinoApp` | `MaterialApp` |
| `CupertinoPageScaffold` | `Scaffold` |
| `CupertinoNavigationBar` | `AppBar` with custom styling |
| `CupertinoTextField` | `TextField` with `InputDecoration` |
| `CupertinoAlertDialog` | `AlertDialog` |
| `CupertinoDialogAction` | `TextButton` inside `actions:` |
| `CupertinoSwitch` | `Switch` (Material) |
| `CupertinoButton` | `TextButton` or `IconButton` |
| `CupertinoIcons.*` | `Icons.*` equivalent (see mapping below) |
| `CupertinoThemeData` | `ThemeData` (Material 3) |

### CupertinoIcons → Icons mapping

| CupertinoIcons | Icons |
|---|---|
| `circle_grid_3x3_fill` | `grid_view` |
| `shuffle` | `shuffle` |
| `clock` | `history` |
| `gear` | `settings` |
| `arrow_2_circlepath` | `refresh` |
| `person_badge_plus` | `person_add` |
| `minus_circle` | `remove_circle_outline` |
| `arrow_uturn_left` | `undo` |
| `arrow_right_circle_fill` | `arrow_circle_right` |
| `xmark_circle_fill` | `cancel` |
| `trash` | `delete_outline` |
| `moon_fill` | `dark_mode` |
| `flag_fill` | `flag` |
| `chevron_right` | `chevron_right` |
| `chevron_down` | `expand_more` |
| `play_fill` | `play_arrow` |
| `person_2_fill` | `group` |
| `dice` | `casino` |
| `sparkles` (emoji ✨) | keep as emoji text |

---

## 5. New Theme Architecture

### main.dart

```
MaterialApp(
  theme: AppTheme.darkTheme,   // only dark theme — no light theme
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.dark,   // always dark
  home: SplashScreen(),
)
```

### app_theme.dart (full rewrite)

```
AppTheme.darkTheme → ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary:    Color(0xFF0066FF),   // electricBlue
    secondary:  Color(0xFF00D4FF),   // cyan
    surface:    Color(0xFF0E1A2E),   // bgCard
    background: Color(0xFF080F1E),   // bgPage
    error:      Color(0xFFFF5252),   // danger
  ),
  scaffoldBackgroundColor: Color(0xFF080F1E),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF050D1A),  // navbar
    foregroundColor: Color(0xFFE8F4FF),  // textPrimary
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: 'Syne',
      fontSize: 18, fontWeight: FontWeight.w700,
      color: Color(0xFFE8F4FF),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF050D1A),
    selectedItemColor: Color(0xFF00D4FF),   // cyan
    unselectedItemColor: Color(0xFF4A6A8A), // textMuted
    type: BottomNavigationBarType.fixed,
  ),
  cardTheme: CardThemeData(
    color: Color(0xFF0E1A2E),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF0E1A2E),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF1A2A44)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF0066FF), width: 2),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((s) =>
      s.contains(WidgetState.selected)
        ? Color(0xFF00D4FF) : Color(0xFF4A6A8A)),
    trackColor: WidgetStateProperty.resolveWith((s) =>
      s.contains(WidgetState.selected)
        ? Color(0xFF0066FF).withValues(alpha: 0.4) : Color(0xFF1A2A44)),
  ),
  fontFamily: 'Syne',
)
```

### app_colors.dart (updated tokens — dark mode only)

AppColors class keeps the same structure but returns Electric Blue & Cyan values for every token. Remove all light mode branching — return dark values always.

---

## 6. Electric Blue & Cyan Color Palette

These are the ONLY colors to use. Apply via AppColors constants — never hardcode.

```dart
// ── Backgrounds ──────────────────────────────
static const bgPage        = Color(0xFF080F1E);  // deepest bg
static const bgCard        = Color(0xFF0E1A2E);  // card surface
static const navbar        = Color(0xFF050D1A);  // nav bar bg
static const bgElevated    = Color(0xFF162236);  // elevated cards

// ── Brand ────────────────────────────────────
static const primary       = Color(0xFF0066FF);  // electric blue
static const primaryDark   = Color(0xFF0052CC);  // pressed state
static const accent        = Color(0xFF00D4FF);  // cyan
static const accentDark    = Color(0xFF00A8CC);  // cyan pressed

// ── Text ─────────────────────────────────────
static const textPrimary   = Color(0xFFE8F4FF);  // headings / main
static const textSecondary = Color(0xFFB0C4D8);  // body text
static const textMuted     = Color(0xFF4A6A8A);  // hints / labels
static const textDisabled  = Color(0xFF2A3A4A);  // disabled

// ── Borders ──────────────────────────────────
static const border        = Color(0xFF1A2A44);  // card borders
static const borderLight   = Color(0xFF243650);  // subtle dividers

// ── Status ───────────────────────────────────
static const success       = Color(0xFF00E676);  // green
static const successBg     = Color(0xFF0A2A1A);
static const warning       = Color(0xFFFFB300);  // amber/gold
static const warningBg     = Color(0xFF2A2000);
static const danger        = Color(0xFFFF5252);  // red
static const dangerBg      = Color(0xFF2A0A0A);

// ── Ball Colors (keep existing logic) ────────
static const ballYellow    = Color(0xFFFFD700);
static const ballGreen     = Color(0xFF22C55E);
static const ballBrown     = Color(0xFF92400E);
static const ballBlue      = Color(0xFF3B82F6);
static const ballPink      = Color(0xFFEC4899);
static const ballBlack     = Color(0xFF1F2937);
static const ballRed       = Color(0xFFEF4444);
```

### Gradient definitions (used in buttons/cards):

```dart
// Primary action button gradient
LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
  begin: Alignment.centerLeft, end: Alignment.centerRight,
);

// Current player card gradient
LinearGradient cardGradient = LinearGradient(
  colors: [Color(0xFF0E2A5A), Color(0xFF061428)],
  begin: Alignment.topLeft, end: Alignment.bottomRight,
);

// Subtract mode gradient (red — keep as-is)
LinearGradient subtractGradient = LinearGradient(
  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
);
```

---

## 7. Hardcoded Color Fix Map

Replace every hardcoded hex value in screen files with AppColors constants:

| Hardcoded Value | File(s) | Replace With |
|---|---|---|
| `0xFF0077CC` | splash_screen, app_theme | `AppColors.primary` |
| `0xFF00AAFF` | home_screen, draw_screen | `AppColors.accent` |
| `0xFFF59E0B` | home_screen, draw_screen | `AppColors.warning` |
| `0xFFB8860B` | home_screen | `AppColors.warning` (dark tint — use directly) |
| `0xFFEF4444` | home_screen | `AppColors.danger` |
| `0xFFDC2626` | home_screen | `AppColors.primaryDark` via subtractGradient |
| `0xFFFFFFFF` | splash_screen (bg) | `AppColors.bgPage` |
| `0xFFFFDD00` | history_screen | `AppColors.ballYellow` |
| `0xFF33FF77` | history_screen | `AppColors.ballGreen` |
| `0xFFD2691E` | history_screen | `AppColors.ballBrown` |
| `0xFF4D9FFF` | history_screen | `AppColors.ballBlue` |
| `0xFFFF66CC` | history_screen | `AppColors.ballPink` |
| `0xFF888888` | history_screen | `AppColors.ballBlack` |
| `0xFFFF5555` | history_screen | `AppColors.ballRed` |

---

## 8. Screen-by-Screen Specification

---

### 8.1 Splash Screen

**File:** `presentation/screens/splash/splash_screen.dart`

**Changes:**
- Replace `CupertinoPageScaffold` → `Scaffold`
- Background: `AppColors.bgPage` (was hardcoded white `0xFFFFFFFF`)
- Title text color: `AppColors.primary` (was hardcoded `0xFF0077CC`)
- Add cyan glow effect behind logo:
  ```
  A radial gradient Container behind the logo image:
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    boxShadow: [BoxShadow(
      color: AppColors.accent.withValues(alpha: 0.3),
      blurRadius: 60, spreadRadius: 20,
    )],
  )
  ```
- Keep all 3 AnimationControllers and timing (2800ms) exactly as-is
- Keep logo image, title "Nazeer Gaming Club", byline "by Ali Abbas"
- Navigation to MainNavigation: keep pushReplacement with fade — unchanged

---

### 8.2 Main Navigation

**File:** `presentation/main_navigation.dart`

**Changes:**
- Replace `CupertinoPageScaffold` → `Scaffold`
- Replace custom `_CustomBottomNav` → Material `BottomNavigationBar`:
  ```
  BottomNavigationBar(
    backgroundColor: AppColors.navbar,
    selectedItemColor: AppColors.accent,
    unselectedItemColor: AppColors.textMuted,
    type: BottomNavigationBarType.fixed,
    currentIndex: _currentIndex,
    onTap: (i) => setState(() => _currentIndex = i),
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.grid_view),    label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.casino),       label: 'Draw'),
      BottomNavigationBarItem(icon: Icon(Icons.history),      label: 'History'),
      BottomNavigationBarItem(icon: Icon(Icons.settings),     label: 'Settings'),
    ],
  )
  ```
- Keep `IndexedStack` with same 4 screens — unchanged
- Keep `navigateToHomeProvider` listener logic — unchanged
- Keep `_addDrawnPlayersToGame()` method — unchanged

---

### 8.3 Home Screen

**File:** `presentation/screens/home/home_screen.dart`

**AppBar (replaces CupertinoNavigationBar):**
```
AppBar(
  backgroundColor: AppColors.navbar,
  title: Column(children: [
    Text('🎱 Nazeer Gaming Club',
      style: TextStyle(fontFamily:'Syne', fontSize:16, fontWeight:FontWeight.w700,
                       color: AppColors.textPrimary)),
    Text('by Ali Abbas',
      style: TextStyle(fontSize:10, color: AppColors.textMuted)),
  ]),
  centerTitle: true,
  actions: [IconButton(icon: Icon(Icons.refresh, color: AppColors.danger), onPressed: _showNewGameDialog)],
)
```

**_AddPlayerRow:**
- `CupertinoTextField` → `TextField` with `InputDecoration`
- `fillColor: AppColors.bgCard`
- `focusedBorder` color: `AppColors.primary`
- prefixIcon: `Icon(Icons.person_add, color: AppColors.textMuted)`
- suffix clear button: `IconButton(icon: Icon(Icons.close))`
- "+" button: keep gradient Container with `AppColors.primary` → `AppColors.accent` gradient

**_PlayerListItem:**
- Keep AnimatedList + slide/fade animation — unchanged
- Left accent bar colors:
  - completed: `AppColors.warning` (gold)
  - active: `AppColors.primary` (blue)
  - other: `AppColors.border`
- Active player score: `AppColors.primary`
- Completed player: `AppColors.warning` star + score
- Remove button: `IconButton(icon: Icon(Icons.remove_circle_outline), color: AppColors.danger)`
- Card background: `AppColors.bgCard`

**_CurrentPlayerCard:**
- Background gradient: `cardGradient` (from Section 6)
- "NOW PLAYING" label: `AppColors.accent`
- Player name: `AppColors.textPrimary`
- Score number: `AppColors.primary`
- Warning badge: `AppColors.warning` background

**_GameTimerChip:**
- Background: `AppColors.bgElevated`
- Text/icon: `AppColors.accent`

**_BallGrid:**
- Keep 3D sphere styling and ball colors exactly — unchanged
- Ball label text colors:
  - Yellow ball: use `AppColors.bgPage` for text (dark on light ball)
  - All other balls: white text

**_SubtractToggle:**
- ON state: `subtractGradient` (red — keep as-is)
- OFF state: border `AppColors.border`, background `AppColors.bgCard`

**_ActionButtons:**
- "Undo" → `OutlinedButton` with `Icons.undo`, border `AppColors.border`
- "Next Player" → `ElevatedButton` with gradient decoration + `Icons.arrow_circle_right`

**Dialogs:**
- `CupertinoAlertDialog` → `AlertDialog`
  - backgroundColor: `AppColors.bgCard`
  - title style: `AppColors.textPrimary`
  - content style: `AppColors.textSecondary`
  - Cancel action: `TextButton` with `AppColors.textMuted`
  - Confirm/Destructive action: `TextButton` with `AppColors.danger`

---

### 8.4 Draw Screen

**File:** `presentation/screens/draw/draw_screen.dart`

**AppBar:** Same structure as Home Screen. Title: "Name Draw 🎲". Trailing reset icon shown conditionally.

**_AddNameRow:** Same TextField pattern as Home Screen.

**_CandidateChips:**
- Chip background: `AppColors.bgCard`
- Chip border: `AppColors.border`
- Chip text: `AppColors.textPrimary`
- Remove icon: `Icons.cancel` color `AppColors.textMuted`

**_RevealCard:**
- Gradient: `cardGradient`
- Drawn name text: `AppColors.accent` (cyan — stands out)
- Position badge: `AppColors.primary` background
- Spring animation: keep exactly — unchanged

**_DrawButton:**
- Gradient: `primaryGradient`
- Icon: `Icons.shuffle`
- Counter badge: `AppColors.bgPage` background, `AppColors.textPrimary` text

**_AddToGameButton:**
- Background: `AppColors.success`
- Icon: `Icons.play_arrow`

**_DrawnOrderList:**
- Left border: `AppColors.warning` (gold — keep same feel)
- Entry text: `AppColors.textPrimary`
- Slide-up animation: keep exactly — unchanged

**Dialog:** Same AlertDialog pattern as Home Screen.

---

### 8.5 History Screen

**File:** `presentation/screens/history/history_screen.dart`

**AppBar:** Title: "History". Trailing delete icon: `Icons.delete_outline` color `AppColors.danger` (shown only when entries exist).

**_HistoryRow:**
- Ball emoji: keep as-is
- Player name: `AppColors.textPrimary` bold
- Ball name + timestamp: `AppColors.textMuted`
- Score badge `+X`: `AppColors.success` background
- Score badge `−X`: `AppColors.danger` background
- Left border colors: replace hardcoded hex values → AppColors ball constants (see Section 7)
- Row background: `AppColors.bgCard`
- Divider: `AppColors.border`

**Empty state:**
- Icon: `Icons.history` color `AppColors.textMuted`
- Text: `AppColors.textMuted`

---

### 8.6 Settings Screen

**File:** `presentation/screens/settings/settings_screen.dart`

**AppBar:** Title: "Settings"

**_DeveloperCard:**
- Gradient background: `cardGradient`
- App name: `AppColors.textPrimary` Syne font
- "by Ali Abbas": `AppColors.accent`
- Version: `AppColors.textMuted`
- Logo image in circle: border `AppColors.primary`

**Appearance section:**
- REMOVE the dark mode toggle row entirely (app is dark mode only)
- Keep section header styling

**Game section:**
- Target score row: `Icons.flag` + label `AppColors.textPrimary`
- Score pill buttons:
  - Selected: background `AppColors.primary`, text white
  - Unselected: border `AppColors.border`, text `AppColors.textMuted`

**About section:**
- Row items: `AppColors.textPrimary` + `Icons.chevron_right` color `AppColors.textMuted`
- Divider: `AppColors.border`

**_SettingsGroup container:**
- Background: `AppColors.bgCard`
- Border: `AppColors.border`
- Border radius: 16

**About Dialog:**
```
AlertDialog(
  backgroundColor: AppColors.bgCard,
  title: Text('Nazeer Gaming Club', style: TextStyle(color: AppColors.textPrimary)),
  content: Column(children: [
    Text('by Ali Abbas', style: TextStyle(color: AppColors.accent)),
    Text('Version 1.0.0', style: TextStyle(color: AppColors.textMuted)),
  ]),
  actions: [TextButton(child: Text('Close'), onPressed: ...)],
)
```

---

## 9. Migration Order

Follow this exact order. Complete and `flutter analyze` each step before next:

```
STEP 1  → pubspec.yaml
          - uses-material-design: true
          - Remove cupertino_icons from dependencies
          - Add google_fonts: ^6.2.1

STEP 2  → core/theme/app_colors.dart
          - Update all color tokens to Electric Blue & Cyan
          - Remove isDarkMode branching — dark values always
          - Add all new constants from Section 6

STEP 3  → core/theme/app_theme.dart
          - Full rewrite to Material ThemeData
          - Remove CupertinoThemeData entirely
          - Implement darkTheme as per Section 5

STEP 4  → main.dart
          - CupertinoApp → MaterialApp
          - themeMode: ThemeMode.dark
          - Remove Firebase stub (_firebaseMessagingBackgroundHandler)
          - Keep ProviderScope, Hive init, storageRepositoryProvider override

STEP 5  → presentation/main_navigation.dart
          - CupertinoPageScaffold → Scaffold
          - Custom bottom nav → BottomNavigationBar
          - Keep all provider listeners and IndexedStack unchanged

STEP 6  → presentation/screens/splash/splash_screen.dart
          - Scaffold, dark bg, cyan glow, fix hardcoded colors

STEP 7  → presentation/screens/home/home_screen.dart
          - Full Cupertino → Material widget replacement
          - Fix all hardcoded colors

STEP 8  → presentation/screens/draw/draw_screen.dart
          - Full Cupertino → Material widget replacement
          - Fix all hardcoded colors

STEP 9  → presentation/screens/history/history_screen.dart
          - Full Cupertino → Material widget replacement
          - Fix hardcoded ball border colors

STEP 10 → presentation/screens/settings/settings_screen.dart
          - Full Cupertino → Material widget replacement
          - Remove dark mode toggle row

STEP 11 → presentation/widgets/add_player_dialog.dart
          - CupertinoAlertDialog → AlertDialog

STEP 12 → presentation/widgets/player_card.dart
          - CupertinoButton → TextButton/IconButton
          - Fix Color.withOpacity() deprecations

STEP 13 → presentation/widgets/game_analytics_widget.dart
          - Fix Color.withOpacity() deprecations only

STEP 14 → presentation/widgets/snooker_ball_button.dart
          - Fix Color.withOpacity() deprecations only

STEP 15 → FINAL CHECK
          - flutter clean
          - flutter pub get
          - flutter analyze → must show zero errors
          - Test on Android emulator:
            * Splash animation plays correctly
            * All 4 tabs navigate correctly
            * Add players, score balls, undo, next player
            * Draw screen: add names, draw, add to game
            * History shows entries
            * Settings: target score changes, about dialog
```

---

## 10. pubspec.yaml Changes

```yaml
# CHANGE:
uses-material-design: true   # was: false

# REMOVE from dependencies:
cupertino_icons: ^1.0.8

# ADD to dependencies:
google_fonts: ^6.2.1

# KEEP everything else exactly as-is:
flutter_riverpod: ^2.6.1
hive: ^2.2.3
hive_flutter: ^1.1.0
path_provider: ^2.1.5
fl_chart: ^0.70.2
intl: ^0.19.0
uuid: ^4.5.1
```

### Google Fonts usage in app_theme.dart:
```dart
import 'package:google_fonts/google_fonts.dart';

// In ThemeData:
textTheme: GoogleFonts.syneTextTheme(ThemeData.dark().textTheme).copyWith(
  bodyMedium: GoogleFonts.dmSans(color: AppColors.textSecondary),
  bodySmall:  GoogleFonts.dmSans(color: AppColors.textMuted),
),
```

---

## 11. Deprecation Fixes

Replace ALL `Color.withOpacity(x)` with `Color.withValues(alpha: x)`:

```dart
// OLD (deprecated):
color.withOpacity(0.3)

// NEW (correct):
color.withValues(alpha: 0.3)
```

Files affected:
- `core/theme/app_colors.dart`
- `presentation/screens/home/home_screen.dart`
- `presentation/screens/draw/draw_screen.dart`
- `presentation/screens/history/history_screen.dart`
- `presentation/screens/settings/settings_screen.dart`
- `presentation/widgets/player_card.dart`
- `presentation/widgets/snooker_ball_button.dart`
- `presentation/widgets/game_analytics_widget.dart`

---

## 12. Other Fixes

### Fix targetScore default discrepancy
In `data/models/game.dart` — DO NOT CHANGE. Leave the 150 default in the Hive model.
The provider already overrides it with AppConstants.defaultTargetScore (100). No change needed.

### Fix pubspec version
In `pubspec.yaml` change: `version: 0.1.0+1` → `version: 1.0.0+1`
This matches the AppConstants.appVersion displayed in UI.

### Remove Firebase stub
In `main.dart` remove:
```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
```
This is a leftover from a removed Firebase Messaging dependency. It serves no purpose.

### Unused widgets
These unused widgets exist in `presentation/widgets/`:
- `add_player_dialog.dart` — fix only (Cupertino → Material), keep file
- `player_card.dart` — fix deprecations only, keep file
- `game_analytics_widget.dart` — fix deprecations only, keep file
- `snooker_ball_button.dart` — fix deprecations only, keep file
Do NOT wire these into screens. Do NOT delete them. Fix only.

---

## Version History

| Version | Change |
|---|---|
| 1.0 | Initial migration PRD — Cupertino → Material 3 + Electric Blue & Cyan |

---

*End of Document*

---

> **App:** Nazeer Gaming Club Snooker Score Tracker
> **Migration:** iOS Cupertino → Material 3 · Electric Blue & Cyan Dark Theme
> **Tech:** Flutter · Riverpod · Hive · Material 3
> **Developed by:** Ali Abbas
> **PRD Version:** 1.0
