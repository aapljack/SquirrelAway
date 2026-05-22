# Squirrel Away

A tiny menu bar utility for macOS that automatically hides other apps when you bring one forward — so you can focus on what's actually in front of you.

## What it does

When you switch to an app, Squirrel Away hides everything else (the same as pressing ⌘H on each one). It lives quietly in your menu bar with no dock icon and no main window.

## Features

- **Auto-hide on app switch** — bring any app forward and the others hide themselves away automatically
- **Exclusion list** — pick apps that should never be hidden (your music player, chat app, whatever you always want visible)
- **Finder-only mode** — optionally restrict hiding to only fire when Finder comes forward, leaving other app switches untouched
- **Shift to override** — hold Shift while switching apps to skip the hiding behavior just that once
- **Launch at login** — optional, off by default
- **No dock icon, no clutter** — pure menu bar app

## Installation

Squirrel Away is currently distributed as source — build it yourself in Xcode.

1. Clone this repo
2. Open `Squirrel Away.xcodeproj` in Xcode 16 or later
3. Build and run (⌘R) — or archive and export a release build to drop into `/Applications`

The app is unsigned for now, so on first launch macOS will ask you to right-click → Open to bypass the unidentified-developer warning.

## Requirements

- macOS 13 (Ventura) or later
- Xcode 16 or later to build from source

## Tech

Built with SwiftUI, using `MenuBarExtra` for the menu bar presence and `NSWorkspace` notifications to detect app activation. Settings persist via `@AppStorage` and `UserDefaults`. Launch at login uses `SMAppService`.

No accessibility permissions required — hiding works via `NSRunningApplication.hide()`, the same API behind ⌘H.

## About this project

Squirrel Away is a vibe-coded project built with the help of Claude Code. It's a replacement for ASM, a Mac utility built by [Frank Vercruesse](https://www.macintoshrepository.org/12014-asm-application-switcher-menu-) that I have relied on for years. The feature I use  most is the single application mode. It has become in integral part of my daily computing life. With each macOS upgrade I fear ASM will finally stop working. Luckily, it has not, but it is showing its age. So my goal was to recreate the feature of this app that I use the most and build it using modern Mac code.

Bug reports and suggestions welcome via Issues.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
