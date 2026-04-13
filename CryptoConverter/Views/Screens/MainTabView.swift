import SwiftUI
import SwiftData
import DotLottie
import DotLottiePlayer

struct MainTabView: View {
	@Environment(\.scenePhase) private var scenePhase
	@Environment(\.modelContext) private var modelContext

	static var fetchDescriptor: FetchDescriptor<Cryptocurrency> {
		var descriptor = FetchDescriptor<Cryptocurrency>()
		descriptor.fetchLimit = 3
		return descriptor
	}

	@Query(fetchDescriptor) private var cryptocurrencies: [Cryptocurrency]

	// Check if I have at least 3 cryptos, or if it's preview
	private var isLoading: Bool {
		cryptocurrencies.count < 3
	}

	let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

	@StateObject private var scheduler = TickerUpdateScheduler()
	@State private var favouritesInitialized = false

	@State private var stableCurrencyService: CurrencyService?

	private var currencyService: CurrencyService {
		if let stable = stableCurrencyService { return stable }
		
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
			if isLoading && !favouritesInitialized {
				ContentUnavailableView {
					VStack {
						DotLottieAnimation(
							fileName: "popping",
							config: AnimationConfig(autoplay: true, loop: true)
						).view()
							.frame(width: 400, height: 500)
						Text("Wait for data to be fetched")
						Spacer()
					}
				}
			} else {
				TabView {
					OverviewView(scheduler: scheduler)
						.tabItem {
							Label("Overview", systemImage: "house")
						}

					SettingsView(currencyService: stableCurrencyService ?? currencyService)
						.tabItem {
							Label("Settings", systemImage: "gear")
						}
				}
			}
		}
		.task {
			// Initialize stable service if not yet done
			if stableCurrencyService == nil {
				stableCurrencyService = currencyService
			}
			
			guard let service = stableCurrencyService else { return }
			
			print("Task is called.")
			if isLoading || isPreview {
				scheduler.updateLastExecution()
				try? await service.ensureInitialDataIfNeeded()
				await service.addInitialFavourites()
				favouritesInitialized = true // Favourites have been added
				print("Initial data has happened")
			} else if scheduler.checkIfNeeded() {
				favouritesInitialized = true // No need add favourites again
				scheduler.updateLastExecution()
				await service.updateAmounts()
				print("Update has happened")
			}

			// When the initial update is done (if needed), make sure the remaining data exist
			// If not, add them
			await service.ensureRemainingData()

			// No matter what happened above, the favourites are in place and the main page can finally load
			favouritesInitialized = true

			scheduler.start { [service] in
				print("Inside the scheduler start. Going to update amounts")
				await service.updateAmounts()
				print("The amounts have been updated")
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
struct AnimationView: View {
	var body: some View {
		DotLottieAnimation(
			fileName: "popping",
			config: AnimationConfig(autoplay: true, loop: true)
		).view()
	}
}

#Preview {
	MainTabView()
		.modelContainer(Previews.preview)
}
