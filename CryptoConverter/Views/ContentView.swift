import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            OverviewView()
                .tabItem {
                    Label("Overview", systemImage: "house")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}


#Preview {
	ContentView()
		.modelContainer(Previews.preview)
}