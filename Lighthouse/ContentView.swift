//
//  ContentView.swift
//  Lighthouse
//
//  Created by havard.sjong@vipps.no on 04/08/2025.
//

import SwiftUI

let appCategories = [
    "Books",
    "Business",
    "Developer Tools",
    "Education",
    "Entertainment",
    "Finance",
    "Food & Drink",
    "Games",
    "Graphics & Design",
    "Health & Fitness",
    "Kids",
    "Lifestyle",
    "Magazines & Newspapers",
    "Medical",
    "Music",
    "Navigation",
    "News",
    "Photo & Video",
    "Productivity",
    "Reference",
    "Safari Extensions",
    "Shopping",
    "Social Networking",
    "Sports",
    "Travel",
    "Utilities",
    "Weather"
]

enum NavigationItem: Hashable {
    case language(String)
    case settings(SettingsSection)
}

enum SettingsSection: String, CaseIterable {
    case appContext = "App Context"
    case translation = "Translation"
    case export = "Export"
}

struct ContentView: View {
    @State private var projectManager = ProjectManager()
    @State private var selection: NavigationItem?
    @State private var showInspector = true
    @State private var showNewProjectDialog = false
    @State private var newProjectName = ""
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection, projectManager: projectManager)
                .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            Group {
                switch selection {
                case .language(let language):
                    HStack(spacing: 0) {
                        PreviewView(language: language, projectManager: projectManager)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        if showInspector {
                            InspectorView()
                                .frame(width: 300)
                                .background(Color(NSColor.controlBackgroundColor))
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: { withAnimation { showInspector.toggle() } }) {
                                Label("Inspector", systemImage: "sidebar.right")
                            }
                        }
                    }
                case .settings(let section):
                    SettingsView(section: section, projectManager: projectManager)
                case nil:
                    if projectManager.currentProject == nil {
                        EmptyProjectView(showNewProjectDialog: $showNewProjectDialog)
                    } else if projectManager.currentProject?.languages.isEmpty == true {
                        Text("Add a language to get started")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Select a language")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showNewProjectDialog) {
            NewProjectSheet(projectManager: projectManager, isPresented: $showNewProjectDialog)
        }
    }
}

struct SidebarView: View {
    @Binding var selection: NavigationItem?
    var projectManager: ProjectManager
    @State private var showNewLanguagePopover = false
    @State private var newLanguageName = "English"
    
