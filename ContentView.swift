import SwiftUI

struct ContentView: View {
    @State private var selectedLanguage: String? = "English"
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedLanguage: $selectedLanguage)
        } detail: {
            PreviewView(language: selectedLanguage ?? "English")
        }
    }
}

struct SidebarView: View {
    @Binding var selectedLanguage: String?
    let languages = ["English", "Spanish", "French", "German"]
    
    var body: some View {
        List(selection: $selectedLanguage) {
            Section("Screenshots") {
                ForEach(languages, id: \.self) { language in
                    Label(language, systemImage: "flag")
                        .tag(language)
                }
                
                Button(action: {}) {
                    Label("Add Language", systemImage: "plus.circle")
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 200, ideal: 250)
    }
}

struct PreviewView: View {
    let language: String
    
    var body: some View {
        VStack {
            Text("iPhone Preview")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            RoundedRectangle(cornerRadius: 40)
                .stroke(lineWidth: 2)
                .frame(width: 300, height: 600)
                .overlay {
                    VStack {
                        Text("App Title")
                            .font(.title)
                            .padding(.top, 100)
                        
                        Text("Marketing subtitle for \(language)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                }
            
            HStack {
                Button("Export All") {}
                Button("Export Current") {}
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
        .frame(width: 900, height: 600)
}