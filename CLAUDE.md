# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lighthouse is a macOS application for creating localized App Store screenshots. The app helps developers generate beautiful, localized screenshot sets for multiple languages with marketing copy that sells.

### Key Features (Planned)
- Upload iOS app screenshots for different languages
- Apply professional device frames (iPhone styles: regular and stroke)
- Customize backgrounds (solid or gradient) and typography (Apple fonts)
- Add localized marketing copy with context-aware translations
- Export App Store-ready screenshots

### MVP Scope
- Stroke style only
- Normal positioning
- Gradient/normal backgrounds
- Apple fonts
- Basic translation functionality

## Development Setup

This is a native macOS SwiftUI application built with Xcode.

### Building and Running
- Open `Lighthouse.xcodeproj` in Xcode
- Press ⌘R to build and run
- Press ⌘B to build without running
- Use Xcode's built-in preview feature (Canvas) to see SwiftUI previews

### Project Structure
- `Lighthouse/LighthouseApp.swift` - Main app entry point with WindowGroup
- `Lighthouse/ContentView.swift` - Main UI view
- `Lighthouse/Assets.xcassets` - App assets and icons
- `Lighthouse.entitlements` - App sandbox and file access permissions

### Architecture Notes
- Pure SwiftUI implementation targeting macOS 14+
- App is sandboxed with read-only file access for user-selected files
- Currently has basic "Hello, world!" template that needs to be replaced with the actual UI

## Development Guidelines

### Modern Swift/SwiftUI Patterns (2025)

When implementing features, use modern Swift patterns:

1. **@Observable instead of ObservableObject**
   ```swift
   @Observable
   class ProjectManager {
       var currentProject: Project?
   }
   ```

2. **Structured Concurrency**
   - Use `async/await` for all asynchronous operations
   - Use `@MainActor` for UI-related classes
   - Use `.task { }` modifier for async work in views

3. **Modern State Management**
   - `@State` for view-local state
   - `@Bindable` for two-way bindings with @Observable
   - `@Environment` for dependency injection

4. **Navigation**
   - Use `NavigationStack` with `NavigationPath` for navigation
   - Avoid deprecated `NavigationView`

5. **Data Flow**
   ```swift
   @MainActor
   @Observable
   class ViewModel {
       var items: [Item] = []
       
       func load() async throws {
           items = try await fetchData()
       }
   }
   ```

6. **View Patterns**
   - Declarative UI with minimal imperative code
   - Composition over inheritance
   - Use `#Preview` macros with multiple states
   - Prefer computed properties over functions in views

### Code Style
- Use trailing closures for single-closure parameters
- Prefer `guard` for early returns
- Use `if let` and `guard let` for optionals
- Leverage Swift's type inference where it improves readability