import SwiftUI
import SwiftData

struct MainTabView: View {
	@Environment(\.scenePhase) private var scenePhase
	@Environment(\.modelContext) private var modelContext
	
	let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

	@StateObject private var scheduler = TickerUpdateScheduler()
	@State private var lastUpdate = "NaN"
	@State private var favouritesInitialized = false

	private var currencyService: CurrencyService {
		let repoCrypto = CryptoRepository(modelContext: modelContext)
		let repoFiat = FiatRepository(modelContext: modelContext)
		let repoAll = AllRepository(modelContext: modelContext, cryptoRepo: repoCrypto, fiatRepo: repoFiat)

		let cloudKitService = CloudKitService()

		let cryptoService = CryptocurrencyService(repository: repoAll, cloudKitService: cloudKitService)
		let fiatService = FiatCurrencyService(repository: repoAll, cloudkitService: cloudKitService)
		return CurrencyService(fiatService: fiatService, cryptoService: cryptoService, currencyRepository: repoAll)
	}

    var body: some View {
		Group {
			if !favouritesInitialized {
				ContentUnavailableView {
					VStack(spacing: 8) {
						Image("btc")
							.resizable()
							.scaledToFit()
							.frame(width: 96, height: 96)
						Text("Wait for data to be fetched.")

						ProgressView()
							.progressViewStyle(CircularProgressViewStyle())
					}
				}
			} else {
				TabView {
					OverviewView(scheduler: scheduler, lastUpdate: lastUpdate)
						.tabItem {
							Label("Overview", systemImage: "house")
						}

					SettingsView()
						.tabItem {
							Label("Settings", systemImage: "gear")
						}
				}
				.onAppear {
					Task {
						print("Calling getLastUpdate with value: \(lastUpdate)")
						lastUpdate = await currencyService.getLastUpdate()
						print("Retrieved getLastUpdate with value: \(lastUpdate)")
					}
				}
			}
		}
		.onAppear {
			Task {
				print("Task is called.")
				let fetchDescriptor = FetchDescriptor<Cryptocurrency>()
				// Check immediately on appear if I have at least 3 cryptos, or if it's preview
				if let result = try? modelContext.fetch(fetchDescriptor), result.count < 3 || isPreview {
					scheduler.updateLastExecution()
					try? await currencyService.ensureInitialDataIfNeeded()
					await currencyService.addInitialFavourites()
					print("Initial data has happened")
				} else if scheduler.checkIfNeeded() {
					scheduler.updateLastExecution()
					await currencyService.updateAmounts()
					print("Update has happened")
				}

				// No matter what happened above, the favourites are in place and the main page can finally load
				favouritesInitialized = true

				scheduler.start { [service = currencyService] in
					print("Inside the scheduler start. Going to update amounts")
					await service.updateAmounts()
					print("The amounts have been updated")
				}
			}
		}
		.onDisappear {
			scheduler.stop()
		}
		.onChange(of: scenePhase, { _, newValue in
			if newValue == .active {
				if scheduler.checkIfNeeded() {
					Task {
						scheduler.updateLastExecution()
						await currencyService.updateAmounts()
					}
				}
			}
		})

    }
}


#Preview {
	MainTabView()
		.modelContainer(Previews.preview)
}
