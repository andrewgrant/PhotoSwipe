# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
PhotoSwipe is a SwiftUI-based iOS application. This is a standard Xcode project with a simple architecture consisting of a main app entry point and a single content view.

## Development Commands

### Building and Running
- **Build**: Use Xcode's Build menu (⌘+B) or `xcodebuild` command line
- **Run**: Use Xcode's Run button (⌘+R) or build and run via `xcodebuild` with appropriate schemes

### Testing
- **Unit Tests**: Located in `PhotoSwipeTests/` using Swift Testing framework
  - Run via Xcode Test Navigator or `xcodebuild test`
- **UI Tests**: Located in `PhotoSwipeUITests/` using XCTest framework
  - Run via Xcode Test Navigator or `xcodebuild test -scheme PhotoSwipe`

## Code Architecture

### Project Structure
```
PhotoSwipe/
├── PhotoSwipe/           # Main app target
│   ├── PhotoSwipeApp.swift    # App entry point (@main)
│   ├── ContentView.swift      # Primary view
│   └── Assets.xcassets/       # App assets
├── PhotoSwipeTests/      # Unit tests (Swift Testing)
└── PhotoSwipeUITests/    # UI tests (XCTest)
```

### Key Components
- **PhotoSwipeApp.swift**: Main app entry point using SwiftUI's `@main` attribute
- **ContentView.swift**: Primary view containing the app's main UI
- Tests use both Swift Testing framework (unit tests) and XCTest (UI tests)

## Development Notes
- This is a standard iOS SwiftUI app created from Xcode template
- Uses modern Swift Testing framework for unit tests alongside traditional XCTest for UI tests
- Project follows standard Xcode project conventions