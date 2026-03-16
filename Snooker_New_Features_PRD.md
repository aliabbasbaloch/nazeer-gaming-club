# Nazeer Gaming Club — New Features PRD
**App:** Snooker Score Tracker
**Developer:** Ali Abbas
**Version:** 1.0
**Base App:** Already migrated to Material 3 + Electric Blue & Cyan theme

---

## ⚠️ AGENT RULES

```
RULE 1 — ADDITIVE ONLY
  Add new features only. Do NOT modify existing business logic.
  Do NOT touch: data/models/, existing providers (except adding methods),
  existing screens (except adding new widgets to them).

RULE 2 — COLOR SCHEME
  Use AppColors constants ONLY. Never hardcode hex values.
  All widgets must work in BOTH light and dark themes.
  AppColors(isDarkMode) returns correct token per theme.

RULE 3 — HIVE MODELS
  Only these new HiveFields are allowed (additive — backward compatible):
    Player     → @HiveField(6) int? personalTarget
                 @HiveField(7) int  colorIndex
    AppSettings→ @HiveField(5) bool turnTimerEnabled
                 @HiveField(6) bool keepScreenOn
                 @HiveField(7) bool hapticEnabled
    SavedPlayer→ NEW model, typeId: 5 (new box)
  Run build_runner after any model change.
  Never change existing HiveField indices.

RULE 4 — ZERO ERRORS
  flutter analyze after every file. Fix before moving on.

RULE 5 — COMPLETE FILES ONLY
  Never write a partial file. One file at a time.

RULE 6 — HAPTIC GUARD
  All haptics wrapped in:
    void _haptic(void Function() fn) {
      if (ref.read(settingsProvider).hapticEnabled) fn();
    }
```

---

## New Packages Required

```yaml
wakelock_plus: ^1.2.8
share_plus:    ^10.0.0
```

No other new packages needed.
`ReorderableListView` and `HapticFeedback` are Flutter built-ins.

---

## Table of Contents

