# Snooker App — Comprehensive Technical Summary

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SECTION 1 — APP OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- **App name (pubspec.yaml):** snooker
- **Display name (in-app):** Nazeer Gaming Club
- **Package name (pubspec.yaml):** snooker (publish_to: 'none')
- **Version:** 0.1.0+1 (pubspec), 1.0.0 (displayed in-app via AppConstants.appVersion)
- **Dart SDK constraint:** ^3.11.0
- **Target platforms:** Android, Web, Windows (project folders exist for all three; iOS folder is absent)
- **Description:** A snooker score-tracking application that lets users add up to 12 players, assign ball-based point values, track scores toward a configurable target, manage turn order, view history, run a random name draw for player ordering, and persist data locally with Hive. Branded "Nazeer Gaming Club — by Ali Abbas."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SECTION 2 — ALL SCREENS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 2.1 Splash Screen

- **File:** lib/presentation/screens/splash/splash_screen.dart
- **Purpose:** Animated splash/branding screen shown on app launch.
- **Widgets:**
  - CupertinoPageScaffold with white background
  - Animated logo image (assets/logo.png, 160×160) with elastic scale-in and fade-in
  - Animated title text "Nazeer Gaming Club" with fade-in
  - Animated byline "by Ali Abbas" with fade-in
- **User interactions:** None — purely auto-timed.
- **Behavior:** After 2800 ms, auto-navigates (pushReplacement with fade transition) to MainNavigation. Three AnimationControllers drive the sequential logo → title → byline reveal.
- **Data read/written:** None.

---

### 2.2 Home Screen (Game Screen)

- **File:** lib/presentation/screens/home/home_screen.dart
- **Purpose:** Main game play screen — add players, score points, manage turns.
- **Widgets:**
  - CupertinoNavigationBar with "🎱 Nazeer Gaming Club" title, "by Ali Abbas" subtitle, and a trailing reset (arrow_2_circlepath) icon button in destructive red
  - _AddPlayerRow: CupertinoTextField with player name input, person_badge_plus prefix icon, clear-text suffix button, and a circular gradient "+" add button
  - _SectionHeader widgets for "Players", "Current Turn", "Score" labels
  - AnimatedList of _PlayerListItem widgets (slide+fade animation) — each shows: left accent bar (gold if completed, blue if active, grey otherwise), rank number in circle, player name, score (large blue if active, gold star + score if completed), minus_circle remove button (only for non-active, non-completed players)
  - _EmptyPlayersHint: shown when no players exist — person_2_fill icon, "No Players Yet" text, instruction text
  - _CurrentPlayerCard: gradient card showing "NOW PLAYING" label, player name, large score number (64pt), and a warning badge ("X pts to go") when remaining points are within 20% of target
  - _GameTimerChip: timer icon + MM:SS elapsed time display (only visible once first score is recorded)
  - _BallGrid: 7 snooker ball buttons arranged in two rows (4 + 3), each as a 3D sphere with highlight, displaying point value and ball name
  - _SubtractToggle: animated toggle bar for subtract mode (red gradient when on, outlined when off)
  - _ActionButtons: two side-by-side action buttons — "Undo" (outlined, arrow_uturn_left) and "Next Player" (filled gradient, arrow_right_circle_fill)
- **User interactions:**
  - Type player name and tap "+" or press Enter to add a player (creates a new game automatically if none exists)
  - Tap any player row to set them as current player (only if not completed)
  - Tap minus_circle icon on non-active player to show a remove confirmation dialog (CupertinoAlertDialog)
  - Tap trailing reset icon to show "New Game" confirmation dialog — starts a new game
  - Tap any ball button to add that ball's points to the current player (or subtract if subtract mode is on)
  - Tap subtract toggle to switch between add/subtract mode
  - Tap "Undo" to revert the last score action
  - Tap "Next Player" to cycle to the next non-completed player
- **Data read:** Reads gameProvider (Game? state), settingsProvider (for default target), appColorsProvider (theme colors), gameTimerProvider (elapsed seconds)
- **Data written:** Adds players, scores points, removes players, creates new games, toggles subtract mode, undo actions — all through gameProvider.notifier

---

### 2.3 Draw Screen

