# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

APIExplorer is a native macOS SwiftUI application for viewing and interacting with API documentation in Swagger/OpenAPI format. Created with Xcode 26.0.

### Key Features
- **Native macOS app** with SwiftUI interface
- **View and edit Swagger/OpenAPI files** with rich editing capabilities
- **API testing interface** - make API calls and record response history
- **Rich markdown documentation** display with full rendering support
- **WYSIWYG markdown editor** for writing and editing API documentation
- **OpenAPI 3.0 links support** - reference values from API responses in other requests
- **Environment variables** - create and manage variables across API requests

### Project Targets
- **APIExplorer**: Main application target (SwiftUI app for macOS)
- **APIExplorerTests**: Unit tests using Swift Testing framework
- **APIExplorerUITests**: UI tests using XCTest framework

## Development Commands

### Building and Running
- **Build project**: `xcodebuild -scheme APIExplorer build`
- **Run app**: Use Xcode or `xcodebuild -scheme APIExplorer -destination 'platform=macOS' run`

### Testing
- **Run unit tests**: `xcodebuild -scheme APIExplorer test -destination 'platform=macOS' -only-testing:APIExplorerTests`
- **Run UI tests**: `xcodebuild -scheme APIExplorer test -destination 'platform=macOS' -only-testing:APIExplorerUITests`
- **Run all tests**: `xcodebuild -scheme APIExplorer test -destination 'platform=macOS'`

### Project Information
- **List schemes**: `xcodebuild -list`
- **Available configurations**: Debug, Release (default: Release)

## Architecture

### File Structure
```
APIExplorer/
├── APIExplorer/              # Main app source
│   ├── APIExplorerApp.swift  # App entry point (@main)
│   ├── ContentView.swift     # Main UI view
│   └── Assets.xcassets/      # App assets
├── APIExplorerTests/         # Unit tests (Swift Testing)
└── APIExplorerUITests/       # UI tests (XCTest)
```

### Key Technical Details
- **Platform**: macOS 26.0+ (using latest beta features)
- **Language**: Swift 5.0
- **UI Framework**: SwiftUI with SwiftUI Previews enabled
- **Testing**: Uses new Swift Testing framework for unit tests, XCTest for UI tests
- **App Sandbox**: Enabled with hardened runtime
- **Bundle ID**: uk.co.bendavisapps.APIExplorer

### Swift Features in Use
- Swift Approachable Concurrency enabled
- MainActor default isolation
- Member import visibility upcoming feature enabled
- String catalog symbol generation
- **Language**: Swift 6 with strict concurrency
- **Concurrency Pattern**: Everything @MainActor isolated by default, no need for explicit @MainActor annotations on types