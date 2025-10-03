//
//  ContentView.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext

	@Query(sort: \CryptoCurrency.id, animation: .default) private var cryptocurrencies: [CryptoCurrency]

	@Query(
		   filter: #Predicate<CryptoCurrency> { $0.favourite },
		   sort: \.id,
		   animation: .default
		 ) private var favouriteCryptos: [CryptoCurrency]


	private let imageService = ImageService()
	private let cryptoService = CryptoService()

	@State private var lastExecution: Date = UserDefaults.standard.object(forKey: "lastExecution") as? Date ?? .distantPast
	@State private var timer: Timer?

	@State private var inputTexts: [String: Double] = [:]
	@State private var isShowingSheet = false
	@FocusState private var focusedCryptoId: String?

	let imageSize: CGFloat = 42

    var body: some View {
		Group {

			if cryptocurrencies.filter({ $0.imageData != nil }).count < 50 {
				ContentUnavailableView {
					VStack(spacing: 8) {
						Label("Wait for data to be fetched.", image: .bitcoin)
							.padding()
						ProgressView()
							.progressViewStyle(CircularProgressViewStyle())
					}
				}
			} else {
				NavigationSplitView {
					List {
						ForEach(favouriteCryptos) { cryptocurrency in
							HStack {
								if cryptocurrency.imageData != nil {
									cryptocurrency.image!
										.resizable()
										.scaledToFit()
										.frame(width: imageSize, height: imageSize)
								} else {
									Image(systemName: "questionmark")
											.resizable()
											.scaledToFit()
											.frame(width: imageSize, height: imageSize)

								}

								VStack(alignment: .leading) {
									Text("\(cryptocurrency.id)")
									Text("\(cryptocurrency.name)")
										.minimumScaleFactor(0.75)
										.lineLimit(1)
								}
								.padding()

								Spacer()

								TextField("0", text: Binding(
									get: {
										let value = inputTexts[cryptocurrency.id] ?? 0
										return value == 0 ? "" : String(format: "%.10f", value)
									},
									set: { input in
										inputTexts[cryptocurrency.id] = Double(input) ?? 0
										updateInputs(basedOn: cryptocurrency.id, with: inputTexts[cryptocurrency.id] ?? 0)
									}
								))
								.multilineTextAlignment(.trailing) // aligns text inside TextField to right
								.keyboardType(.decimalPad)
								.autocorrectionDisabled()
								.font(.title)
								.focused($focusedCryptoId, equals: cryptocurrency.id)

							}
							.swipeActions(edge: .trailing) {
								Button(cryptocurrency.favourite ? "Remove from favourites" : "Add to favourites", systemImage: "trash") {
									withAnimation {
										cryptocurrency.favourite.toggle()
									}
									do {
										try modelContext.save()
									} catch {
										print(error)
									}
								}
								.tint(.red)
							}
						}
					}
					.scrollDismissesKeyboard(.interactively)
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button(action: {
								isShowingSheet.toggle()
							}) {
								Image(systemName: "plus")
							}
							.sheet(isPresented: $isShowingSheet) {
								AddListItems(imageSize: imageSize)
							}
						}
					}
				} detail: {
					Text("Select an item")
				}
			}
		}
		.onAppear {
			Task {
				print("Task is called.")
				print("Cryptos saved so far: \(cryptocurrencies.count)")
				// Check immediately on appear
				if checkIfNeeded() {
					updateLastExecution()
					await updateCryptos()
				} else if cryptocurrencies.count < 3 {
					updateLastExecution()
					await fetchCryptos()
				}
				await startTimer()
			}
		}
		.onDisappear {
			timer?.invalidate()
		}
		.onChange(of: scenePhase, { _, newValue in
			switch newValue {
			case .active:
				if checkIfNeeded() {
					Task {
						updateLastExecution()
						await updateCryptos()
					}
				}
			default:
				focusedCryptoId = nil
			}
		})
    }

	private func startTimer() async {
		// Run check every minute while app is open
		timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
			if checkIfNeeded() {
				updateLastExecution()
				Task {
					await updateCryptos()
				}
			}
		}
	}

	private func checkIfNeeded() -> Bool {
		let now = Date()
		let elapsed = now.timeIntervalSince(lastExecution)

		if elapsed >= 3600 { // 1 hour
			return true
		}
		return false
	}

	private func updateInputs(basedOn cryptoId: String, with value: Double) {
		let crypto = cryptocurrencies.first(where: { $0.id == cryptoId })!

		for cryptocurrency in cryptocurrencies {
			if cryptocurrency.favourite {
				inputTexts[cryptocurrency.id] = (crypto.value * value) / cryptocurrency.value
			}

		}
	}

	private func updateLastExecution() {
		lastExecution = Date()
		UserDefaults.standard.set(lastExecution, forKey: "lastExecution")
	}

	private func updateCryptos() async {
		do {
			let tickers = try await cryptoService.fetchTickers()
			for ticker in tickers {
				if let crypto = CryptoCurrency(ticker: ticker) {
					if let cryptoToUpdate = cryptocurrencies.first(where: { $0.id == crypto.id }) {
						cryptoToUpdate.value = crypto.value
						cryptoToUpdate.marketCap = crypto.marketCap
					}
				}
			}
		} catch {
			print(error)
		}
	}

	private func fetchCryptos() async {
		do {
			let tickers = try await cryptoService.fetchTickers()
			for ticker in tickers {
				if let crypto = CryptoCurrency(ticker: ticker) {
					print("The id of the inserted is: \(crypto.id)")
					if crypto.id == "BTC" || crypto.id == "ETH" {
						crypto.favourite = true
					}
					modelContext.insert(crypto)
//					try await Task.sleep(nanoseconds: 1_000_000)
				}
			}

			try modelContext.save()

			print("FetchLogoURLs is called")
			fetchLogoURLs()

		} catch {
			print(error)
		}
	}

	private func fetchLogoURLs() {
		Task {
			let idsAndUrls = try! await imageService.fetchLogoURLs(for: cryptocurrencies.map(\.id))
			await fillInDatabase(idsAndUrls)

		}
	}

	private func fillInDatabase(_ idsAndUrls: [String : URL]) async {
		for crypto in cryptocurrencies {
			if let url = idsAndUrls[crypto.id] {
				do {
					crypto.imageData = try await URLSession.shared.data(from: url).0
					print("Got image for \(crypto.id) with URL:  \(url)")
					try modelContext.save()
				} catch {
					print(error)
				}
			}
		}

	}

}

#Preview {
    ContentView()
		.modelContainer(Previews.preview)
}
