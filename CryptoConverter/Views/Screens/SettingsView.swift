import SwiftUI
import Foundation

struct SettingsView: View {
	@Environment(\.modelContext) private var modelContext
	@State private var settingsService: AppSettingsService?
	@State private var cryptoLastUpdate: String = "Loading..."
	
	let currencyService: CurrencyService?

	// TODO: Soon to be used from the service
	private func getCurrentDate() -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter.string(from: Date())
	}

	var body: some View {
		NavigationStack {
			List {

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

				// Update Information Footer
				Section {
					EmptyView() // Empty section just to hold the footer
				} footer: {
					VStack(alignment: .leading, spacing: 4) {
						Text("Cryptocurrencies updated: \(cryptoLastUpdate)")
						Text("Fiat currencies updated: \(getCurrentDate())")
					}
					.font(.footnote)
					.foregroundColor(.secondary)
				}

			}
			.navigationTitle("Settings")
		}
		.onAppear {
			if settingsService == nil {
				settingsService = AppSettingsService(modelContext: modelContext)
			}

			// Load real cryptocurrency last update
			if let currencyService = currencyService {
				Task {
					cryptoLastUpdate = await currencyService.getLastUpdate()
				}
			}
		}
	}
}

#Preview {
	SettingsView(currencyService: nil)
}