- **File:** lib/presentation/screens/draw/draw_screen.dart
- **Purpose:** Random name draw feature to determine player order for a new game.
- **Widgets:**
  - CupertinoNavigationBar with "Name Draw" title and trailing reset (arrow_2_circlepath) icon (destructive red, only shown when data exists)
  - _AddNameRow: CupertinoTextField with "Enter player name..." placeholder, person_badge_plus prefix icon, clear suffix, circular gradient "+" add button (disabled during/after draw)
  - _SectionHeader for "Names to Draw", "Draw Result", "Draw Order"
  - _CandidateChips: Wrap of name chips with optional xmark_circle_fill remove buttons (removable only before draw starts)
  - _EmptyState: dice emoji (🎲) in circle, "Add at least 2 names" text, "to start a random draw" subtitle
  - _RevealCard: large gradient card showing either a shuffle icon + "Tap Draw Next…" prompt, or the last drawn name in 42pt text with position badge (#N) and sparkle emoji (✨), with a spring scale animation on reveal
  - _DrawButton: gradient button with shuffle icon, "Draw Next" text, and remaining count badge
  - _AddToGameButton: green button with play_fill icon, "Add to Game" text, and right arrow — shown only when draw is complete
  - _DrawnOrderList: numbered list of drawn names with gold accent left border and animated slide-up on each entry
- **User interactions:**
  - Type name and tap "+" or press Enter to add a candidate name (max 12, blocked during/after draw)
  - Tap xmark on a chip to remove a name (only before draw starts)
  - Tap "Draw Next" to randomly draw the next name from the pool (triggers haptic feedback via HapticFeedback.lightImpact)
  - Tap "Add to Game" (shown after all names drawn) to show confirmation dialog, then creates a new game with drawn player order and navigates to Home tab
  - Tap trailing reset icon to show "Reset Draw" confirmation dialog, clears all draw state
- **Data read:** drawProvider (DrawData state), appColorsProvider
- **Data written:** drawProvider.notifier (addName, removeName, drawNext, reset), navigateToHomeProvider (triggers navigation via MainNavigation listener), gameProvider (indirectly via MainNavigation._addDrawnPlayersToGame)

---

### 2.4 History Screen

- **File:** lib/presentation/screens/history/history_screen.dart
- **Purpose:** Displays chronological log of score and subtract actions from all games.
- **Widgets:**
  - CupertinoNavigationBar with "History" title and trailing trash icon (in error red, only shown when entries exist)
  - _EmptyState: clock icon, "No History Yet" text, "Score actions will appear here" subtitle
  - ListView.builder of _HistoryRow widgets — each row shows: ball emoji on left, player name (bold), ball color name + timestamp ("HH:MM") below, and a +X or −X badge on right. Left border is coloured to match the ball.
- **User interactions:**
  - Tap trash icon to show "Clear History" confirmation dialog — permanently deletes all history
  - Scroll through the list
- **Data read:** historyProvider (List<HistoryAction>), appColorsProvider
- **Data written:** historyProvider.notifier.clearHistory() on clear

---

### 2.5 Settings Screen

- **File:** lib/presentation/screens/settings/settings_screen.dart
- **Purpose:** App settings — dark mode toggle, default target score, about info.
- **Widgets:**
  - CupertinoNavigationBar with "Settings" title
  - _DeveloperCard: gradient card at top with logo image (assets/logo.png in circle), app name, "by Ali Abbas", and version
  - "Appearance" section: _SettingsRow with moon_fill icon and CupertinoSwitch for dark mode
  - "Game" section: _SettingsRow with flag_fill icon showing current default target score, tap to expand a _TargetScoreSelector row (animated chevron rotation)
  - _TargetScoreSelector: 4 pill buttons for target scores 100, 150, 200, 250 — selected one is filled with primary color
  - "About" section: _SettingsRow "About App" with chevron (tap shows CupertinoAlertDialog with app name, developer, version), _SettingsRow "App Version" showing "1.0.0"
  - _SettingsGroup containers with card shadow, _Divider between rows
- **User interactions:**
  - Tap dark mode switch to toggle dark/light theme (persisted)
  - Tap "Default Target Score" to expand/collapse selector
  - Tap a target score pill (100/150/200/250) to change the default target (persisted)
  - Tap "About App" to show about dialog
- **Data read:** settingsProvider (AppSettings), appColorsProvider
- **Data written:** settingsProvider.notifier.toggleDarkMode(), settingsProvider.notifier.updateDefaultTargetScore()

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SECTION 3 — NAVIGATION & ROUTING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- **Navigation approach:** Manual tab-based navigation using IndexedStack inside MainNavigation. No go_router, no named routes. The only Navigator.push/pushReplacement is the splash → MainNavigation transition.
- **Initial screen:** SplashScreen (set as `home:` in CupertinoApp)
- **After splash:** Navigator.pushReplacement to MainNavigation (replaces splash so no back-navigation to it)

**Full navigation map:**

1. **SplashScreen** → (auto 2.8s, pushReplacement with fade) → **MainNavigation**
2. **MainNavigation** contains 4 tabs via IndexedStack:
   - Tab 0: **HomeScreen** (icon: circle_grid_3x3_fill, label: "Home")
   - Tab 1: **DrawScreen** (icon: shuffle, label: "Draw")
   - Tab 2: **HistoryScreen** (icon: clock, label: "History")
   - Tab 3: **SettingsScreen** (icon: gear, label: "Settings")
3. **DrawScreen** → "Add to Game" action → sets navigateToHomeProvider to true → MainNavigation listener catches it, creates game with drawn names, resets draw, and switches to tab 0 (HomeScreen)

**Back button behavior:**
- SplashScreen: no back button (it is the initial route; push-replaces to MainNavigation)
- MainNavigation / all tabs: system back button would exit the app (no nested navigation stack within tabs). None of the tab screens push sub-routes.
- Dialogs (New Game, Remove Player, Clear History, Reset Draw, About, Add to Game): standard CupertinoAlertDialog dismiss via Cancel or background tap.

**Custom bottom navigation:**
- _CustomBottomNav: Row of 4 GestureDetector items with animated active indicator bar and label. Height: 64 + bottom safe area padding.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SECTION 4 — STATE MANAGEMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Framework:** flutter_riverpod (Riverpod 2.6.1)

### Providers and State Variables:

**1. gameProvider** — `StateNotifierProvider<GameNotifier, Game?>`
- State: `Game?` (nullable — null when no active game)
- Game fields: id (String), players (List<Player>), currentPlayerId (String?), targetScore (int), isSubtractMode (bool), createdAt (DateTime), completedAt (DateTime?), isActive (bool)
- Player fields: id (String), name (String), score (int, default 0), isCompleted (bool, default false), turnCount (int, default 0), createdAt (DateTime)
- Internal: _undoStack (List<Game>, max 20 entries for multi-step undo)
- Rebuilds: HomeScreen (entire screen), MainNavigation (for draw→game handoff), GameTimerNotifier (listens for game changes)

**2. settingsProvider** — `StateNotifierProvider<SettingsNotifier, AppSettings>`
- State: AppSettings with fields: isDarkMode (bool, default false), defaultTargetScore (int, default 100), lastModified (DateTime)
- Rebuilds: MainApp (theme switching), HomeScreen (default target), SettingsScreen (all settings display), appColorsProvider (derived)

**3. historyProvider** — `StateNotifierProvider<HistoryNotifier, List<HistoryAction>>`
- State: List<HistoryAction> sorted newest-first
- HistoryAction fields: id (String), gameId (String), actionType (ActionType enum), playerId (String?), playerName (String?), pointsChanged (int?), ballColor (String?), details (String?), timestamp (DateTime)
- ActionType enum values: score, subtract, playerAdded, playerRemoved, playerCompleted, gameReset, turnChanged
- Rebuilds: HistoryScreen

**4. drawProvider** — `StateNotifierProvider<DrawNotifier, DrawData>`
- State: DrawData with fields: candidateNames (List<String>), drawnNames (List<String>), remainingPool (List<String>), drawState (DrawState enum), lastDrawnName (String?)
- DrawState enum values: empty, ready, drawing, complete
- Rebuilds: DrawScreen, MainNavigation (for draw completion handoff)

**5. gameTimerProvider** — `StateNotifierProvider<GameTimerNotifier, int>`
- State: int (elapsed seconds since first score, starts at 0)
- Internal: Timer? _ticker (1-second interval), _trackedGameId (String?), _timerStarted (bool)
- Rebuilds: _GameTimerChip widget on HomeScreen

**6. storageRepositoryProvider** — `Provider<StorageRepository>`
- Global singleton, overridden in ProviderScope at app startup with a pre-initialized instance

**7. appColorsProvider** — `Provider<AppColors>`
- Derived from settingsProvider.isDarkMode
- Returns AppColors instance with contextual color tokens
- Rebuilds: every screen that watches it (HomeScreen, DrawScreen, HistoryScreen, SettingsScreen, MainNavigation)

**8. navigateToHomeProvider** — `StateProvider<bool>`
- Simple boolean flag; when set to true, MainNavigation listener routes to Home tab and resets it to false
- Local to draw→home navigation flow

**Global vs local state:**
- All providers above are global (accessible from anywhere via ref)
- Local state: _currentIndex in MainNavigation (tab index), _showTargetSelector in SettingsScreen, _nameController in HomeScreen and DrawScreen, _cachedPlayers + AnimatedList state in HomeScreen, _revealController animation in DrawScreen, _btnScale/_scale in various button widgets

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SECTION 5 — DATA & STORAGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Storage technology:** Hive (hive: ^2.2.3 + hive_flutter: ^1.1.0) — local NoSQL database with type adapters generated by hive_generator.

### Hive Boxes:

1. **'games'** — `Box<Game>` — stores Game objects keyed by game ID
2. **'history'** — `Box<HistoryAction>` — stores HistoryAction objects keyed by action ID
3. **'settings'** — `Box<AppSettings>` — stores a single AppSettings object under key 'settings'

### Hive Type Adapters (registered IDs):

- typeId 0: PlayerAdapter
- typeId 1: GameAdapter
- typeId 2: ActionTypeAdapter (enum)
- typeId 3: HistoryActionAdapter
- typeId 4: AppSettingsAdapter

### Keys stored in settings box:

- `'settings'` — single AppSettings object

### Data Models with all fields and types:

**Player (typeId 0):**
- id: String
- name: String
- score: int (default 0)
- isCompleted: bool (default false)
- turnCount: int (default 0)
- createdAt: DateTime

**Game (typeId 1):**
- id: String
- players: List<Player>
- currentPlayerId: String? (nullable)
- targetScore: int (default 150 in model, overridden to 100 by AppConstants.defaultTargetScore)
- isSubtractMode: bool (default false)
- createdAt: DateTime
- completedAt: DateTime? (nullable)
- isActive: bool (default true)

**ActionType (typeId 2, enum):**
- score, subtract, playerAdded, playerRemoved, playerCompleted, gameReset, turnChanged

**HistoryAction (typeId 3):**
- id: String
- gameId: String
- actionType: ActionType
- playerId: String? (nullable)
- playerName: String? (nullable)
- pointsChanged: int? (nullable)
- ballColor: String? (nullable)
- details: String? (nullable)
- timestamp: DateTime

**AppSettings (typeId 4):**
- isDarkMode: bool (default false)
- defaultTargetScore: int (default 100)
- lastModified: DateTime

### Persistence behavior:

- **Persists across sessions:** All Hive data — games, history, settings (dark mode, default target score). The active game is loaded on startup via loadActiveGame().
- **Resets on app open:** Game timer (gameTimerProvider state: int, starts at 0). Draw state (drawProvider is initialized fresh each session — in-memory only, DrawData is not persisted). The undo stack (_undoStack in GameNotifier) is in-memory only and lost on app restart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SECTION 6 — BUSINESS LOGIC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### Core scoring rules:

- 7 snooker balls with fixed point values: Yellow = 2, Green = 3, Brown = 4, Blue = 5, Pink = 6, Black = 7, Red = 10
- **NOTE:** The Red ball is assigned 10 points in this app. Standard snooker rules assign 1 point to red. This is a custom scoring system.
- Tapping a ball button adds the ball's points to the current player's score
- If subtract mode is active, the ball's points are subtracted instead
- Score is clamped: minimum -100, no explicit maximum (clamp(-100, double.infinity))
- Each score action increments the player's turnCount by 1

### Subtract mode:

- Toggled via _SubtractToggle button on HomeScreen
- When active, isSubtractMode = true on the Game object
- Ball taps subtract points instead of adding
- Visual feedback: ball buttons get a red overlay, subtract toggle turns red gradient

### Player completion (win condition):

- A player is marked as completed (isCompleted = true) when their score reaches or exceeds the game's targetScore
- When completed: a "playerCompleted" history action is recorded, the app auto-advances to the next non-completed player
- Completed players are displayed with a gold star icon and gold score text

### Game completion:

- Game.isGameComplete returns true when all players have isCompleted == true
- There is no explicit "game over" screen or special handling — completed players simply show as completed with stars

### Target scores:

- Configurable per game; predefined options: 100, 150, 200, 250 (from AppConstants.targetScores)
- Default target: 100 (from AppConstants.defaultTargetScore and AppSettings)
- Can be changed in Settings (persisted) and also at game creation

### Turn management:

- Current player is tracked by currentPlayerId on Game
- Tap a player row to manually set them as current player (only if not completed)
- "Next Player" button cycles forward through the full player list (wrapping around) to find the next non-completed player
- Auto-advance occurs after a player is marked completed

### Undo:

- Before each score action, the current Game state is pushed onto an in-memory _undoStack (max 20 entries)
- undoLastAction() pops the last snapshot, saves it to Hive, removes the last history entry for that game, and restores the state
- Undo stack is lost on app restart

### Warning threshold:

- When remaining points (targetScore - playerScore) is less than or equal to 20% of targetScore and greater than 0, a warning badge displays "X pts to go"

### Name Draw logic:

- Users add candidate names (minimum 2, maximum 12)
- "Draw Next" picks a random name from the remaining pool (using Random.nextInt)
- Names are removed from the pool as they are drawn
- Draw completes when the pool is empty
- The drawn order can be used to create a new game with players in that order via "Add to Game"
- Draw state is not persisted — resets on navigation or app restart

### Timers:

- Game timer starts ticking (1-second interval) when any player's score becomes non-zero
- Displays elapsed time in MM:SS format
- Resets to 0 when a new game is started (tracked game ID changes) or game becomes null
- Timer is purely display — not used for any game logic

### Validation rules:

- Player name must not be empty (trimmed)
- Maximum 12 players per game (AppConstants.maxPlayers)
- Minimum 1 player (AppConstants.minPlayers, though not enforced in UI)
- Minimum 2 candidate names to start a draw
- Maximum 12 candidate names in draw
- Cannot add names or remove names during/after a draw
- AddPlayerDialog widget (not used in current HomeScreen) validates minimum 2 characters for name

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SECTION 7 — ALL PACKAGES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### Dependencies:

| Package | Version | Usage in app |
|---------|---------|-------------|
| flutter (sdk) | — | Core framework |
| cupertino_icons | ^1.0.8 | iOS-style icons used throughout all screens (CupertinoIcons references) |
| flutter_riverpod | ^2.6.1 | State management — all providers and ConsumerWidget/ConsumerStatefulWidget usage |
| hive | ^2.2.3 | Local NoSQL storage — Game, Player, HistoryAction, AppSettings persistence |
| hive_flutter | ^1.1.0 | Hive Flutter integration — Hive.initFlutter() initialization |
| path_provider | ^2.1.5 | Required by hive_flutter for finding app documents directory (implicit dependency) |
| fl_chart | ^0.70.2 | Bar chart in GameAnalyticsWidget (widget exists but is not currently wired into any screen) |
| intl | ^0.19.0 | Date formatting in DateFormatter utility (DateFormat class) |
| uuid | ^4.5.1 | Generating unique IDs for games, players, and history actions (Uuid().v4()) |

### Dev Dependencies:

| Package | Version | Usage in app |
|---------|---------|-------------|
| flutter_test (sdk) | — | Testing framework (widget_test.dart exists but is default template) |
| flutter_lints | ^6.0.0 | Lint rules (analysis_options.yaml includes package:flutter_lints/flutter.yaml) |
| hive_generator | ^2.0.1 | Code generation for Hive type adapters (.g.dart files) |
| build_runner | ^2.4.13 | Build system for running hive_generator code generation |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SECTION 8 — THEME & UI STYLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### Current theme:

- Supports both **light** and **dark** modes, toggled via Settings. Default is light (isDarkMode: false).
- Theme is applied via CupertinoApp's `theme:` property, switching between AppTheme.lightTheme and AppTheme.darkTheme based on settings.isDarkMode.

### ThemeData configuration:

**Light CupertinoThemeData:**
- brightness: Brightness.light
- primaryColor: 0xFF0077CC
- scaffoldBackgroundColor: 0xFFFFFFFF
- barBackgroundColor: 0xFFFFFFFF
- textTheme primaryColor/textStyle color: 0xFF111111

**Dark CupertinoThemeData:**
- brightness: Brightness.dark
- primaryColor: 0xFF4D9FFF
- scaffoldBackgroundColor: 0xFF0D1117
- barBackgroundColor: 0xFF161B22
- textTheme primaryColor/textStyle color: 0xFFF0F6FC

### Font family:

- No custom font declared. Uses the system default font (San Francisco on iOS/macOS, Roboto on Android, Segoe UI on Windows).

### iOS-specific (Cupertino) widgets — EVERY usage:

The entire app is built with Cupertino widgets. There are zero Material widgets (uses-material-design: false in pubspec.yaml). Key Cupertino widgets used:

- **CupertinoApp** — lib/main.dart (root widget)
- **CupertinoPageScaffold** — lib/presentation/main_navigation.dart, every screen file (splash, home, draw, history, settings)
- **CupertinoNavigationBar** — lib/presentation/screens/home/home_screen.dart, draw_screen.dart, history_screen.dart, settings_screen.dart
- **CupertinoTextField** — lib/presentation/screens/home/home_screen.dart (_AddPlayerRow), draw_screen.dart (_AddNameRow), widgets/add_player_dialog.dart
- **CupertinoAlertDialog** — lib/presentation/screens/home/home_screen.dart (new game, remove player), draw_screen.dart (reset draw, add to game), history_screen.dart (clear history), settings_screen.dart (about), widgets/add_player_dialog.dart
- **CupertinoDialogAction** — all dialog usages listed above
- **CupertinoSwitch** — lib/presentation/screens/settings/settings_screen.dart (dark mode toggle)
- **CupertinoButton** — lib/presentation/widgets/player_card.dart (trash button)
- **CupertinoIcons** — used throughout all screens for iconography

### Platform checks:

- No Platform.isIOS, Platform.isAndroid, defaultTargetPlatform, or similar platform checks found anywhere in the codebase.

### All hardcoded color values found in code (lib/ only):

**AppTheme (lib/core/theme/app_theme.dart):**
- Light: 0xFF0077CC, 0xFFFFFFFF, 0xFFF5F8FF, 0xFF111111, 0xFF555555
- Dark: 0xFF4D9FFF, 0xFF0D1117, 0xFF161B22, 0xFFF0F6FC, 0xFF8B949E
- Balls: 0xFFFFD700, 0xFF22C55E, 0xFF92400E, 0xFF3B82F6, 0xFFEC4899, 0xFF1F2937, 0xFFEF4444

**AppColors (lib/core/theme/app_colors.dart):**
- background: 0xFF0D1117 / 0xFFF2F2F7
- surface: 0xFF161B22 / 0xFFFFFFFF
- primary: 0xFF4D9FFF / 0xFF0077CC
- primaryDark: 0xFF3A7AC8 / 0xFF005FA3
- accent: 0xFF4D9FFF / 0xFF00AAFF
- textPrimary: 0xFFF0F6FC / 0xFF111111
- textSecondary: 0xFF8B949E / 0xFF555555
- divider: 0xFF30363D / 0xFFE0E0E0
- navBar: 0xFF161B22 / 0xFFF8F8F8
- cardGradientStart: 0xFF1A2744 / 0xFFEBF4FF
- cardGradientEnd: 0xFF0F1E3A / 0xFFDBEEFF
- success: 0xFF22C55E
- error: 0xFFEF4444
- warning: 0xFFF59E0B
- Ball colours (same as AppTheme)

**Inline hardcoded colors in screens:**
- 0xFF00AAFF — gradient endpoint (home_screen, draw_screen)
- 0xFFF59E0B — gold/warning accent for completed players, warning badge, drawn order accent (home_screen, draw_screen)
- 0xFFB8860B — dark gold for yellow ball label text (home_screen)
- 0xFFEF4444, 0xFFDC2626 — subtract mode gradient (home_screen)
- 0xFFFFFFFF — splash background (splash_screen)
- 0xFF0077CC — splash title text color (splash_screen)

**Inline hardcoded colors in history_screen (ball border colors):**
- 0xFFFFDD00 (yellow), 0xFF33FF77 (green), 0xFFD2691E (brown), 0xFF4D9FFF (blue), 0xFFFF66CC (pink), 0xFF888888 (black), 0xFFFF5555 (red)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SECTION 9 — ASSETS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### Assets declared in pubspec.yaml:

- `assets/` (entire directory)

### Asset files that actually exist in assets/ folder:

- `assets/logo.png`

### Fonts declared:

- None. No fonts section in pubspec.yaml.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SECTION 10 — FOLDER STRUCTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   └── utils/
│       └── date_formatter.dart
├── data/
│   ├── models/
│   │   ├── app_settings.dart
│   │   ├── app_settings.g.dart
│   │   ├── game.dart
│   │   ├── game.g.dart
│   │   ├── history_action.dart
│   │   ├── history_action.g.dart
│   │   ├── player.dart
│   │   ├── player.g.dart
│   │   └── snooker_ball.dart
│   └── repositories/
│       └── storage_repository.dart
└── presentation/
    ├── main_navigation.dart
    ├── providers/
    │   ├── draw_provider.dart
    │   ├── game_provider.dart
    │   ├── game_timer_provider.dart
    │   ├── history_provider.dart
    │   └── settings_provider.dart
    ├── screens/
    │   ├── draw/
    │   │   └── draw_screen.dart
    │   ├── history/
    │   │   └── history_screen.dart
    │   ├── home/
    │   │   └── home_screen.dart
    │   ├── settings/
    │   │   └── settings_screen.dart
    │   └── splash/
    │       └── splash_screen.dart
    └── widgets/
        ├── add_player_dialog.dart
        ├── game_analytics_widget.dart
        ├── player_card.dart
        └── snooker_ball_button.dart
```

### Purpose of each file:

- **main.dart** — App entry point; initializes Hive, sets up ProviderScope, defines CupertinoApp root widget with theme switching
- **core/constants/app_constants.dart** — App-wide constants: app name/version, ball point values, target scores, player limits, warning threshold, storage keys
- **core/theme/app_theme.dart** — CupertinoThemeData definitions for light and dark modes; static ball colour constants
- **core/theme/app_colors.dart** — Design-token colour system (AppColors class) providing contextual colours based on dark/light mode, semantic colours, ball colours, and shadow helpers
- **core/utils/date_formatter.dart** — Date/time formatting utility using intl package (absolute and relative formats)
- **data/models/app_settings.dart** — Hive model for app settings (dark mode, default target score)
- **data/models/app_settings.g.dart** — Generated Hive adapter for AppSettings
- **data/models/game.dart** — Hive model for a game (players, target score, subtract mode, active state)
- **data/models/game.g.dart** — Generated Hive adapter for Game
- **data/models/history_action.dart** — Hive model for history actions (scoring, player events) and ActionType enum
- **data/models/history_action.g.dart** — Generated Hive adapters for HistoryAction and ActionType
- **data/models/player.dart** — Hive model for a player (name, score, completion status, turn count)
- **data/models/player.g.dart** — Generated Hive adapter for Player
- **data/models/snooker_ball.dart** — SnookerBall enum with extension providing points, colour, and display name for each ball
- **data/repositories/storage_repository.dart** — Hive storage abstraction layer; initializes boxes, provides CRUD for games, history, and settings
- **presentation/main_navigation.dart** — Tab-based navigation shell with IndexedStack and custom bottom navigation bar; handles draw→game handoff
- **presentation/providers/draw_provider.dart** — Riverpod state management for the name draw feature (add/remove names, random draw, reset)
- **presentation/providers/game_provider.dart** — Riverpod state management for the active game (create, add/remove players, score, undo, turn management)
- **presentation/providers/game_timer_provider.dart** — Riverpod provider for elapsed game time (starts on first score, resets on new game)
- **presentation/providers/history_provider.dart** — Riverpod provider for history action list (loads from Hive, supports reload and clear)
- **presentation/providers/settings_provider.dart** — Riverpod provider for app settings (dark mode, target score); also hosts storageRepositoryProvider and appColorsProvider
- **presentation/screens/draw/draw_screen.dart** — Draw screen UI: name entry, candidate chips, reveal card, draw button, drawn order list; also defines navigateToHomeProvider
- **presentation/screens/history/history_screen.dart** — History screen UI: list of score/subtract actions with ball emojis, badge colours, and clear option
- **presentation/screens/home/home_screen.dart** — Home/game screen UI: player management, current player card, ball grid, subtract toggle, action buttons, game timer
- **presentation/screens/settings/settings_screen.dart** — Settings screen UI: developer card, dark mode, target score selector, about dialog
- **presentation/screens/splash/splash_screen.dart** — Animated splash screen with logo, title, and byline
- **presentation/widgets/add_player_dialog.dart** — Reusable CupertinoAlertDialog for adding a player with name validation (not used in current HomeScreen — HomeScreen uses inline text field instead)
- **presentation/widgets/game_analytics_widget.dart** — Game analytics card with stats grid and fl_chart bar chart of player progress (not wired into any screen currently)
- **presentation/widgets/player_card.dart** — Reusable player card widget with progress bar (not used in current HomeScreen — HomeScreen uses _PlayerListItem instead); also contains a custom LinearProgressIndicator implementation
- **presentation/widgets/snooker_ball_button.dart** — Reusable snooker ball button widget (not used in current HomeScreen — HomeScreen uses inline _BallButton instead)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SECTION 11 — KNOWN ISSUES / OBSERVATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### Deprecation warnings:

- `Color.withOpacity()` is used extensively throughout the codebase. In newer versions of Flutter (3.27+), this is deprecated in favor of `Color.withValues()`. Found in: app_colors.dart, home_screen.dart, draw_screen.dart, history_screen.dart, settings_screen.dart, player_card.dart, snooker_ball_button.dart, game_analytics_widget.dart.

### TODO / FIXME comments:

- NONE found in any source file in lib/.

### Platform-specific code that may cause issues on Android:

- The entire app is built with CupertinoApp and Cupertino widgets (CupertinoPageScaffold, CupertinoNavigationBar, CupertinoTextField, CupertinoSwitch, CupertinoAlertDialog, etc.). While these will render on Android, they will look like an iOS app rather than following Material Design conventions. This is by design but notable.
- `uses-material-design: false` is set in pubspec.yaml. There are no Material icons used; all icons are CupertinoIcons. If any Material icon were referenced, it would fail.
- `HapticFeedback.lightImpact()` is used in draw_screen.dart. This works on Android with varying degrees of hardware support.
- The splash screen background is hardcoded to white (0xFFFFFFFF) regardless of dark mode setting.

### Packages that are iOS-only or may cause Android issues:

- None of the packages are iOS-only. All (hive, riverpod, fl_chart, intl, uuid, path_provider, cupertino_icons) are cross-platform.

### Unused widgets/code:

- **add_player_dialog.dart** — Defines AddPlayerDialog with name validation, but the current HomeScreen does not use it. Player addition is handled inline via _AddPlayerRow.
- **game_analytics_widget.dart** — Fully implemented analytics/chart widget using fl_chart, but it is not imported or rendered in any screen. The fl_chart dependency is only used here.
- **player_card.dart** — Defines a PlayerCard with progress bar, but the current HomeScreen uses its own _PlayerListItem widget instead. Also defines a custom LinearProgressIndicator class.
- **snooker_ball_button.dart** — Defines SnookerBallButton, but the current HomeScreen uses its own _BallButton with 3D sphere styling instead.

### Hardcoded values that should be constants:

- Gold accent colour 0xFFF59E0B is hardcoded in home_screen.dart (lines 419, 504, 511, 708, 715) and draw_screen.dart (line 793). It matches AppColors.warning but is repeated as raw Color values rather than referencing the constant.
- Gradient blue endpoint 0xFF00AAFF is hardcoded in home_screen.dart (line 374, 1121) and draw_screen.dart (lines 357, 639). It matches AppColors.accent (in light mode) but is hardcoded.
- Subtract mode red gradient colours 0xFFEF4444 and 0xFFDC2626 are hardcoded in home_screen.dart (line 996).
- History screen ball border colours (0xFFFFDD00, 0xFF33FF77, 0xFFD2691E, 0xFF4D9FFF, 0xFFFF66CC, 0xFF888888, 0xFFFF5555) are hardcoded in _HistoryRow._borderColor() and differ from the ball colours in AppTheme/AppColors.
- Splash screen title colour 0xFF0077CC is hardcoded rather than referencing AppTheme.lightPrimary.
- Ball label dark gold colour 0xFFB8860B is hardcoded in _BallButton for yellow ball text.
- Player score clamp lower bound -100 is hardcoded in game_provider.dart scorePoints().
- Undo stack limit of 20 is hardcoded in game_provider.dart.
- Maximum 12 players/candidates limit is hardcoded in some draw_provider checks and also defined in AppConstants.maxPlayers.
- Animation durations (2800ms splash, 400ms transitions, 300ms list animations, etc.) are hardcoded throughout.
- The `_firebaseMessagingBackgroundHandler` stub in main.dart guards against stale Firebase Messaging callbacks from a previously installed version. Firebase Messaging is not used in this build.

### Version discrepancy:

- pubspec.yaml declares version 0.1.0+1, but AppConstants.appVersion reports "1.0.0" which is displayed in the UI.

### Game model default targetScore discrepancy:

- The Game model constructor defaults targetScore to 150, while AppConstants.defaultTargetScore is 100 and AppSettings also defaults to 100. In practice, games created through the provider use the settings value (100), but the model's own default of 150 is inconsistent.

### Duplicate project folders:

- The workspace contains three copies of the lib source: the main `lib/`, a `snooker/lib/` subfolder, and a `_zip_preview/snooker/lib/` folder. The main `lib/` at the root is the active codebase.
