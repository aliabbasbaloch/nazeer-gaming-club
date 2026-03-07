# 🎱 Nazeer Gaming Club — App Screen Guide

> A premium iOS-native Flutter snooker score tracker, built by **Ali Abbas**.
> All data is stored locally — no internet, no login required.

---

## 1. Splash Screen

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│           [  LOGO  ]            │
│        (fades in + scales)      │
│                                 │
│       Clean white background    │
│                                 │
└─────────────────────────────────┘
```

When the app launches you see a **clean white screen** with your club logo centred on it.  
The logo smoothly **fades in and scales up** with a premium 120fps animation before the main UI appears.

---

## 2. Bottom Navigation Bar

```
┌──────────┬──────────┬──────────┐
│  🏠 Home │ 🕐 History│ ⚙ Settings│
└──────────┴──────────┴──────────┘
```

Three tabs sit at the bottom of every screen in a native iOS-style tab bar:

| Tab | Icon | Purpose |
|-----|------|---------|
| **Home** | 🏠 | Live gameplay & scoring |
| **History** | 🕐 | Full log of every scoring action |
| **Settings** | ⚙ | Dark mode, target score, about |

---

## 3. Home Screen — Live Gameplay

### 3a. Navigation Bar

```
┌─────────────────────────────────┐
│   🎱 Nazeer Gaming Club    [↺]  │
│        by Ali Abbas             │
└─────────────────────────────────┘
```

- The title shows the club name and developer credit.
- The **↺ (reset) button** on the right opens a confirmation dialog to start a new game.

---

### 3b. Add Player Row

```
┌──────────────────────────────┬──────┐
│ 👤+ Enter player name...  [✕]│  (+) │
└──────────────────────────────┴──────┘
```

- Type a player's name in the text field and tap the **+ button** (sky-blue gradient circle) to add them.
- Up to **12 players** can be added. The + button turns grey when the limit is reached.
- The ✕ inside the field clears the text instantly.

---

### 3c. Players Section

```
PLAYERS
─────────────────────────────────────
│ ██ 1  Ali                     142 │  ← active player (blue border, large score)
│ ██ 2  Nazeer        18  [−]       │
│ ██ 3  Usman    ⭐  150             │  ← completed (gold star, amber score)
─────────────────────────────────────
```

Each player card shows:

- A **coloured left accent bar**: blue = active turn, gold = completed, grey = waiting
- A **rank number** badge (1, 2, 3…)
- The player's **name**
- Their current **score** (large and bold for the active player)
- A **⭐ gold star** next to their score when they have completed the target
- A **− (remove) button** on inactive, non-completed players

Tap any non-completed player card to **make them the active player**.  
Cards animate in from the right when added and slide out when removed.

---

### 3d. Current Turn Card

```
┌─────────────────────────────────┐
│         NOW PLAYING             │
│            Ali                  │
│                                 │
│             142                 │  ← huge score number
│                                 │
│   ⚠  8 pts to go               │  ← warning badge (shows when ≤20% remains)
└─────────────────────────────────┘
```

A gradient card showing:
- **"NOW PLAYING"** label with the active player's name
- Their score displayed in large, bold numerals (font size 64)
- An **amber warning badge** (⚠ X pts to go) that appears only when the player is within the final 20% of the target

If no player is selected yet, the card shows *"Tap a player to start"*.

---

### 3e. Game Timer Chip

```
         ⏱  00:04:32
```

A small pill-shaped chip just below the current turn card displays the **elapsed game time** in `HH:MM:SS` format.  
It only appears once the game has started (timer > 0).

---

### 3f. Score Section — Ball Grid

```
SCORE
─────────────────────────────────────
  🟡 2    🟢 3    🟤 4    🔵 5
     Yellow  Green  Brown   Blue

        🌸 6    ⚫ 7    🔴 10
          Pink    Black   Red
─────────────────────────────────────
```

Seven snooker ball buttons arranged in two rows (4 + 3):

| Ball | Colour | Points |
|------|--------|--------|
| Yellow | 🟡 | 2 |
| Green | 🟢 | 3 |
| Brown | 🟤 | 4 |
| Blue | 🔵 | 5 |
| Pink | 🌸 | 6 |
| Black | ⚫ | 7 |
| Red | 🔴 | 10 |

Each ball is rendered as a **3D sphere** with a highlight glint.  
Tapping a ball plays a **spring bounce animation** (scale 0.88 → 1.0) and adds the ball's points to the active player.  
When **Subtract Mode** is on the balls show a red tint and tapping deducts points instead.

---

### 3g. Subtract Toggle

```
  ➕ Add Mode       ← tap to switch →       ➖ Subtract Mode
  [●──────────]                             [──────────●]
