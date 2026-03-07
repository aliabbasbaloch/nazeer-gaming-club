# 🎱 Nazeer Gaming Club
## Product Requirements Document
### Feature: Name Draw Screen
> Developed by **Ali Abbas** · Version 1.0 · March 2026 · Status: Draft

---

## Document Info

| Field | Value |
|-------|-------|
| **Document Title** | PRD — Name Draw Screen |
| **App** | Nazeer Gaming Club (iOS Flutter) |
| **Author** | Ali Abbas |
| **Version** | 1.0 |
| **Date** | March 2026 |
| **Status** | Draft — Pending Review |
| **Platform** | iOS (Flutter / Cupertino) |

---

## 1. Overview

The Name Draw screen is a new tab in the Nazeer Gaming Club snooker tracker app. It allows users to enter up to 12 player names, then randomly draw them one by one to determine a play order. Once all names have been drawn, users can send the full ordered list directly into a new game session on the Home screen — skipping manual name entry entirely.

This feature removes the need to manually decide who plays first and makes the pre-game setup faster, fairer, and more exciting, especially when multiple players are competing.

---

## 2. Goals & Success Criteria

### 2.1 Primary Goals

- Provide a fun, animated random name draw experience before a game begins.
- Allow up to 12 player names to be entered and drawn in a randomised order.
- Let the drawn order be sent directly to the Home screen as a new game session.
- Keep the UI consistent with existing Cupertino design language and the app's colour system.

### 2.2 Success Criteria

- A user can enter names, draw them one by one, and start a game in under 60 seconds.
- The random draw is visually engaging (animation/reveal) and feels premium.
- "Add to Game" correctly passes all drawn names to the Home screen and resets any existing session.
- The screen respects the existing dark/light mode setting from Settings.

---

## 3. User Stories

| ID | As a user, I want to... | So that... |
|----|------------------------|-----------|
| **US-01** | Enter player names into a dedicated draw screen | I can prepare all names before starting the draw. |
| **US-02** | Tap a button to randomly reveal one name at a time | The draw feels exciting and fair for everyone watching. |
| **US-03** | See all drawn names listed in order as they are revealed | Everyone can see who plays in which position. |
| **US-04** | Tap "Add to Game" once all names are drawn | I can start a new game instantly with the drawn order. |
| **US-05** | Reset the draw and start over at any point | I can correct mistakes or re-draw if needed. |

---

## 4. Screen Design & UI Specification

### 4.1 Navigation & Tab Bar

A new fourth tab named **"Draw"** with a 🎲 dice icon is added to the bottom navigation bar. The tab bar now reads:

```
┌──────────┬──────────┬──────────┬──────────┐
│  🏠 Home │  🎲 Draw │ 🕐 History│ ⚙ Settings│
└──────────┴──────────┴──────────┴──────────┘
```

The Draw tab uses the same `CupertinoTabBar` styling as all other tabs.

---

### 4.2 Navigation Bar (Top)

```
┌─────────────────────────────────┐
│         Name Draw          [↺]  │
└─────────────────────────────────┘
```

Displays the title **"Name Draw"** centred in the nav bar. A reset icon (↺) sits on the right — tapping it shows a Cupertino confirmation dialog to clear all names and drawn results.

---

### 4.3 Name Entry Row

Identical in layout to the Add Player row on the Home screen for visual consistency:

```
┌──────────────────────────────┬──────┐
│ 👤+ Enter player name...  [✕]│  (+) │
└──────────────────────────────┴──────┘
```

- A text field with placeholder `"Enter player name..."` and a ✕ clear button inside.
- A sky-blue gradient **+** button on the right to add the name.
- The **+** button turns grey and becomes disabled once 12 names have been added.
- Names entered here are **not yet players** — they are candidates for the draw.

---

### 4.4 Candidate Names List

Shows all entered names as simple **pill-shaped chips** arranged in a scrollable wrap/grid:

```
┌──────────┐ ┌──────────┐ ┌──────────┐
│  Ali  ✕  │ │ Nazeer ✕ │ │ Usman  ✕ │
└──────────┘ └──────────┘ └──────────┘
```

Each chip displays:
- The player name in bold.
- A small ✕ button to remove that name — **only visible before the draw starts**.