    var body: some View {
        VStack(spacing: 0) {
            // Project Picker
            if projectManager.currentProject != nil {
                HStack {
                    Text(projectManager.projectURL?.lastPathComponent.replacingOccurrences(of: ".lighthouse", with: "") ?? "Untitled")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
                Divider()
            }
            
            List(selection: $selection) {
            Section("Settings") {
                ForEach(SettingsSection.allCases, id: \.self) { section in
                    Label(section.rawValue, systemImage: iconForSection(section))
                        .tag(NavigationItem.settings(section))
                }
            }
            
            if let project = projectManager.currentProject {
                Section("Languages") {
                    ForEach(Array(project.languages.keys.sorted()), id: \.self) { language in
                        DisclosureGroup {
                            if let screenshots = project.languages[language]?.screenshots {
                                ForEach(Array(screenshots.enumerated()), id: \.element.id) { index, screenshot in
                                    HStack {
                                        Image(systemName: screenshot.imagePath != nil ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(screenshot.imagePath != nil ? .green : .secondary)
                                            .font(.caption)
                                        
                                        Text(screenshot.pageName.isEmpty ? "Page \(index + 1)" : screenshot.pageName)
                                            .font(.subheadline)
                                    }
                                    .padding(.leading)
                                    // TODO: Add page-specific navigation later
                                }
                                
                                Button(action: { projectManager.addEmptyPage(to: language) }) {
                                    Label("Add Page", systemImage: "plus.circle")
                                        .font(.subheadline)
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(.secondary)
                                .padding(.leading)
                            }
                        } label: {
                            HStack {
                                if project.languages[language]?.isReference == true {
                                    Label {
                                        Text(language)
                                    } icon: {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                    }
                                } else {
                                    Label(language, systemImage: "flag")
                                }
                                Spacer()
                                if let count = project.languages[language]?.screenshots.count, count > 0 {
                                    Text("\(count)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 6)
                                        .background(Capsule().fill(.quaternary))
                                }
                            }
                        }
                        .tag(NavigationItem.language(language))
                    }
                    
                    Button(action: { showNewLanguagePopover = true }) {
                        Label("Add Language", systemImage: "plus.circle")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .popover(isPresented: $showNewLanguagePopover) {
                        AddLanguagePopover(projectManager: projectManager, isPresented: $showNewLanguagePopover)
                    }
                }
            }
            }
            .listStyle(.sidebar)
        }
        .navigationTitle("")
    }
    
    func iconForSection(_ section: SettingsSection) -> String {
        switch section {
        case .appContext: return "app.fill"
        case .translation: return "character.book.closed"
        case .export: return "square.and.arrow.up"
        }
    }
}

struct PreviewView: View {
    let language: String
    var projectManager: ProjectManager
    @State private var currentScreenshot = 0
    
    var screenshots: [Screenshot] {
        projectManager.currentProject?.languages[language]?.screenshots ?? []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if screenshots.isEmpty {
                // Empty language state
                VStack(spacing: 30) {
                    Spacer()
                    
                    Text("Drop screenshots here")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundStyle(.quaternary)
                    
                    Text("Supports: PNG, JPG")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    
                    Divider()
                        .frame(width: 200)
                    
                    HStack(spacing: 20) {
                        Button("Browse Files") {
                            // TODO: Implement file browser
                        }
                        .controlSize(.large)
                        
                        Button("Add Empty Page") {
                            projectManager.addEmptyPage(to: language)
                        }
                        .controlSize(.large)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.02))
                .onDrop(of: ["public.image"], isTargeted: nil) { providers in
                    // Handle drop
                    return true
                }
            } else {
                // Preview controls
                HStack {
                    Button(action: { if currentScreenshot > 0 { currentScreenshot -= 1 } }) {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(currentScreenshot == 0)
                    
                    Text("\(currentScreenshot + 1) of \(screenshots.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 80)
                    
                    Button(action: { if currentScreenshot < screenshots.count - 1 { currentScreenshot += 1 } }) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(currentScreenshot == screenshots.count - 1)
                    
                    Divider()
                        .frame(height: 20)
                        .padding(.horizontal, 10)
                    
                    Button(action: { 
                        projectManager.addEmptyPage(to: language)
                        // Jump to the new page
                        currentScreenshot = screenshots.count
                    }) {
                        Label("Add Page", systemImage: "plus.circle")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                    .help("Add new page")
                }
                .padding()
            
            // Canvas area
            GeometryReader { geometry in
                ZStack {
                    // Background pattern
                    Canvas { context, size in
                        let gridSize: CGFloat = 20
                        for x in stride(from: 0, to: size.width, by: gridSize) {
                            for y in stride(from: 0, to: size.height, by: gridSize) {
                                context.fill(
                                    Path(ellipseIn: CGRect(x: x + gridSize/2 - 1, y: y + gridSize/2 - 1, width: 2, height: 2)),
                                    with: .color(.secondary.opacity(0.2))
                                )
                            }
                        }
                    }
                    
                    PhoneFrame {
                        if let screenshot = screenshots[safe: currentScreenshot] {
                            if screenshot.imagePath == nil {
                                // Empty page state
                                VStack(spacing: 20) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 60))
                                        .foregroundStyle(.quaternary)
                                    
                                    Text("Drop screenshot here")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("or browse...")
                                        .font(.subheadline)
                                        .foregroundStyle(.tertiary)
                                }
                            } else {
                                // Screenshot with text
                                VStack(spacing: 8) {
                                    Text(screenshot.title.isEmpty ? "Add title" : screenshot.title)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(screenshot.title.isEmpty ? .tertiary : .primary)
                                    
                                    Text(screenshot.subtitle.isEmpty ? "Add subtitle" : screenshot.subtitle)
                                        .font(.title3)
                                        .foregroundStyle(screenshot.subtitle.isEmpty ? .tertiary : .secondary)
                                }
                                .padding(.top, 80)
                                .frame(maxHeight: .infinity, alignment: .top)
                            }
                        }
                    }
                    .scaleEffect(min(geometry.size.width / 400, geometry.size.height / 800))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            }
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}

struct PhoneFrame<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.primary.opacity(0.2), lineWidth: 3)
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.white)
                )
                .frame(width: 320, height: 640)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            
            content
                .frame(width: 300, height: 620)
                .clipShape(RoundedRectangle(cornerRadius: 35))
        }
    }
}

struct InspectorView: View {
    @State private var selectedDevice = "iPhone 15 Pro"
    @State private var strokeWidth: Double = 3
    @State private var strokeColor = Color.primary.opacity(0.2)
    @State private var backgroundColor = Color.white
    @State private var showGradient = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Device Settings
                VStack(alignment: .leading, spacing: 12) {
                    Text("Device")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Model")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Picker("", selection: $selectedDevice) {
                            Text("iPhone 15 Pro").tag("iPhone 15 Pro")
                            Text("iPhone 15").tag("iPhone 15")
                            Text("iPhone SE").tag("iPhone SE")
                            Text("iPad Pro").tag("iPad Pro")
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Frame Style")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Picker("", selection: .constant("stroke")) {
                            Text("No Frame").tag("none")
                            Text("Stroke").tag("stroke")
                            Text("Device").tag("device")
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stroke Width")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Slider(value: $strokeWidth, in: 1...5)
                        
                        HStack {
                            Text("Color")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            ColorPicker("", selection: $strokeColor)
                                .labelsHidden()
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary))
                
                // Background Settings
                VStack(alignment: .leading, spacing: 12) {
                    Text("Background")
                        .font(.headline)
                    
                    Toggle("Gradient", isOn: $showGradient)
                    
                    HStack {
                        Text("Color")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        ColorPicker("", selection: $backgroundColor)
                            .labelsHidden()
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary))
                
                // Typography Settings
                VStack(alignment: .leading, spacing: 12) {
                    Text("Typography")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title Font")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Picker("", selection: .constant("SF Pro Display")) {
                            Text("SF Pro Display").tag("SF Pro Display")
                            Text("SF Pro Text").tag("SF Pro Text")
                            Text("New York").tag("New York")
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary))
                
                // Margin Settings
                VStack(alignment: .leading, spacing: 12) {
                    Text("Margin")
                        .font(.headline)
                    
                    Picker("", selection: .constant("medium")) {
                        Text("Small").tag("small")
                        Text("Medium").tag("medium")
                        Text("Large").tag("large")
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary))
                
                // Export
                VStack(alignment: .leading, spacing: 12) {
                    Text("Export")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        Button(action: {}) {
                            Label("Current Screenshot", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {}) {
                            Label("All English Screenshots", systemImage: "square.and.arrow.up.on.square")
                                .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {}) {
                            Label("All Languages", systemImage: "globe")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary))
                
                Spacer()
            }
            .padding()
        }
    }
}