1. [Ball History — Per-Player Filtering](#1-ball-history--per-player-filtering)
2. [Turn Timer — 30 Second Auto-Next](#2-turn-timer--30-second-auto-next)
3. [Player Profiles — Saved Names in Draw](#3-player-profiles--saved-names-in-draw)
4. [Player Color & Avatar](#4-player-color--avatar)
5. [Rematch Button](#5-rematch-button)
6. [Spectator Mode — Screen Wake Lock](#6-spectator-mode--screen-wake-lock)
7. [Haptic Feedback](#7-haptic-feedback)
8. [APK Share from Settings](#8-apk-share-from-settings)
9. [Dynamic Target — Global + Per-Player](#9-dynamic-target--global--per-player)
10. [Player Order Reordering — Drag to Reposition](#10-player-order-reordering--drag-to-reposition)
11. [New Hive Model Fields — Summary](#11-new-hive-model-fields--summary)
12. [New Provider Methods — Summary](#12-new-provider-methods--summary)
13. [Build Order](#13-build-order)

---

## 1. Ball History — Per-Player Filtering

### What It Does
History screen mein player chips — tap karo aur sirf us player ki history dekho. Kaise unhon ne target complete kiya step by step. Auto-reset on new game / rematch.

### Filter Bar
```
Horizontal scrollable chips at top of history screen:
  [All]  [Main]  [Babar]  [Izhar]

Selected chip:
  bg: AppColors.primary, text: white
Unselected chip:
  bg: AppColors.bgElevated, border: AppColors.border, text: AppColors.textMuted
Shape: pill, padding: 8×16px
```

### Per-Player View
```
Header card:
  Player avatar (§4) + name (Syne bold)
  Score / target  e.g. "87 / 100"
  Linear progress bar — primary blue fill, bgElevated track
  Status badge: "In Progress" / "Completed ✓" / "Current Player"

Chronological list — ONLY that player's actions:
  Each row:
    Ball emoji + name          e.g. "🔴 Red"
    Points                     e.g. "+10" (success) / "−5" (danger)
    Running total after shot   e.g. "→ 87 pts"  (textMuted, small)
    Timestamp                  e.g. "2:34 PM"  (textMuted, 10px)
    Left border: 4px, ball color
  Completion row (special):
    🏆 icon, AppColors.warning border
    "Target reached! Final score: 100"
```

### Auto-Reset
```dart
// Called in gameProvider.notifier.resetGame() AND rematch():
await _storage.clearHistory(gameId);

// New StorageRepository method:
Future<void> clearHistory(String gameId) async {
  final box = Hive.box<HistoryAction>('history');
  final keys = box.values
    .where((h) => h.gameId == gameId)
    .map((h) => h.id)
    .toList();
  for (final key in keys) await box.delete(key);
}
```

### New Provider
```dart
// Selected filter player ID (null = show all)
final historyFilterProvider = StateProvider<String?>((ref) => null);
```

### Files to Change
- `presentation/screens/history/history_screen.dart` — filter chips + per-player view
- `data/repositories/storage_repository.dart` — add clearHistory()
- `presentation/providers/` — add historyFilterProvider

---

## 2. Turn Timer — 30 Second Auto-Next

### What It Does
```
Default: ON
Timer: 30 seconds per turn
No ball tapped in 30s → auto-next player
Ball tapped → timer stops (state = -1 / ✓)
  Player stays active — manual "Next Player" still needed
Timer restarts when Next Player is tapped
```

### New Provider
```dart
final turnCountdownProvider =
    StateNotifierProvider<TurnCountdownNotifier, int>((ref) {
  return TurnCountdownNotifier(ref);
});

class TurnCountdownNotifier extends StateNotifier<int> {
  TurnCountdownNotifier(this._ref) : super(30);
  final Ref _ref;
  Timer? _timer;

  void startCountdown() {
    _timer?.cancel();
    state = 30;
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (state <= 1) {
        _timer?.cancel();
        state = 0;
        _ref.read(gameProvider.notifier).nextPlayer();
        _ref.read(turnCountdownProvider.notifier).startCountdown();
        // haptic — heavy (timeout)
        HapticFeedback.heavyImpact();
      } else {
        state--;
        if (state == 10) HapticFeedback.mediumImpact(); // warning
      }
    });
  }

  void stopCountdown() {
    // ball scored — timer off, waiting for Next Player
    _timer?.cancel();
    state = -1;
  }

  void resetCountdown() {
    // Next Player tapped or reorder happened
    startCountdown();
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
}
```

### Integration Points
```
gameProvider.notifier.scoreBall()
  → end: turnCountdownProvider.notifier.stopCountdown()

gameProvider.notifier.nextPlayer()  (manual)
  → end: turnCountdownProvider.notifier.resetCountdown()

gameProvider.notifier.resetGame() / rematch()
  → turnCountdownProvider.notifier.stopCountdown()
  → state reset to 30

Home screen initState (active game exists)
  → turnCountdownProvider.notifier.startCountdown()

AppSettings.turnTimerEnabled = false
  → never call startCountdown() → widget hidden
```

### Timer UI — _TurnTimerWidget
Place inside `_CurrentPlayerCard` below "NOW PLAYING" label:

```dart
Stack(alignment: Alignment.center, children: [
  // Background ring
  SizedBox(width: 52, height: 52,
    child: CircularProgressIndicator(
      value: 1.0, strokeWidth: 4,
      color: AppColors.border,
    )),
  // Countdown ring
  SizedBox(width: 52, height: 52,
    child: CircularProgressIndicator(
      value: countdown < 0 ? 0 : countdown / 30,
      strokeWidth: 4,
      strokeCap: StrokeCap.round,
      color: countdown > 10 ? AppColors.accent    // cyan
           : countdown > 5  ? AppColors.warning   // amber
           :                   AppColors.danger,  // red
    )),
  // Center text
  Text(
    countdown == -1 ? '✓' : '$countdown',
    style: TextStyle(
      fontSize: 16, fontWeight: FontWeight.w800,
      color: countdown == -1 ? AppColors.success
           : countdown > 10  ? AppColors.textPrimary
           : countdown > 5   ? AppColors.warning
           :                    AppColors.danger,
    ),
  ),
])
```

### Settings Toggle
```
Settings → Game section
Icons.timer + "Turn Timer (30s)" + Switch
Persisted: AppSettings @HiveField(5) bool turnTimerEnabled (default: true)
```

### Files to Change
- New: `presentation/providers/turn_countdown_provider.dart`
- `presentation/screens/home/home_screen.dart` — add _TurnTimerWidget, integration
- `presentation/providers/game_provider.dart` — add stopCountdown/reset calls
- `presentation/screens/settings/settings_screen.dart` — toggle

---

## 3. Player Profiles — Saved Names in Draw

### What It Does
Draw screen mein previously used player names suggest karo. Ek tap se add — koi typing nahi.

### New Hive Model — SavedPlayer
```dart
@HiveType(typeId: 5)
class SavedPlayer extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) int    colorIndex;  // auto-assigned (§4)
  @HiveField(3) int    usageCount;
  @HiveField(4) DateTime lastUsed;
}
// Hive box: 'savedPlayers'
// Run build_runner after adding this model
```

### Auto-Save Logic
```
Player added in Draw screen → save to savedPlayers box
Player added in Home screen → also save to savedPlayers box
If name already exists → update usageCount + lastUsed
colorIndex auto-assigned: next available in palette (§4)
```

### Draw Screen UI
```
Below TextField — "Recent Players" label (textMuted, 11px, uppercase)

Horizontal scrollable row of saved player chips:
  Each chip:
    Circle avatar (player color + first letter)
    Player name (12px)
    Tap → add to candidates list instantly

Chip style:
  bg: AppColors.bgElevated
  border: AppColors.border
  already-added: border → AppColors.primary
  border radius: 20px

TextField typing → filter chips by name.startsWith(input)
Section hidden if no saved players yet
```

### Profile Management in Settings
```
Settings → new "Player Profiles" row
  Icons.people + "Player Profiles" + Icons.chevron_right
  → Opens bottom sheet:
    List of saved players (avatar + name + "X games")
    Swipe to delete
    "Clear All" button (danger, confirm dialog)
```

### New Provider
```dart
final savedPlayersProvider =
    StateNotifierProvider<SavedPlayersNotifier, List<SavedPlayer>>((ref) {
  return SavedPlayersNotifier(ref.read(storageRepositoryProvider));
});

class SavedPlayersNotifier extends StateNotifier<List<SavedPlayer>> {
  Future<void> savePlayer(String name, int colorIndex) async { ... }
  Future<void> deletePlayer(String id) async { ... }
  Future<void> clearAll() async { ... }
}
```

### Files to Change
- New: `data/models/saved_player.dart` + `saved_player.g.dart`
- New: `presentation/providers/saved_players_provider.dart`
- `presentation/screens/draw/draw_screen.dart` — suggestions UI
- `presentation/screens/settings/settings_screen.dart` — profiles row
- `main.dart` — register new Hive box/adapter

---

## 4. Player Color & Avatar

### What It Does
Har player ka ek color — list mein, history mein, draw chips mein instantly pehchano.

### Color Palette — 12 Colors
```dart
static const List<Color> playerColors = [
  Color(0xFF0066FF),  // 0  electric blue
  Color(0xFF00D4FF),  // 1  cyan
  Color(0xFF00E676),  // 2  green
  Color(0xFFFFB300),  // 3  amber
  Color(0xFFFF5252),  // 4  red
  Color(0xFFAA66FF),  // 5  purple
  Color(0xFFFF66CC),  // 6  pink
  Color(0xFFFF8C00),  // 7  orange
  Color(0xFF26C6DA),  // 8  teal
  Color(0xFF9CCC65),  // 9  lime
  Color(0xFFEF9A9A),  // 10 rose
  Color(0xFF80CBC4),  // 11 mint
];
// Add to AppColors class
```

Auto-assign: player index % 12 on add.

### Player Model Change
```dart
// data/models/player.dart — add:
@HiveField(7) int colorIndex;   // default: 0
// Run build_runner after
```

### _PlayerAvatar Widget
```dart
Widget _PlayerAvatar(Player player, {double size = 36}) {
  final color = AppColors.playerColors[player.colorIndex % 12];
  return Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: 0.2),
      border: Border.all(color: color, width: 2),
    ),
    child: Center(
      child: Text(
        player.name[0].toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.4,
          fontFamily: 'Syne',
        ),
      ),
    ),
  );
}
```

Use in: player list rows, current player card, history rows, draw chips, history filter chips.

### Color Change
```
Long press player card → inline color picker appears
12 color circles in a horizontal row
Current color: checkmark ✓
Tap → color updates instantly
```

```dart
// New provider method:
Future<void> setPlayerColor(String playerId, int colorIndex) async { ... }
```

### Files to Change
- `data/models/player.dart` — add colorIndex field
- `presentation/screens/home/home_screen.dart` — _PlayerAvatar, color picker
- `presentation/screens/history/history_screen.dart` — avatar in filter chips + rows
- `presentation/screens/draw/draw_screen.dart` — avatar in drawn order + suggestions
- `presentation/providers/game_provider.dart` — add setPlayerColor()

---

## 5. Rematch Button

### What It Does
Sab players complete hone pe game-over banner + Rematch button. Same players, same target, scores zero. Personal targets + colors preserved.

### Game Over Banner
Shown when all players `isCompleted == true`:

```dart
Container(
  margin: EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: isDarkMode ? cardGradientDark : cardGradientLight,
    border: Border.all(color: AppColors.warning, width: 1.5),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(children: [
    Text('🏆 Game Complete!', style: Syne bold, textPrimary),
    // Podium: 1st 2nd 3rd  (sorted by score desc)
    // Each: avatar + name + score
    SizedBox(height: 16),
    Row(children: [
      Expanded(child: // Rematch button
        _GradientButton(
          icon: Icons.replay,
          label: 'Rematch',
          onTap: () => ref.read(gameProvider.notifier).rematch(),
        )),
      SizedBox(width: 12),
      Expanded(child: // New Game button
        OutlinedButton(
          child: Row(children: [Icon(Icons.add), Text('New Game')]),
          onPressed: _showNewGameDialog,
        )),
    ]),
  ]),
)
```

### Rematch Provider Method
```dart
Future<void> rematch() async {
  if (state == null) return;

  await _storage.clearHistory(state!.id);

  final resetPlayers = state!.players.map((p) => p.copyWith(
    score: 0,
    isCompleted: false,
    turnCount: 0,
    // personalTarget preserved ✅
    // colorIndex preserved ✅
  )).toList();

  final newGame = state!.copyWith(
    id: _uuid.v4(),
    players: resetPlayers,
    currentPlayerId: resetPlayers.first.id,
    createdAt: DateTime.now(),
    isActive: true,
    // targetScore preserved ✅
  );

  await _storage.saveGame(newGame);
  _undoStack.clear();
  ref.read(turnCountdownProvider.notifier).resetCountdown();
  state = newGame;
}
```

### Files to Change
- `presentation/providers/game_provider.dart` — add rematch()
- `presentation/screens/home/home_screen.dart` — game over banner + rematch UI

---

## 6. Spectator Mode — Screen Wake Lock

### What It Does
Game chal raha ho toh screen auto-off nahi hogi.

### Package
```yaml
wakelock_plus: ^1.2.8
```

### Implementation
```dart
// home_screen.dart initState:
@override
void initState() {
  super.initState();
  if (ref.read(settingsProvider).keepScreenOn) {
    WakelockPlus.enable();
  }
}

@override
void dispose() {
  WakelockPlus.disable();
  super.dispose();
}
```

### Android Permission
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

### Settings Toggle
```
Settings → Game section
Icons.visibility + "Keep Screen On" + Switch
Persisted: AppSettings @HiveField(6) bool keepScreenOn (default: true)
On toggle: WakelockPlus.enable() or .disable() immediately
```

### Files to Change
- `presentation/screens/home/home_screen.dart` — wakelock enable/disable
- `presentation/screens/settings/settings_screen.dart` — toggle
- `android/app/src/main/AndroidManifest.xml` — permission

---

## 7. Haptic Feedback

### What It Does
Subtle vibrations — never annoying. Flutter built-in, no package needed.

### Vibration Map
```dart
HapticFeedback.lightImpact()    // ball tap (any ball, add or subtract)
HapticFeedback.mediumImpact()   // next player (manual), timer 10s warning
HapticFeedback.heavyImpact()    // player completes target, timer timeout
HapticFeedback.selectionClick() // filter chip tap, color picker tap
```

No haptic for: typing, scrolling, dialogs, Switch toggles.

### Guard Pattern
```dart
// In any widget that needs haptic:
void _haptic(void Function() fn) {
  if (ref.read(settingsProvider).hapticEnabled) fn();
}

// Usage:
_haptic(() => HapticFeedback.lightImpact());
```

### Integration Points
```
game_provider.scoreBall()         → lightImpact()
  + if player completes           → heavyImpact()
Next Player button tap            → mediumImpact()
turnCountdownProvider at state=10 → mediumImpact()
turnCountdownProvider at state=0  → heavyImpact()
Color picker tap                  → selectionClick()
History filter chip tap           → selectionClick()
Drag drop (reorder)               → mediumImpact()
```

### Settings Toggle
```
Settings → Game section
Icons.vibration + "Haptic Feedback" + Switch
Persisted: AppSettings @HiveField(7) bool hapticEnabled (default: true)
```

### Files to Change
- `presentation/providers/game_provider.dart` — haptic calls in scoreBall()
- `presentation/screens/home/home_screen.dart` — next player, color picker
- `presentation/screens/history/history_screen.dart` — filter chip
- `presentation/screens/settings/settings_screen.dart` — toggle

---

## 8. APK Share from Settings

### What It Does
Settings mein "Share App" — installed APK file seedha share karo. WhatsApp, Files, Bluetooth — kuch bhi.

### Package
```yaml
share_plus: ^10.0.0
```

### Platform Channel — MainActivity.kt
```kotlin
// In MainActivity.kt — add inside configureFlutterEngine():
MethodChannel(
  flutterEngine.dartExecutor.binaryMessenger,
  "com.nazeer.snooker/apk"
).setMethodCallHandler { call, result ->
  if (call.method == "getApkPath") {
    result.success(applicationInfo.sourceDir)
  } else {
    result.notImplemented()
  }
}
```

### Dart Implementation
```dart
Future<void> shareApk() async {
  try {
    const channel = MethodChannel('com.nazeer.snooker/apk');
    final String apkPath = await channel.invokeMethod('getApkPath');
    final apkFile = XFile(apkPath,
      mimeType: 'application/vnd.android.package-archive');
    await SharePlus.instance.share(ShareParams(
      files: [apkFile],
      text: 'Nazeer Gaming Club — Snooker Score Tracker\nby Ali Abbas',
    ));
  } catch (e) {
    // Fallback: copy to cache then share
    final tempDir = await getTemporaryDirectory();
    final dest = File('${tempDir.path}/NazeerGamingClub.apk');
    final src = await _getApkPath();
    await File(src).copy(dest.path);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(dest.path,
        mimeType: 'application/vnd.android.package-archive')],
    ));
  }
}
```

### Android Manifest + FileProvider
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>

<provider
  android:name="androidx.core.content.FileProvider"
  android:authorities="${applicationId}.fileprovider"
  android:exported="false"
  android:grantUriPermissions="true">
  <meta-data
    android:name="android.support.FILE_PROVIDER_PATHS"
    android:resource="@xml/file_paths"/>
</provider>
```

```xml
<!-- android/app/src/main/res/xml/file_paths.xml (create new file) -->
<?xml version="1.0" encoding="utf-8"?>
<paths>
  <cache-path name="cache" path="."/>
  <external-cache-path name="external_cache" path="."/>
</paths>
```

### Settings UI
```
Settings → About section
Icons.share + "Share App"
Subtext: "Share APK file with friends"  (textMuted, 12px)
Icons.chevron_right trailing
Tap → shareApk()
```

### Files to Change
- `android/app/src/main/kotlin/.../MainActivity.kt` — platform channel
- `android/app/src/main/AndroidManifest.xml` — permission + FileProvider
- `android/app/src/main/res/xml/file_paths.xml` — create new
- `presentation/screens/settings/settings_screen.dart` — Share App row

---

## 9. Dynamic Target — Global + Per-Player

### What It Does
```
Global target: change anytime during game → affects all players
Per-player target: optional override → only that player affected
Both: auto-complete player if score already meets new target
```

### Player Model Change
```dart
@HiveField(6) int? personalTarget;  // null = use global target
```

### Effective Target Logic
```dart
// Use everywhere instead of raw game.targetScore:
int effectiveTarget(Player p, int globalTarget) =>
    p.personalTarget ?? globalTarget;

// Completion check (replace ALL existing occurrences):
// OLD: player.score >= game.targetScore
// NEW: player.score >= effectiveTarget(player, game.targetScore)
```

### Global Target Chip — Home Screen
```
Pill below AppBar:
  🎯 Target: 100 pts  ✏️
  bg: AppColors.bgElevated, border: AppColors.border
  Tap → _ChangeTargetSheet (bottom sheet)
```

**_ChangeTargetSheet:**
```
Title: "Change Game Target"
Subtitle: "Affects all players without a personal target"
4 preset pills: 100 / 150 / 200 / 250
Custom TextField (min 10, max 999)
Warning if any player already exceeds new target:
  "X player(s) will be auto-completed"  (warning color)
"Update Target" button (primary gradient)
```

### Per-Player Target — Player Card
```
Icons.tune button on each non-completed player card
Tap → _PersonalTargetSheet (bottom sheet):
  Player avatar + name header
  Current status: "Using game target: 100 pts" OR "Personal: 150 pts"
  4 preset pills + custom TextField
    Min: player.score + 1
  "Reset to Game Target" (shown if personalTarget != null, danger outlined)
  "Set Target" button (primary gradient)
```

**Personal target badge on player card:**
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  decoration: BoxDecoration(
    color: AppColors.accent.withValues(alpha: 0.12),
    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Text('🎯 ${player.personalTarget} pts',
    style: TextStyle(fontSize: 10, color: AppColors.accent,
      fontWeight: FontWeight.w600)),
)
```

### New Provider Methods
```dart
// game_provider.dart:
Future<void> updateGlobalTarget(int newTarget) async { ... }
Future<void> setPlayerTarget(String playerId, int? personalTarget) async { ... }
```

### Files to Change
- `data/models/player.dart` — add personalTarget field
- `presentation/providers/game_provider.dart` — 2 new methods + fix all completion checks
- `presentation/screens/home/home_screen.dart` — global target chip, per-player sheet, badge

---

## 10. Player Order Reordering — Drag to Reposition

### What It Does
```
Home screen: long press (2s) player card → drag up/down → reorder turn sequence
Draw screen: long press (2s) drawn order row → drag → change draw sequence
Completed players: cannot be dragged (lock icon)
Current player: can be moved, stays current at new position
```

### No Extra Package Needed
Uses Flutter built-in `ReorderableListView`.

### Home Screen — ReorderableListView
Replace existing player ListView:

```dart
ReorderableListView(
  onReorder: (oldIndex, newIndex) {
    if (newIndex > oldIndex) newIndex--;
    ref.read(gameProvider.notifier).reorderPlayers(oldIndex, newIndex);
    _haptic(() => HapticFeedback.mediumImpact());
  },
  buildDefaultDragHandles: false,
  proxyDecorator: (child, index, animation) => Material(
    elevation: 8,
    borderRadius: BorderRadius.circular(16),
    shadowColor: AppColors.primary.withValues(alpha: 0.4),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent, width: 1.5),
        color: AppColors.bgElevated,
      ),
      child: child,
    ),
  ),
  children: [
    for (int i = 0; i < players.length; i++)
      _PlayerListItem(
        key: ValueKey(players[i].id),  // REQUIRED
        player: players[i],
        index: i,
      ),
  ],
)
```

### Drag Handle Widget
```dart
// Inside each _PlayerListItem — right side:
if (player.isCompleted)
  Icon(Icons.lock_outline, size: 14, color: AppColors.textDisabled)
else
  ReorderableDragStartListener(
    index: index,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _line(), SizedBox(height: 3),
        _line(), SizedBox(height: 3),
        _line(),
      ]),
    ),
  )

Widget _line() => Container(
  width: 14, height: 1.5,
  color: AppColors.textMuted.withValues(alpha: 0.5));
```

### Draw Screen — ReorderableListView
```dart
// _DrawnOrderList → replace with ReorderableListView
ReorderableListView(
  onReorder: (oldIndex, newIndex) {
    if (newIndex > oldIndex) newIndex--;
    ref.read(drawProvider.notifier).reorderDrawnPlayers(oldIndex, newIndex);
    _haptic(() => HapticFeedback.mediumImpact());
  },
  buildDefaultDragHandles: false,
  children: [
    for (int i = 0; i < drawnOrder.length; i++)
      _DrawnOrderItem(
        key: ValueKey(drawnOrder[i]),
        player: drawnOrder[i],
        position: i + 1,  // updates live on drag
        index: i,
      ),
  ],
)
```

### New Provider Methods
```dart
// game_provider.dart:
Future<void> reorderPlayers(int oldIndex, int newIndex) async {
  if (state == null) return;
  _undoStack.add(state!.copyWith());
  if (_undoStack.length > 20) _undoStack.removeAt(0);
  final players = List<Player>.from(state!.players);
  final moved = players.removeAt(oldIndex);
  players.insert(newIndex, moved);
  // currentPlayerId unchanged — same player, new position
  final updated = state!.copyWith(players: players);
  await _storage.saveGame(updated);
  // Reset turn timer after reorder
  ref.read(turnCountdownProvider.notifier).resetCountdown();
  state = updated;
}

// draw_provider.dart:
void reorderDrawnPlayers(int oldIndex, int newIndex) {
  final list = List<String>.from(state.drawnOrder);
  final moved = list.removeAt(oldIndex);
  list.insert(newIndex, moved);
  state = state.copyWith(drawnOrder: list);
}
```

### Files to Change
- `presentation/providers/game_provider.dart` — add reorderPlayers()
- `presentation/providers/draw_provider.dart` — add reorderDrawnPlayers()
- `presentation/screens/home/home_screen.dart` — ReorderableListView + drag handle
- `presentation/screens/draw/draw_screen.dart` — ReorderableListView for drawn order

---

## 11. New Hive Model Fields — Summary

| Model | Field | HiveField Index | Type | Default |
|---|---|---|---|---|
| `Player` | `personalTarget` | 6 | `int?` | `null` |
| `Player` | `colorIndex` | 7 | `int` | `0` |
| `AppSettings` | `turnTimerEnabled` | 5 | `bool` | `true` |
| `AppSettings` | `keepScreenOn` | 6 | `bool` | `true` |
| `AppSettings` | `hapticEnabled` | 7 | `bool` | `true` |
| `SavedPlayer` | *(new model)* | typeId: 5 | — | — |

**After any model change:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 12. New Provider Methods — Summary

All in `game_provider.dart` unless noted:

| Method | Feature |
|---|---|
| `rematch()` | §5 |
| `updateGlobalTarget(int)` | §9 |
| `setPlayerTarget(String, int?)` | §9 |
| `setPlayerColor(String, int)` | §4 |
| `reorderPlayers(int, int)` | §10 |
| `reorderDrawnPlayers(int, int)` | §10 — in draw_provider.dart |

New standalone providers:
| Provider | Feature |
|---|---|
| `historyFilterProvider` (StateProvider<String?>) | §1 |
| `turnCountdownProvider` (StateNotifierProvider<TurnCountdownNotifier, int>) | §2 |
| `savedPlayersProvider` (StateNotifierProvider) | §3 |

---

## 13. Build Order

```
PHASE 1 — Models + Codegen
  1. data/models/player.dart       → add HiveField 6, 7
  2. data/models/app_settings.dart → add HiveField 5, 6, 7
  3. data/models/saved_player.dart → new model (typeId 5)
  4. flutter pub run build_runner build --delete-conflicting-outputs
  5. main.dart → register Hive.openBox('savedPlayers')
  6. flutter analyze → zero errors

PHASE 2 — Packages + Android
  7.  pubspec.yaml → add wakelock_plus, share_plus → flutter pub get
  8.  AndroidManifest.xml → WAKE_LOCK, READ_EXTERNAL_STORAGE, FileProvider
  9.  android/.../res/xml/file_paths.xml → create
  10. MainActivity.kt → APK platform channel

PHASE 3 — New Providers
  11. turn_countdown_provider.dart → new file
  12. saved_players_provider.dart  → new file
  13. game_provider.dart → add: rematch(), updateGlobalTarget(),
      setPlayerTarget(), setPlayerColor(), reorderPlayers()
      fix ALL completion checks → effectiveTarget()
  14. draw_provider.dart → add reorderDrawnPlayers()
  15. history screen → add historyFilterProvider (inline StateProvider)
  16. flutter analyze → zero errors

PHASE 4 — Screens
  17. history_screen.dart    → filter chips, per-player view, clearHistory
  18. home_screen.dart       → _GlobalTargetChip, _TurnTimerWidget,
                               rematch banner, player avatar, color picker,
                               drag handles + ReorderableListView,
                               haptic calls, wakelock
  19. draw_screen.dart       → saved suggestions, ReorderableListView
  20. settings_screen.dart   → Turn Timer, Keep Screen On, Haptic,
                               Player Profiles, Share App toggles/rows
  21. flutter analyze → zero errors

PHASE 5 — Test
  22. Turn timer auto-next
  23. Ball scored → timer stops → manual next
  24. Global target change → auto-complete players
  25. Per-player target → override + badge
  26. Rematch → scores reset, colors/targets preserved
  27. History filter → per-player view correct
  28. Drag reorder home + draw
  29. Saved player suggestions in draw
  30. APK share opens system sheet
  31. Wakelock → screen stays on
  32. Haptics → correct intensity per action
  33. All features in BOTH light and dark theme
```

---

> **App:** Nazeer Gaming Club Snooker Score Tracker
> **Features PRD Version:** 1.0
> **Developed by:** Ali Abbas
