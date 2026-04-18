import Foundation
import SwiftUI
import SwiftData
import OSLog

struct SettingsView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.currencyService) private var currencyService
	@Environment(\.settingsService) private var settingsService
	@Environment(\.metadataService) private var metadataService

	var body: some View {
		NavigationStack {
			List {

				// Display Settings
				Section {
					if let settingsService = settingsService {
						Picker(
							"Display Mode",
							selection: Binding(
								get: { settingsService.settings.displayMode },
								set: { newValue in
									// TODO: It would be better to access only the settings, not the whole service in here
									settingsService.settings.displayMode =
										newValue
									settingsService.save()
								}
							)
						) {
							Text("Merged").tag(DisplayMode.merged)
							Text("Separated").tag(DisplayMode.separated)
						}
						.pickerStyle(.segmented)

						Picker(
							"Crypto Decimals",
							selection: Binding(
								get: {
									settingsService.settings.cryptoDecimals
								},
								set: { newValue in
									settingsService.settings.cryptoDecimals =
										newValue
									settingsService.save()
								}
							)
						) {
							Text("0,01").tag(2)
							Text("0,001").tag(3)
							Text("0,0001").tag(4)
							Text("0,00001").tag(5)
							Text("0,000001").tag(6)
							Text("0,0000001").tag(7)
						}

						Picker(
							"Fiat Decimals",
							selection: Binding(
								get: { settingsService.settings.fiatDecimals },
								set: { newValue in
									settingsService.settings.fiatDecimals =
										newValue
									settingsService.save()
								}
							)
						) {
							Text("0,01").tag(2)
							Text("0,001").tag(3)
							Text("0,0001").tag(4)
							Text("0,00001").tag(5)
							Text("0,000001").tag(6)
							Text("0,0000001").tag(7)
						}
					}
				} header: {
					Text("Display Settings")
				}

				// Additional Info
				Section {
					NavigationLink(
						destination: MarkdownView(fileName: "Privacy_Policy")
					) {
						Text("Privacy Policy")
					}

					NavigationLink(
						destination: MarkdownView(fileName: "Technical_Information")
					) {
						Text("Technical Information")
					}
					
				} header: {
					Text("Additional Info")
				}

				// Update Information Footer
				Section {
					EmptyView()  // Empty section just to hold the footer
				} footer: {
					VStack(alignment: .leading, spacing: 4) {
						Text(
							"Cryptocurrencies updated: \(metadataService?.metadata.cryptoLastUpdate ?? "Loading...")"
						)
						Text(
							"Fiat currencies updated: \(metadataService?.metadata.fiatLastUpdate ?? "Loading...")"
						)
					}
					.font(.footnote)
					.foregroundColor(.secondary)
				}

			}
			.navigationTitle("Settings")
		}
		.task {
			guard let currencyService = currencyService else { return }

			// If they are stale, remove the previous value and show that it's loading.
			// If the value is not too old, it doesn't hurt to keep it
			if isStaleForADay(
				lastUpdated: metadataService?.metadata.cryptoLastUpdate
			) {
				metadataService?.metadata.cryptoLastUpdate = nil
			}
			if isStaleForADay(
				lastUpdated: metadataService?.metadata.fiatLastUpdate
			) {
				metadataService?.metadata.fiatLastUpdate = nil
			}

			async let cryptoUpdate = currencyService.getLastUpdate(
				of: "Cryptocurrency"
			)
			async let fiatUpdate = currencyService.getLastUpdate(
				of: "FiatCurrency"
			)

			let (crypto, fiat) = await (cryptoUpdate, fiatUpdate)

			withAnimation {
				metadataService?.metadata.cryptoLastUpdate = crypto
				metadataService?.metadata.fiatLastUpdate = fiat
				metadataService?.save()
			}
		}
	}

	private func isStaleForADay(lastUpdated: String?) -> Bool {
		// If it's null, then it means it is `Loading...` and therefore it is stale
		guard let lastUpdated = lastUpdated else { return true }

		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .medium
		
		let isStale = formatter.date(from: lastUpdated).map {
			Date().timeIntervalSince($0) > 86400
		} ?? true

		Log.ui.debugApp("Is \(lastUpdated) stale? \(isStale)")

		return isStale
	}
}

#Preview {
	SettingsView()
		.environment(\.currencyService, Previews.previewCurrencyService)
		.modelContainer(Previews.preview)
}