struct SettingsView: View {
    let section: SettingsSection
    var projectManager: ProjectManager
    
    var body: some View {
        ScrollView {
            VStack {
                switch section {
                case .appContext:
                    AppContextView(projectManager: projectManager)
                case .translation:
                    TranslationSettingsView()
                case .export:
                    ExportSettingsView()
                }
            }
            .frame(maxWidth: 800)
            .padding()
        }
    }
}

struct AppContextView: View {
    var projectManager: ProjectManager
    
    var appContext: Binding<AppContext> {
        Binding(
            get: { projectManager.currentProject?.appContext ?? AppContext() },
            set: { newValue in
                projectManager.currentProject?.appContext = newValue
                projectManager.saveProject()
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("App Context")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("This information helps AI create better localized copy for your screenshots.")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Form {
                Section {
                    TextField("App Name", text: appContext.name)
                    TextField("Tagline", text: appContext.tagline)
                    
                    Picker("Category", selection: appContext.category) {
                        ForEach(appCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextField("App Store URL (optional)", text: appContext.appStoreURL)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section("About Your App") {
                    TextEditor(text: appContext.description)
                        .frame(minHeight: 200)
                        .font(.body)
                }
            }
            .formStyle(.grouped)
        }
    }
}

struct TranslationSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Translation Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Configure how AI translates your content.")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            // Translation settings form...
        }
    }
}

struct ExportSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Export Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Default export preferences.")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            // Export settings form...
        }
    }
}

struct EmptyProjectView: View {
    @Binding var showNewProjectDialog: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No project open")
                .font(.largeTitle)
                .fontWeight(.medium)
            