```

A toggle row beneath the ball grid. Flipping it switches between **Add Mode** (green) and **Subtract Mode** (red), with a smooth animated slide.

---

### 3h. Action Buttons

```
┌──────────────────────┬───────────────────┐
│   ⏭  Next Player    │  🎯 150 pts target │
└──────────────────────┴───────────────────┘
```

- **Next Player** — advances the turn to the next non-completed player (completed players are skipped automatically).
- **Target Score chip** — shows the current target (100 / 150 / 200 / 250). Tapping it opens a target picker in the game context.

---

## 4. History Screen

### 4a. Navigation Bar

```
┌─────────────────────────────────┐
│           History          [🗑] │
└─────────────────────────────────┘
```

The trash icon (top-right) appears only when there is history to clear. Tapping it shows a confirmation dialog before permanently deleting all records.

---

### 4b. History List (newest first)

```
┌─────────────────────────────────────────┐
│ ████ 🔴  Ali                  │ +10 │   │  ← red left border, green badge
│         Red  •  14:32         └─────┘   │
├─────────────────────────────────────────┤
│ ████ 🔵  Nazeer               │ +5  │   │  ← blue left border
│         Blue  •  14:31        └─────┘   │
├─────────────────────────────────────────┤
│ ████ 🔴  Ali                  │ −7  │   │  ← red-error border, red badge (subtract)
│         Black  •  14:30       └─────┘   │
└─────────────────────────────────────────┘
```

Each row contains:

- A **coloured left border** matching the ball's colour (or red for a subtracted score)
- The ball's **emoji** icon
- **Player name** (bold) on top, **ball name + timestamp** below
- A **badge** on the right showing `+X` (green) or `−X` (red)

When there are no entries, an empty-state illustration shows *"No History Yet — Score actions will appear here."*

---

## 5. Settings Screen

### 5a. Developer Card

```
┌─────────────────────────────────┐
│                                 │  ← sky-blue → dark-blue gradient
│         [ LOGO 60px ]           │
│       Nazeer Gaming Club        │
│           by Ali Abbas          │
│    🎱 Premium Snooker Tracker   │
└─────────────────────────────────┘
```

A gradient card at the top of Settings showing the app logo, name, and developer credit.

---

### 5b. Appearance Section

```
APPEARANCE
┌─────────────────────────────────┐
│  🌙  Dark Mode          [  ●─] │  ← CupertinoSwitch
└─────────────────────────────────┘
```

Toggle **Dark Mode** on/off. The entire app theme switches instantly — backgrounds, cards, navigation bars, and text all update.

---

### 5c. Game Section

```
GAME
┌─────────────────────────────────┐
│  🏁  Default Target Score  150 ›│
│  ────────────────────────────── │
│  [100]  [●150]  [200]  [250]    │  ← inline selector (expands on tap)
└─────────────────────────────────┘
```

Tap **Default Target Score** to expand an inline selector. Choose from **100, 150, 200, or 250** points. The selected value is highlighted with a filled button. This value is used automatically when starting a new game.

---

### 5d. About Section

```
ABOUT
┌─────────────────────────────────┐
│  ℹ  About App              ›   │
│  ────────────────────────────── │
│  ✅  App Version        1.0.0   │
└─────────────────────────────────┘
```

- **About App** — opens a dialog confirming the app name, developer (Ali Abbas), and version.
- **App Version** — displays the current version number (e.g. `1.0.0`) as a static row.

---

## 6. Dialogs & Alerts (iOS-native)

All dialogs use `CupertinoAlertDialog` — the native iOS rounded sheet:

### New Game Confirmation
```
┌─────────────────────────────┐
│           New Game          │
│  This will end the current  │
│  game. Continue?            │
│                             │
│    [Cancel]  [Start New]    │
│              (destructive)  │
└─────────────────────────────┘
```

### Remove Player Confirmation
```
┌─────────────────────────────┐
│        Remove Player        │
│   Remove Ali from the game? │
│                             │
│    [Cancel]   [Remove]      │
│               (destructive) │
└─────────────────────────────┘
```

### Clear History Confirmation
```
┌───────────────────────────────┐
│         Clear History         │
│  This will permanently delete │
│  all history. Continue?       │
│                               │
│    [Cancel]    [Clear]        │
│                (destructive)  │
└───────────────────────────────┘
```

---

## 7. Design System at a Glance

| Token | Light | Dark |
|-------|-------|------|
| **Primary** | Sky Blue `#007AFF` | Sky Blue `#0A84FF` |
| **Background** | White `#FFFFFF` | Dark `#1C1C1E` |
| **Surface (cards)** | Off-white `#F2F2F7` | Elevated dark `#2C2C2E` |
| **Text primary** | Near-black | White |
| **Success badge** | Green `#34C759` | Green |
| **Error / subtract** | Red `#FF3B30` | Red |
| **Warning (pts to go)** | Amber `#F59E0B` | Amber |

All UI is built exclusively with **Cupertino widgets** — no Material Design anywhere.  
Animations target **120 fps** with spring/bounce curves throughout.

---

## 8. Data & Storage

- **No backend, no authentication, fully offline.**
- All game state, player scores, history entries, and settings are persisted locally using `shared_preferences`.
- Riverpod providers (`gameProvider`, `historyProvider`, `settingsProvider`) manage state reactively across the app.

---

*Snooker Score Tracker — Nazeer Gaming Club · Developed by Ali Abbas*
