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

When implementing features:
1. Maintain clean, simple SwiftUI code with proper previews
2. Use native macOS design patterns (NavigationSplitView for sidebar, etc.)
3. Keep state management simple with @State and @Binding
4. Ensure all views have #Preview macros for easy development