            Button("Create New Project") {
                showNewProjectDialog = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

struct NewProjectSheet: View {
    var projectManager: ProjectManager
    @Binding var isPresented: Bool
    @State private var projectName = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New Project")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Project Name", text: $projectName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)
                
                Button("Create") {
                    projectManager.createNewProject(named: projectName.isEmpty ? "Untitled" : projectName)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(projectName.isEmpty)
                .keyboardShortcut(.return)
            }
        }
        .padding(40)
    }
}

struct AddLanguagePopover: View {
    var projectManager: ProjectManager
    @Binding var isPresented: Bool
    @State private var selectedLanguage = "English"
    @State private var isReference = false
    
    let availableLanguages = ["English", "Spanish", "French", "German", "Japanese", "Chinese", "Italian", "Portuguese", "Russian", "Korean"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Add Language")
                .font(.headline)
            
            Picker("Language", selection: $selectedLanguage) {
                ForEach(availableLanguages, id: \.self) { language in
                    Text(language).tag(language)
                }
            }
            
            if projectManager.currentProject?.languages.isEmpty == true {
                Toggle("Set as reference language", isOn: $isReference)
            }
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                
                Spacer()
                
                Button("Add") {
                    projectManager.addLanguage(selectedLanguage, isReference: isReference || projectManager.currentProject?.languages.isEmpty == true)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

// Preview wrapper that allows us to inject a ProjectManager
struct ContentView_Previews: View {
    @State var projectManager: ProjectManager
    @State private var selection: NavigationItem?
    @State private var showInspector = true
    @State private var showNewProjectDialog = false
    @State private var newProjectName = ""
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection, projectManager: projectManager)
                .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        } detail: {
            Group {
                switch selection {
                case .language(let language):
                    HStack(spacing: 0) {
                        PreviewView(language: language, projectManager: projectManager)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        if showInspector {
                            InspectorView()
                                .frame(width: 300)
                                .background(Color(NSColor.controlBackgroundColor))
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: { withAnimation { showInspector.toggle() } }) {
                                Label("Inspector", systemImage: "sidebar.right")
                            }
                        }
                    }
                case .settings(let section):
                    SettingsView(section: section, projectManager: projectManager)
                case nil:
                    if projectManager.currentProject == nil {
                        EmptyProjectView(showNewProjectDialog: $showNewProjectDialog)
                    } else if projectManager.currentProject?.languages.isEmpty == true {
                        Text("Add a language to get started")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Select a language")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showNewProjectDialog) {
            NewProjectSheet(projectManager: projectManager, isPresented: $showNewProjectDialog)
        }
    }
}

#Preview("Empty State") {
    ContentView()
        .frame(width: 1200, height: 800)
}

#Preview("With Project") {
    ContentView_Previews(projectManager: {
        let manager = ProjectManager()
        var project = Project()
        project.appContext.name = "FocusFlow"
        project.appContext.tagline = "Deep work made simple"
        project.appContext.category = "Productivity"
        project.languages["English"] = Language(isReference: true, screenshots: [
            Screenshot(id: "1", imagePath: "screenshot1.png", title: "Focus Better", subtitle: "Track your deep work sessions")
        ])
        project.languages["Spanish"] = Language(isReference: false, screenshots: [])
        manager.currentProject = project
        return manager
    }())
    .frame(width: 1200, height: 800)
}

#Preview("Language Selected") {
    struct PreviewWrapper: View {
        @State var projectManager = {
            let manager = ProjectManager()
            var project = Project()
            project.appContext.name = "TestApp"
            project.languages["English"] = Language(isReference: true, screenshots: [])
            manager.currentProject = project
            return manager
        }()
        @State var selection: NavigationItem? = .language("English")
        
        var body: some View {
            NavigationSplitView {
                SidebarView(selection: $selection, projectManager: projectManager)
                    .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            } detail: {
                if case .language(let language) = selection {
                    HStack(spacing: 0) {
                        PreviewView(language: language, projectManager: projectManager)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        InspectorView()
                            .frame(width: 300)
                            .background(Color(NSColor.controlBackgroundColor))
                    }
                }
            }
        }
    }
    
    return PreviewWrapper()
        .frame(width: 1200, height: 800)
}
