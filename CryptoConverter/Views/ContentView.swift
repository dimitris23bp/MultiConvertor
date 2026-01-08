import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.scenePhase) private var scenePhase
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: \Cryptocurrency.sortOrder, animation: .default) private var cryptocurrencies: [Cryptocurrency]

	@Query(
		filter: #Predicate<Cryptocurrency> { $0.favourite },
		sort: \.sortOrder,
		animation: .default
	) private var favouriteCryptos: [Cryptocurrency]

	@Query(sort: \FiatCurrency.popularity, animation: .default) private var fiatCurrencies: [FiatCurrency]

	@Query(
		filter: #Predicate<FiatCurrency> { $0.favourite },
		sort: \.sortOrder,
		animation: .default
	) private var favouriteFiats: [FiatCurrency]

	private var combinedFavourites: [any Currency] {
		let all = (favouriteCryptos as [any Currency]) + (favouriteFiats as [any Currency])
		return all.sorted { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }
	}

	private var allCurrencies: [any Currency] {
		let all = (cryptocurrencies as [any Currency]) + (fiatCurrencies as [any Currency])
		return all.sorted { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }
	}

	let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

	@StateObject private var scheduler = TickerUpdateScheduler()

	private var currencyService: CurrencyService {
		let repoCrypto = CryptoRepository(modelContext: modelContext)
		let repoFiat = FiatRepository(modelContext: modelContext)
		let repoAll = AllRepository(modelContext: modelContext, cryptoRepo: repoCrypto, fiatRepo: repoFiat)

		let cloudKitService = CloudKitService()

		let cryptoService = CryptocurrencyService(repository: repoCrypto, cloudKitService: cloudKitService)
		let fiatService = FiatCurrencyService(fiatRepository: repoFiat, cloudkitService: cloudKitService)
		return CurrencyService(fiatService: fiatService, cryptoService: cryptoService, currencyRepository: repoAll)
	}

    var body: some View {
		Group {
			if combinedFavourites.count < 1 {
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
					OverviewView(scheduler: scheduler)
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
		.onAppear {
			Task {
				print("Task is called.")

				// Check immediately on appear
				if cryptocurrencies.count < 3 || isPreview {
					scheduler.updateLastExecution()
					try? await currencyService.ensureInitialDataIfNeeded()
					await currencyService.addInitialFavourites(currencies: allCurrencies)
					print("Initial data has happened")
				} else if scheduler.checkIfNeeded() {
					scheduler.updateLastExecution()
					await currencyService.updateAmounts()
					print("Update has happened")
				}
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
	ContentView()
		.modelContainer(Previews.preview)
}
