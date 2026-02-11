import SwiftUI
import Foundation

struct SettingsView: View {
	@Environment(\.modelContext) private var modelContext
	@State private var settingsService: AppSettingsService?

	var body: some View {
		NavigationStack {
			List {

				// TODO: Update Information needs to be somewhere in here

				// Display Settings
				Section {
					if let settingsService = settingsService {
						Picker("Display Mode", selection: Binding(
							get: { settingsService.settings.displayMode },
							set: { newValue in
								settingsService.settings.displayMode = newValue
								settingsService.save()
							}
						)) {
							Text("Merged").tag(DisplayMode.merged)
							Text("Separated").tag(DisplayMode.separated)
						}
					}
				} header: {
					Text("Display Settings")
				}

				// Additional Info
				Section {
					NavigationLink(destination: MarkdownView(fileName: "Technical_Information")) {
						Text("Technical Information")
					}

					NavigationLink(destination: MarkdownView(fileName: "Privacy_Policy")) {
						Text("Privacy Policy")
					}
				} header: {
					Text("Additional Info")
				}

			}
			.navigationTitle("Settings")
		}
		.onAppear {
			if settingsService == nil {
				settingsService = AppSettingsService(modelContext: modelContext)
			}
		}
	}
}

#Preview {
	SettingsView()
}