Once the draw starts (first Draw tap), the remove buttons disappear and chips become non-interactive.

---

### 4.5 Draw Button

A large, prominent primary action button centred below the candidate list:

| State | Label & Appearance |
|-------|-------------------|
| **Ready (≥2 names)** | `"Draw Next"` — sky-blue gradient, full width, active. |
| **Disabled (<2 names)** | `"Draw Next"` — grey, disabled, 40% opacity. |
| **All drawn** | Button disappears; replaced by `"Add to Game"` button. |

When tapped, the button triggers a reveal animation for the next randomly selected name (see Section 4.6). Each tap draws exactly **one name** until all names are exhausted.

---

### 4.6 Reveal Animation & Draw Result Card

At the centre of the screen, a card (matching the "NOW PLAYING" card style from Home) displays the most recently drawn name:

```
┌─────────────────────────────────┐
│             #1                  │  ← sky-blue position badge
│                                 │
│             Ali                 │  ← font size 48, bold
│                                 │
│        ✨ (particle burst)      │
└─────────────────────────────────┘
```

- A large position number badge (e.g. **#1, #2, #3**) in sky-blue.
- The drawn name rendered in **bold at font size 48**.
- A **spring-scale animation** — card scales from `0.5 → 1.1 → 1.0` with a 120fps bounce curve.
- A subtle **confetti or particle burst** behind the card on each new draw.

If no draw has happened yet, the card shows a placeholder: `"Tap Draw Next to reveal the first name"`.

---

### 4.7 Drawn Order List

Below the reveal card, a scrollable list shows all drawn names in order:

```
DRAW ORDER
─────────────────────────────────────
│ ██ #1  Ali                        │
│ ██ #2  Nazeer                     │
│ ██ #3  Usman                      │
─────────────────────────────────────
```

Each row shows:
- A **gold-numbered badge** on the left (`#1, #2, #3...`).
- The player name.
- A **coloured left accent bar** (matching the existing player card style from Home).

Rows **animate in from the bottom** when newly added. Previously drawn names remain visible throughout.

---

### 4.8 "Add to Game" Button

Appears **only when all names have been drawn** (replaces the Draw Next button):

```
┌─────────────────────────────────┐
│       Add to Game  →            │  ← full-width, success green
└─────────────────────────────────┘
```

On tap:
1. A Cupertino confirmation dialog appears (see Section 9).
2. On confirm: all drawn names are passed to `gameProvider` in drawn order, a new game session is started, and the app navigates to the **Home tab**.
3. The Draw screen resets to its initial empty state.

---

### 4.9 Empty State

When no names have been added yet:

```
         🎲
   Add at least 2 names
      to start a draw.
```

A centred illustration with helper text is displayed.

---

## 5. Screen States

| State | Description |
|-------|-------------|
| **Empty** | No names entered. Empty state illustration shown. Draw button disabled. |
| **Ready** | 1+ names entered but draw not started. Names shown as chips. Draw button active if ≥2 names. |
| **Drawing** | Draw in progress. Some names revealed. Remove chips hidden. Draw Next button active. |
| **Complete** | All names drawn. Full order list visible. "Add to Game" button shown. Draw Next gone. |

---

## 6. Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| **FR-01** | User can type a name and tap + to add it to the candidate list. | 🔴 Must Have |
| **FR-02** | A maximum of 12 names can be added; + disables at the limit. | 🔴 Must Have |
| **FR-03** | User can remove a candidate name (before draw starts only). | 🔴 Must Have |
| **FR-04** | Draw Next button is disabled if fewer than 2 names are in the list. | 🔴 Must Have |
| **FR-05** | Each tap of Draw Next randomly picks one un-drawn name from the remaining pool. | 🔴 Must Have |
| **FR-06** | The reveal card animates in with a spring/bounce at 120fps on each draw. | 🔴 Must Have |
| **FR-07** | Drawn names appear in an ordered list below the reveal card, persisting across draws. | 🔴 Must Have |
| **FR-08** | Once all names are drawn, Draw Next disappears and "Add to Game" appears. | 🔴 Must Have |
| **FR-09** | "Add to Game" shows a Cupertino confirmation dialog before proceeding. | 🔴 Must Have |
| **FR-10** | On confirmation, drawn names are passed to `gameProvider` in drawn order as a new session. | 🔴 Must Have |
| **FR-11** | After "Add to Game", the app navigates to the Home tab automatically. | 🔴 Must Have |
| **FR-12** | After sending to game, the Draw screen resets to its empty initial state. | 🔴 Must Have |
| **FR-13** | The reset (↺) button clears all names and drawn results after confirmation. | 🔴 Must Have |
| **FR-14** | The screen respects the global dark/light mode setting from the Settings provider. | 🔴 Must Have |
| **FR-15** | Duplicate names are allowed (two players can share a name). | 🟡 Should Have |
| **FR-16** | A subtle particle/confetti burst animates behind the reveal card on each draw. | 🟢 Nice to Have |
| **FR-17** | A haptic feedback tap fires on each Draw Next interaction (light impact). | 🟢 Nice to Have |

---

## 7. State Management

A new Riverpod provider, **`drawProvider`**, will manage the Name Draw screen state:

| Property | Type | Description |
|----------|------|-------------|
| `candidateNames` | `List<String>` | All names entered by the user |
| `drawnNames` | `List<String>` | Names drawn so far, in order |
| `remainingPool` | `List<String>` | Names not yet drawn (unordered) |
| `drawState` | `DrawState (enum)` | `empty \| ready \| drawing \| complete` |
| `lastDrawnName` | `String?` | The name shown on the reveal card |

**Exposed methods:** `addName()`, `removeName()`, `drawNext()`, `addToGame()`, `reset()`

> The `drawProvider` does **not** persist to `shared_preferences` — draw state is ephemeral and resets each session.

---

## 8. Design System Alignment

All colours, typography, and components must use the existing design token system:

| Token | Light | Dark |
|-------|-------|------|
| **Primary (Draw Next button)** | Sky Blue `#007AFF` | Sky Blue `#0A84FF` |
| **Draw rank badge** | Gold `#F59E0B` | Gold `#F59E0B` |
| **Add to Game button** | Success Green `#34C759` | Success Green `#34C759` |
| **Reveal card background** | Off-white `#F2F2F7` | Elevated dark `#2C2C2E` |
| **Candidate chip background** | Off-white `#F2F2F7` | Elevated dark `#2C2C2E` |
| **Disabled button** | Grey `#8E8E93` at 40% opacity | Same |
| **Animations** | 120fps spring/bounce (same as ball tap) | Same |

All UI is built exclusively with **Cupertino widgets** — no Material Design anywhere.

---

## 9. Dialogs

Both dialogs use `CupertinoAlertDialog` to match the existing app style.

### Reset Confirmation
```
┌─────────────────────────────┐
│         Reset Draw          │
│  This will clear all names  │
│  and the current draw.      │
│  Continue?                  │
│                             │
│    [Cancel]   [Reset]       │
│               (destructive) │
└─────────────────────────────┘
```

### Start New Game Confirmation
```
┌──────────────────────────────────┐
│         Start New Game           │
│  This will replace the current   │
│  game with the drawn player      │
│  order. Continue?                │
│                                  │
│    [Cancel]    [Start Game]      │
│                (destructive)     │
└──────────────────────────────────┘
```

---

## 10. Out of Scope (v1.0)

- Saving or persisting draw history across app sessions.
- Importing names from a previous game's player list automatically.
- Custom draw animations or themes.
- Drawing in bracket / tournament format.
- Sound effects during the draw (may be added in a future audio update).

---

## 11. Open Questions

| # | Question |
|---|---------|
| 1 | Should duplicate player names be blocked with a warning, or silently allowed? |
| 2 | Should the Draw tab icon use 🎲 (dice) or 🎯 (target) or a custom snooker-themed icon? |
| 3 | Should "Add to Game" set the first drawn name as the active player automatically, or leave it for the user to tap? |
| 4 | Should there be a minimum of 2 names enforced, or allow drawing with just 1? |

---

## 12. Sign-off

| Role | Name | Status |
|------|------|--------|
| Developer / Product Owner | Ali Abbas | ⏳ Pending |

---

*Nazeer Gaming Club — Name Draw PRD · Developed by Ali Abbas · v1.0 · March 2026*
