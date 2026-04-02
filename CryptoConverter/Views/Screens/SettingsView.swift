import Foundation
import SwiftUI
import SwiftData

struct SettingsView: View {
	@Environment(\.modelContext) private var modelContext
	@State private var settingsService: AppSettingsService?
	@State private var cryptoLastUpdate: String = "Loading..."
	@State private var fiatLastUpdate: String = "Loading..."

	let currencyService: CurrencyService?

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
				} header: {
					Text("Additional Info")
				}

				// Update Information Footer
				Section {
					EmptyView()  // Empty section just to hold the footer
				} footer: {
					VStack(alignment: .leading, spacing: 4) {
						Text("Cryptocurrencies updated: \(cryptoLastUpdate)")
						Text("Fiat currencies updated: \(fiatLastUpdate)")
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
					async let cryptoUpdate = currencyService.getLastUpdate(
						of: "Cryptocurrency"
					)
					async let fiatUpdate = currencyService.getLastUpdate(
						of: "FiatCurrency"
					)

					let (crypto, fiat) = await (cryptoUpdate, fiatUpdate)

					cryptoLastUpdate = crypto
					fiatLastUpdate = fiat
				}
			}
		}
	}
}

#Preview {
	SettingsView(currencyService: nil)
}
