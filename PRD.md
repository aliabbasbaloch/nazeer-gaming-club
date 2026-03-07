App Name

Snooker Score Tracker

App Overview

I want to build a fully native Flutter mobile application for tracking snooker scores in real time.

The app must be 100% iOS-native in look and behavior, using Cupertino (iOS-style) widgets, navigation, and icons only.
The Material library must be completely disabled.

There is no backend and no authentication.
All game data must be stored locally on the device and work fully offline.

Splash Screen

A smooth splash screen when the app launches

Displays my logo in the center

Clean white background with subtle fade-in / scale animation

Must feel premium and smooth (target 120fps animations)

Navigation Structure

Bottom Navigation Bar (iOS-style)

Tabs:

Home

History

Settings

Navigation must be minimal, smooth, and completely native.

Home Screen

This is the main gameplay screen.

Features:

Add players (maximum 12 players)

Remove players

Tap on a player to set as current active player

Display:

Current player name

Current player score

Remaining score indicator when close to target

Scoring System:

Snooker ball buttons with fixed points:

Yellow (2)

Green (3)

Brown (4)

Blue (5)

Pink (6)

Black (7)

Red (10)

Tapping a ball:

Adds points to the current player

Subtract Mode:

Toggle button

When enabled, ball taps subtract points instead of adding

Target Score:

Selectable target score:

100

150 (default)

200

250

When a player reaches or exceeds the target:

Mark player as completed

Automatically switch to the next active (non-completed) player

Show remaining points warning only when remaining score is 20% or less of the target

Turn Controls:

Button to move to the next active player

Completed players must be skipped automatically

History Screen

This screen displays the complete gameplay history.

Features:

Store and show:

All scoring actions

Subtracted scores

Player additions and removals

Target completions

New game resets

Each history item should include:

Player name

Action type

Points added or removed

Timestamp

History should be displayed in reverse chronological order

Filters:

Filters placed below the AppBar

Examples:

Scoring actions only

Player actions only

Completion events

Date-based filters

Analytics & Visualization:

A graph / chart for data visualization

Analytics examples:

Total points scored per player

Number of turns

Game progress overview

Purpose is to allow basic gameplay analytics and insights

Settings Screen

The Settings screen contains basic application options.

Features:

Dark mode / Light mode toggle

Target score default selection

Terms & Conditions

About application

App version and developer info

Clean iOS-style list layout

Design & UI Requirements

Default iOS color combination:

Sky Blue

White

Black

Clean, minimal, premium iOS-native UI

Very smooth transitions and animations (target 120fps)

Fully responsive layout

No Material Design widgets

Use Cupertino widgets and icons only

Technical Constraints

Flutter only

iOS-native UI across all platforms

No backend

No authentication

Local storage only

Clean, maintainable, and scalable code

High performance and smooth UX