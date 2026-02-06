import SwiftUI
import Foundation

struct SettingsView: View {
	@Environment(\.modelContext) private var modelContext
	@State private var settingsService: AppSettingsService?

	var body: some View {
		NavigationStack {
			List {
//				Section {
//					NavigationLink(destination: Text("Membership features coming soon!")) {
//						Text("Upgrade to Pro")
//					}
//				} header: {
//					Text("Membership")
//				}

				Section {
					NavigationLink(destination: PrivacyPolicyView()) {
						Text("Privacy Policy")
					}
//					NavigationLink(destination: Text("Support features coming soon!")) {
//						Text("Contact Support")
//					}
				} header: {
					Text("Additional Info")
				}

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

struct PrivacyPolicyView: View {
	@State private var policyContent: String = "Loading..."

	var body: some View {
		MarkdownView(content: policyContent)
			.onAppear {
				loadPolicy()
			}
	}
	
	private func loadPolicy() {
		if let url = Bundle.main.url(forResource: "Privacy_Policy", withExtension: "md") {
			do {
				policyContent = try String(contentsOf: url, encoding: .utf8)
			} catch {
				policyContent = "Error loading Privacy Policy: \(error.localizedDescription)"
			}
		} else {
			policyContent = "Privacy Policy file not found in Bundle."
		}
	}
}


#Preview {
	SettingsView()
}
